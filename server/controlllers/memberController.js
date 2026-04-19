import { User } from "../models/User.js";
import { hashPassword } from "../helpers/authHelper.js";

// Admin: Add new member
const addMemberController = async (req, res) => {
  try {
    const { name, email, password, contact, city, address, gender, age, feeAmount, feeDueDate, membershipStart, membershipEnd, emergencyContact, bloodGroup, weight, height } = req.body;

    if (!name) return res.status(400).json({ success: false, message: "Name is required" });
    if (!email) return res.status(400).json({ success: false, message: "Email is required" });
    if (!password) return res.status(400).json({ success: false, message: "Password is required" });
    if (!contact) return res.status(400).json({ success: false, message: "Contact is required" });

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ success: false, message: "Member with this email already exists" });
    }

    const hashedPassword = await hashPassword(password);

    let profilePic = "";
    if (req.file) {
      profilePic = `/uploads/${req.file.filename}`;
    }

    const member = await new User({
      name,
      email,
      password: hashedPassword,
      contact,
      city: city || "",
      address: address || "",
      gender: gender || "",
      age: age || null,
      feeAmount: feeAmount || 0,
      feeDueDate: feeDueDate || null,
      membershipStart: membershipStart || new Date(),
      membershipEnd: membershipEnd || null,
      emergencyContact: emergencyContact || "",
      bloodGroup: bloodGroup || "",
      weight: weight || null,
      height: height || null,
      role: 0,
      status: "active",
      profilePic,
    }).save();

    res.status(201).json({
      success: true,
      message: "Member added successfully",
      member: { ...member._doc, password: undefined },
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error adding member", error: error.message });
  }
};

// Admin: Update member
const updateMemberController = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, contact, city, address, gender, age, feeAmount, feeDueDate, membershipStart, membershipEnd, status, emergencyContact, bloodGroup, weight, height } = req.body;

    const member = await User.findById(id);
    if (!member) {
      return res.status(404).json({ success: false, message: "Member not found" });
    }

    const updatedMember = await User.findByIdAndUpdate(
      id,
      {
        name: name || member.name,
        contact: contact || member.contact,
        city: city !== undefined ? city : member.city,
        address: address !== undefined ? address : member.address,
        gender: gender !== undefined ? gender : member.gender,
        age: age !== undefined ? age : member.age,
        feeAmount: feeAmount !== undefined ? feeAmount : member.feeAmount,
        feeDueDate: feeDueDate !== undefined ? feeDueDate : member.feeDueDate,
        membershipStart: membershipStart !== undefined ? membershipStart : member.membershipStart,
        membershipEnd: membershipEnd !== undefined ? membershipEnd : member.membershipEnd,
        status: status || member.status,
        emergencyContact: emergencyContact !== undefined ? emergencyContact : member.emergencyContact,
        bloodGroup: bloodGroup !== undefined ? bloodGroup : member.bloodGroup,
        weight: weight !== undefined ? weight : member.weight,
        height: height !== undefined ? height : member.height,
      },
      { new: true }
    ).select("-password");

    res.status(200).json({
      success: true,
      message: "Member updated successfully",
      member: updatedMember,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error updating member", error: error.message });
  }
};

// Admin: Delete member
const deleteMemberController = async (req, res) => {
  try {
    const { id } = req.params;
    const member = await User.findById(id);
    if (!member) {
      return res.status(404).json({ success: false, message: "Member not found" });
    }
    await User.findByIdAndDelete(id);
    res.status(200).json({ success: true, message: "Member deleted successfully" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error deleting member", error: error.message });
  }
};

// Admin: Get single member
const getMemberController = async (req, res) => {
  try {
    const { id } = req.params;
    const member = await User.findById(id).select("-password");
    if (!member) {
      return res.status(404).json({ success: false, message: "Member not found" });
    }
    res.status(200).json({ success: true, member });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error getting member", error: error.message });
  }
};

// Admin: Get all members (role=0 only, excludes admins)
const getAllMembersController = async (req, res) => {
  try {
    const members = await User.find({ role: 0 }).select("-password").sort({ createdAt: -1 });
    res.status(200).json({ success: true, members });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error getting members", error: error.message });
  }
};

// Admin: Search members
const searchMembersController = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({ success: false, message: "Search query is required" });
    }
    const members = await User.find({
      role: 0,
      $or: [
        { name: { $regex: q, $options: "i" } },
        { email: { $regex: q, $options: "i" } },
        { contact: { $regex: q, $options: "i" } },
        { city: { $regex: q, $options: "i" } },
      ],
    }).select("-password");
    res.status(200).json({ success: true, members });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error searching members", error: error.message });
  }
};

// Admin: Update member status
const updateMemberStatusController = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    if (!["active", "inactive", "expired"].includes(status)) {
      return res.status(400).json({ success: false, message: "Invalid status value" });
    }
    const member = await User.findByIdAndUpdate(id, { status }, { new: true }).select("-password");
    if (!member) {
      return res.status(404).json({ success: false, message: "Member not found" });
    }
    res.status(200).json({ success: true, message: "Status updated", member });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error updating status", error: error.message });
  }
};

// Admin: Update member profile pic
const updateProfilePicController = async (req, res) => {
  try {
    const { id } = req.params;
    if (!req.file) {
      return res.status(400).json({ success: false, message: "No image file provided" });
    }
    const profilePic = `/uploads/${req.file.filename}`;
    const member = await User.findByIdAndUpdate(id, { profilePic }, { new: true }).select("-password");
    if (!member) {
      return res.status(404).json({ success: false, message: "Member not found" });
    }
    res.status(200).json({ success: true, message: "Profile picture updated", member });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error updating profile picture", error: error.message });
  }
};

// Member count (only role=0)
const memberCountController = async (req, res) => {
  try {
    const total = await User.countDocuments({ role: 0 });
    res.status(200).json({ success: true, total });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Error counting members", error: error.message });
  }
};

export {
  addMemberController,
  updateMemberController,
  deleteMemberController,
  getMemberController,
  getAllMembersController,
  searchMembersController,
  updateMemberStatusController,
  updateProfilePicController,
  memberCountController,
};
