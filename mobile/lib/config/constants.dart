class ApiConstants {
  static const String baseUrl = 'https://gymmaster-g33n.onrender.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String userProfile = '/auth/user-profile';
  static const String totalUsers = '/auth/total-user';
  static const String allUsers = '/auth/get-all-users';

  // Members
  static const String addMember = '/member/add-member';
  static const String updateMember = '/member/update-member';
  static const String deleteMember = '/member/delete-member';
  static const String getMember = '/member/get-member';
  static const String allMembers = '/member/get-all-members';
  static const String searchMembers = '/member/search-members';
  static const String updateMemberStatus = '/member/update-member-status';
  static const String updateProfilePic = '/member/update-profile-pic';
  static const String totalMembers = '/member/total-member';

  // Fees
  static const String createPayment = '/fee/create-payment';
  static const String markPaid = '/fee/mark-paid';
  static const String markUnpaid = '/fee/mark-unpaid';
  static const String updatePayment = '/fee/update-payment';
  static const String getPayments = '/fee/get-payments';
  static const String allPayments = '/fee/get-all-payments';
  static const String overdueMembers = '/fee/overdue-members';
  static const String feeSummary = '/fee/fee-summary';
  static const String paymentReminders = '/fee/payment-reminders';

  // Plans
  static const String createPlan = '/plan/create-plan';
  static const String updatePlan = '/plan/update-plan';
  static const String deletePlan = '/plan/delete-plan';
  static const String allPlans = '/plan/getall-plan';
  static const String getPlan = '/plan/get-plan';
  static const String totalPlans = '/plan/total-plan';

  // Subscriptions
  static const String createSubscription = '/subscription/create-subscription';
  static const String updateSubscription = '/subscription/update-subscription';
  static const String deleteSubscription = '/subscription/delete-subscription';
  static const String allSubscriptions = '/subscription/getall-subscription';
  static const String getSubscription = '/subscription/get-subscription';
  static const String totalSubscriptions = '/subscription/total-subscription';

  // Feedback
  static const String createFeedback = '/feedback/create-feedback';
  static const String allFeedback = '/feedback/getall-feedback';
  static const String totalFeedback = '/feedback/total-feedback';

  // Contact
  static const String createContact = '/contact/create-contact';
  static const String allContacts = '/contact/getall-contact';
  static const String totalContacts = '/contact/total-contact';
}
