import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  city: {
    type: String,
    default: "",
  },
  address: {
    type: String,
    default: "",
  },
  contact: {
    type: String,
    required: true,
  },
  profilePic: {
    type: String,
    default: "",
  },
  gender: {
    type: String,
    enum: ["male", "female", "other", ""],
    default: "",
  },
  age: {
    type: Number,
    default: null,
  },
  feeAmount: {
    type: Number,
    default: 0,
  },
  feeDueDate: {
    type: Date,
    default: null,
  },
  membershipStart: {
    type: Date,
    default: null,
  },
  membershipEnd: {
    type: Date,
    default: null,
  },
  status: {
    type: String,
    enum: ["active", "inactive", "expired"],
    default: "active",
  },
  emergencyContact: {
    type: String,
    default: "",
  },
  bloodGroup: {
    type: String,
    default: "",
  },
  weight: {
    type: Number,
    default: null,
  },
  height: {
    type: Number,
    default: null,
  },
  role: {
    type: Number,
    default: 0, // 0 = normal user, 1 = admin
  },
}, { timestamps: true });

const User = mongoose.model("User", userSchema);

export { User };

