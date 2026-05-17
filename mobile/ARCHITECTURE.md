# GymMaster Mobile App - Architecture Plan

## Tech Stack
- **Framework:** Flutter (Dart) — iOS & Android from single codebase
- **State Management:** Provider + ChangeNotifier
- **API Client:** Dio (HTTP) + Retrofit-style service classes
- **Local Storage:** SharedPreferences (auth tokens), Hive (offline cache)
- **Navigation:** GoRouter (declarative routing)
- **Backend:** Existing Node.js/Express/MongoDB API

---

## Module Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐  │
│  │  Auth     │ │Dashboard │ │ Members  │ │   Fees     │  │
│  │  Screens  │ │  Screen  │ │ Screens  │ │  Screens   │  │
│  └──────────┘ └──────────┘ └──────────┘ └────────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐  │
│  │  Plans   │ │Attendance│ │ Reports  │ │  Settings  │  │
│  │  Screens │ │  Screens │ │ Screens  │ │  Screens   │  │
│  └──────────┘ └──────────┘ └──────────┘ └────────────┘  │
├─────────────────────────────────────────────────────────┤
│                    PROVIDER LAYER                         │
│  AuthProvider │ MemberProvider │ FeeProvider │ PlanProv   │
│  AttendanceProvider │ DashboardProvider │ SettingsProvider│
├─────────────────────────────────────────────────────────┤
│                    SERVICE LAYER                          │
│  AuthService │ MemberService │ FeeService │ PlanService   │
│  AttendanceService │ SubscriptionService │ ContactService │
├─────────────────────────────────────────────────────────┤
│                    DATA LAYER                             │
│  Models │ API Client (Dio) │ Local Storage │ Hive Cache   │
└─────────────────────────────────────────────────────────┘
```

---

## Screen Map

### 1. AUTH MODULE
- Splash Screen (auto-login check)
- Login Screen
- Register Screen
- Forgot Password Screen

### 2. DASHBOARD (Home)
- Total Members (Active / Inactive / Expired / Blocked)
- Today's Collection Amount
- Today's Attendance Count
- Membership Expiry Alerts (1-3, 4-7, 8-15 days)
- Today's Birthdays
- Monthly Collection vs Due Overview
- Quick Actions (Add Member, Record Payment, Mark Attendance)

### 3. MEMBER MANAGEMENT
- Member List (with search, filters: All/Active/Inactive/Expired/Blocked)
- Member Card (photo, name, M ID, mobile, plan expiry, due amount)
- Member Detail/Profile Screen
- Add Member Screen (name, email, contact, photo, gender, DOB, address, emergency contact, blood group, weight, height)
- Edit Member Screen
- Member Actions: ID Card, Call, WhatsApp, Attendance, Renew Plan, Block/Unblock, Delete

### 4. FEE MANAGEMENT ⭐ (Primary Focus)
- **Fee Dashboard:** Total collected, total due, monthly breakdown
- **Record Payment:** Select member → amount, payment method (Cash/UPI/Card/Bank Transfer), months covered, receipt number, remarks
- **Payment History:** Per-member payment timeline with status (Paid/Unpaid/Partial)
- **Overdue Members List:** Members with unpaid fees, days overdue, quick "send reminder" action
- **Fee Reminders:** Auto-generated reminder list, WhatsApp/SMS integration for sending reminders
- **Fee Summary/Reports:** Collection by date range, payment method breakdown, plan-wise collection
- **Invoice Generation:** Digital receipt with gym branding
- **Discount Management:** Fixed amount or percentage discounts on plans
- **Partial Payment Tracking:** Track members who paid partially, remaining balance
- **Due Date Alerts:** Upcoming due dates (today, this week, this month)
- **Bulk Fee Operations:** Mark multiple payments, generate bulk reminders

### 5. PLAN MANAGEMENT
- Plan List Screen
- Create Plan Screen
- Edit Plan Screen
- Plan Details Screen (with amenities breakdown)
- Plan Assignment (assign plan to member during add/renew)

### 6. SUBSCRIPTION MANAGEMENT
- Active Subscriptions List
- Subscription Details
- Renew Subscription
- Subscription History per Member
- Expiry Alerts

### 7. ATTENDANCE MODULE
- Mark Attendance (tap or QR scan)
- Daily Attendance View
- Attendance History (by member, by date)
- Attendance Reports

### 8. REPORTS & ANALYTICS
- Revenue Reports (daily, weekly, monthly, yearly)
- Member Growth Chart
- Attendance Trends
- Plan Popularity Stats
- Payment Method Distribution
- Overdue Summary

### 9. COMMUNICATION
- WhatsApp Integration (send messages to members)
- Call Integration (direct dial)
- Fee Reminder Notifications (push notifications)
- Birthday Wishes

### 10. SETTINGS & PROFILE
- Gym Profile (name, logo, address, contact)
- Admin Profile
- Notification Preferences
- App Theme (light/dark)
- Backup/Export Data

---

## Data Models

### User/Member
```dart
- id, name, email, password, contact, city, address
- profilePic, gender, age, dateOfBirth
- feeAmount, feeDueDate
- membershipStart, membershipEnd
- status (active/inactive/expired/blocked)
- emergencyContact, bloodGroup, weight, height
- role (0=member, 1=admin)
- membershipId (display ID)
- batch, joinDate
```

### Plan
```dart
- id, planName, monthlyAmount, yearlyAmount
- duration, description
- amenities (water, locker, wifi, cardio, trainer, etc.)
```

### Subscription
```dart
- id, userId, planId, planType, planAmount
- startDate, endDate, status
```

### FeePayment
```dart
- id, userId, amount, dueDate, paymentDate
- isPaid, paymentMethod, month, months
- coverFrom, coverTo, remarks
- receiptNumber, collectedBy
- discount, discountType
- balanceAmount
```

### Attendance
```dart
- id, userId, date, checkInTime, checkOutTime
- markedBy (self/admin)
```

---

## API Integration
Backend already running at existing server. All endpoints documented:
- Auth: /api/v1/auth/*
- Members: /api/v1/member/*
- Fees: /api/v1/fee/*
- Plans: /api/v1/plan/*
- Subscriptions: /api/v1/subscription/*
- Feedback: /api/v1/feedback/*
- Contact: /api/v1/contact/*

---

## Navigation Structure
```
BottomNavigationBar:
├── Members (default tab)
├── Attendance
├── Reports
└── More (Settings, Plans, etc.)

FloatingActionButton: + Add Member

Drawer Menu:
├── Dashboard
├── Members
├── Plans
├── Fee Management
├── Attendance
├── Reports
├── Subscriptions
├── Feedback
├── Settings
└── Logout
```

---

## Color Scheme (from screenshot)
- Primary: Teal (#008080)
- Primary Dark: Dark Teal (#006666)
- Accent: White
- Background: Light Grey (#F5F5F5)
- Card: White
- Text Primary: Dark (#1A1A1A)
- Text Secondary: Teal (#008080)
- Danger: Red (#E53935)
- Success: Green (#43A047)
