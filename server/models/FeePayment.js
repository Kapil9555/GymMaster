import mongoose from "mongoose";

const feePaymentSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  dueDate: {
    type: Date,
    required: true,
  },
  paymentDate: {
    type: Date,
    default: null,
  },
  isPaid: {
    type: Boolean,
    default: false,
  },
  paymentMethod: {
    type: String,
    enum: ["cash", "upi", "card", "bank_transfer", ""],
    default: "",
  },
  month: {
    type: String,
    default: "",
  },
  months: {
    type: Number,
    default: 1,
  },
  coverFrom: {
    type: Date,
    default: null,
  },
  coverTo: {
    type: Date,
    default: null,
  },
  remarks: {
    type: String,
    default: "",
  },
  receiptNumber: {
    type: String,
    default: "",
  },
  collectedBy: {
    type: String,
    default: "",
  },
}, { timestamps: true });

const FeePayment = mongoose.model("FeePayment", feePaymentSchema);

export default FeePayment;
