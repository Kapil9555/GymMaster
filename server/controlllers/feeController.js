import FeePayment from "../models/FeePayment.js";
import { User } from "../models/User.js";

// Create fee payment record
const createPaymentController = async (req, res) => {
  try {
    const { userId, amount, dueDate, paymentDate, isPaid, paymentMethod, months, remarks, receiptNumber, collectedBy } = req.body;

    if (!userId) return res.status(400).json({ success: false, message: "User ID is required" });
    if (!amount) return res.status(400).json({ success: false, message: "Amount is required" });
    if (!months || months < 1) return res.status(400).json({ success: false, message: "Months must be at least 1" });

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "Member not found" });
    }

    // Calculate base due date: use existing feeDueDate if set, otherwise use today
    const baseDueDate = user.feeDueDate ? new Date(user.feeDueDate) : new Date();
    
    // coverFrom = baseDueDate (start of period), coverTo = baseDueDate + N months
    const coverFrom = new Date(baseDueDate);
    const coverTo = new Date(baseDueDate);
    coverTo.setMonth(coverTo.getMonth() + Number(months));

    // Generate readable month label e.g. "Apr 2026 - Jun 2026"
    const fmt = (d) => d.toLocaleString('en-IN', { month: 'short', year: 'numeric' });
    const monthLabel = Number(months) === 1 ? fmt(coverFrom) : `${fmt(coverFrom)} → ${fmt(coverTo)}`;

    const payment = await new FeePayment({
      user: userId,
      amount,
      dueDate: dueDate || baseDueDate,
      paymentDate: isPaid ? (paymentDate || new Date()) : null,
      isPaid: isPaid || false,
      paymentMethod: paymentMethod || "",
      month: monthLabel,
      months: Number(months),
      coverFrom,
      coverTo,
      remarks: remarks || "",
      receiptNumber: receiptNumber || "",
      collectedBy: collectedBy || "",
    }).save();

    // Auto-calculate next due date: advance by N months
    if (isPaid) {
      await User.findByIdAndUpdate(userId, { feeDueDate: coverTo });
    }

    res.status(201).json({ success: true, message: "Payment recorded successfully", payment });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error creating payment", error: error.message });
  }
};

// Mark fee as paid
const markPaidController = async (req, res) => {
  try {
    const { id } = req.params;
    const { paymentMethod, paymentDate, collectedBy, remarks } = req.body;

    const payment = await FeePayment.findById(id);
    if (!payment) {
      return res.status(404).json({ success: false, message: "Payment record not found" });
    }

    payment.isPaid = true;
    payment.paymentDate = paymentDate || new Date();
    payment.paymentMethod = paymentMethod || "cash";
    payment.collectedBy = collectedBy || "";
    payment.remarks = remarks || payment.remarks;
    await payment.save();

    // Update user's next fee due date — use coverTo if available, otherwise calculate
    const nextDueDate = payment.coverTo
      ? new Date(payment.coverTo)
      : (() => { const d = new Date(payment.dueDate); d.setMonth(d.getMonth() + (payment.months || 1)); return d; })();
    await User.findByIdAndUpdate(payment.user, { feeDueDate: nextDueDate });

    res.status(200).json({ success: true, message: "Fee marked as paid", payment });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error marking fee as paid", error: error.message });
  }
};

// Mark fee as unpaid
const markUnpaidController = async (req, res) => {
  try {
    const { id } = req.params;
    const payment = await FeePayment.findByIdAndUpdate(
      id,
      { isPaid: false, paymentDate: null, paymentMethod: "" },
      { new: true }
    );
    if (!payment) {
      return res.status(404).json({ success: false, message: "Payment record not found" });
    }
    res.status(200).json({ success: true, message: "Fee marked as unpaid", payment });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error marking fee as unpaid", error: error.message });
  }
};

// Update payment record
const updatePaymentController = async (req, res) => {
  try {
    const { id } = req.params;
    const payment = await FeePayment.findByIdAndUpdate(id, req.body, { new: true });
    if (!payment) {
      return res.status(404).json({ success: false, message: "Payment record not found" });
    }
    res.status(200).json({ success: true, message: "Payment updated", payment });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error updating payment", error: error.message });
  }
};

// Get all payments for a member
const getMemberPaymentsController = async (req, res) => {
  try {
    const { userId } = req.params;
    const payments = await FeePayment.find({ user: userId }).populate("user", "-password").sort({ dueDate: -1 });
    res.status(200).json({ success: true, payments });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error fetching payments", error: error.message });
  }
};

// Get all payments (admin)
const getAllPaymentsController = async (req, res) => {
  try {
    const payments = await FeePayment.find({}).populate("user", "-password").sort({ createdAt: -1 });
    res.status(200).json({ success: true, payments });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error fetching payments", error: error.message });
  }
};

// Get overdue members
const getOverdueMembersController = async (req, res) => {
  try {
    const today = new Date();
    const overdueMembers = await User.find({
      role: 0,
      status: "active",
      feeDueDate: { $lt: today, $ne: null },
    }).select("-password").sort({ feeDueDate: 1 });

    res.status(200).json({ success: true, members: overdueMembers });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error fetching overdue members", error: error.message });
  }
};

// Fee summary
const feeSummaryController = async (req, res) => {
  try {
    const totalMembers = await User.countDocuments({ role: 0 });
    const activeMembers = await User.countDocuments({ role: 0, status: "active" });
    const today = new Date();
    const overdueCount = await User.countDocuments({
      role: 0,
      status: "active",
      feeDueDate: { $lt: today, $ne: null },
    });

    const currentMonth = today.toLocaleString("default", { month: "long", year: "numeric" });
    const monthPayments = await FeePayment.find({ month: currentMonth });
    const totalCollected = monthPayments.filter(p => p.isPaid).reduce((sum, p) => sum + p.amount, 0);
    const totalPending = monthPayments.filter(p => !p.isPaid).reduce((sum, p) => sum + p.amount, 0);
    const paidCount = monthPayments.filter(p => p.isPaid).length;
    const unpaidCount = monthPayments.filter(p => !p.isPaid).length;

    res.status(200).json({
      success: true,
      summary: {
        totalMembers,
        activeMembers,
        overdueCount,
        currentMonth,
        totalCollected,
        totalPending,
        paidCount,
        unpaidCount,
      },
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error fetching summary", error: error.message });
  }
};

// Payment reminders / notifications
const paymentRemindersController = async (req, res) => {
  try {
    const today = new Date();
    const fiveDaysLater = new Date();
    fiveDaysLater.setDate(today.getDate() + 5);

    // Overdue members
    const overdue = await User.find({
      role: 0,
      status: "active",
      feeDueDate: { $lt: today, $ne: null },
    }).select("name contact feeDueDate feeAmount profilePic").sort({ feeDueDate: 1 });

    // Upcoming due (within 5 days)
    const upcoming = await User.find({
      role: 0,
      status: "active",
      feeDueDate: { $gte: today, $lte: fiveDaysLater },
    }).select("name contact feeDueDate feeAmount profilePic").sort({ feeDueDate: 1 });

    const notifications = [];

    overdue.forEach(m => {
      const days = Math.floor((today - new Date(m.feeDueDate)) / (1000 * 60 * 60 * 24));
      notifications.push({
        _id: m._id,
        type: "overdue",
        name: m.name,
        contact: m.contact,
        feeAmount: m.feeAmount,
        feeDueDate: m.feeDueDate,
        message: `${m.name}'s payment is overdue by ${days} day(s) — ₹${m.feeAmount || 0}`,
      });
    });

    upcoming.forEach(m => {
      const days = Math.ceil((new Date(m.feeDueDate) - today) / (1000 * 60 * 60 * 24));
      notifications.push({
        _id: m._id,
        type: "upcoming",
        name: m.name,
        contact: m.contact,
        feeAmount: m.feeAmount,
        feeDueDate: m.feeDueDate,
        message: `${m.name}'s payment due in ${days} day(s) — ₹${m.feeAmount || 0}`,
      });
    });

    res.status(200).json({ success: true, notifications, overdueCount: overdue.length, upcomingCount: upcoming.length });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error fetching reminders", error: error.message });
  }
};

export {
  createPaymentController,
  markPaidController,
  markUnpaidController,
  updatePaymentController,
  getMemberPaymentsController,
  getAllPaymentsController,
  getOverdueMembersController,
  feeSummaryController,
  paymentRemindersController,
};
