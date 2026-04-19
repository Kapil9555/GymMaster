import express from "express";
import { requireSignIn, isAdmin } from "../Middlewares/authMiddleware.js";
import multer from "multer";
import path from "path";
import {
  addMemberController,
  updateMemberController,
  deleteMemberController,
  getMemberController,
  getAllMembersController,
  searchMembersController,
  updateMemberStatusController,
  updateProfilePicController,
  memberCountController,
} from "../controlllers/memberController.js";

const router = express.Router();

// Multer config for profile pic uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/webp"];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error("Only JPEG, JPG, PNG, and WEBP images are allowed"), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
});

// All routes require admin auth
router.post("/add-member", requireSignIn, isAdmin, upload.single("profilePic"), addMemberController);
router.put("/update-member/:id", requireSignIn, isAdmin, updateMemberController);
router.delete("/delete-member/:id", requireSignIn, isAdmin, deleteMemberController);
router.get("/get-member/:id", requireSignIn, isAdmin, getMemberController);
router.get("/get-all-members", requireSignIn, isAdmin, getAllMembersController);
router.get("/search-members", requireSignIn, isAdmin, searchMembersController);
router.put("/update-status/:id", requireSignIn, isAdmin, updateMemberStatusController);
router.put("/update-profile-pic/:id", requireSignIn, isAdmin, upload.single("profilePic"), updateProfilePicController);
router.get("/total-members", requireSignIn, isAdmin, memberCountController);

export default router;
