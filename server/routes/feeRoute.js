import express from "express";
import { requireSignIn, isAdmin } from "../Middlewares/authMiddleware.js";
import {
  createPaymentController,
  markPaidController,
  markUnpaidController,
  updatePaymentController,
  getMemberPaymentsController,
  getAllPaymentsController,
  getOverdueMembersController,
  feeSummaryController,
  paymentRemindersController,
} from "../controlllers/feeController.js";

const router = express.Router();

// All routes require admin auth
router.post("/create-payment", requireSignIn, isAdmin, createPaymentController);
router.put("/mark-paid/:id", requireSignIn, isAdmin, markPaidController);
router.put("/mark-unpaid/:id", requireSignIn, isAdmin, markUnpaidController);
router.put("/update-payment/:id", requireSignIn, isAdmin, updatePaymentController);
router.get("/get-payments/:userId", requireSignIn, isAdmin, getMemberPaymentsController);
router.get("/get-all-payments", requireSignIn, isAdmin, getAllPaymentsController);
router.get("/overdue-members", requireSignIn, isAdmin, getOverdueMembersController);
router.get("/fee-summary", requireSignIn, isAdmin, feeSummaryController);
router.get("/payment-reminders", requireSignIn, isAdmin, paymentRemindersController);

export default router;
