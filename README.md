<p align="center">
  <img src="images/techfusion-logo-text.png" alt="TechFusion Logo" width="180" />
</p>

<h1 align="center">TechFusion — Gaming & PC Hardware Store</h1>

<p align="center">
  <b>A complete mobile shopping app for PC gamers and tech enthusiasts.</b><br>
  Built with Flutter, Dart, and Firebase.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Provider-State%20Management-blueviolet?style=for-the-badge" alt="Provider" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-success?style=for-the-badge" alt="Platform" />
</p>

---

## 📌 Project Overview

**TechFusion** is a cross-platform mobile e-commerce application tailored for PC gaming gear and computer hardware. The app delivers a complete, production-grade retail journey:

- **Customer Journey**: Seamless authentication, category navigation, live search, cart calculations, multi-step checkout with interactive card animations, real-time parcel tracking, and direct WhatsApp customer support.
- **Store Operations**: A dedicated administrative portal equipped with live revenue analytics, interactive chart trends, inventory CRUD management, order fulfillment controls, and user role management.

The system is powered by **Google Firebase** for real-time authentication and cloud database management, with **Provider** managing reactive client state.

---

## 🌟 Key Highlights

- **Two Full Experiences in One App**:
  - **Shopper Mode**: For regular customers browsing, shopping, and tracking their gear.
  - **Admin Mode**: A password-protected control panel with live analytics, inventory control, and order fulfillment.
- **Real-Time Data**: Backed by **Firebase Authentication** and **Cloud Firestore** for instant updates.
- **Provider State Management**: Fast, reactive cart calculations, quantity toggles, and wishlist updates without unnecessary screen re-renders.
- **Interactive Micro-Interactions**: Animated credit card flip for CVV entry, carousel banners, status chips, and step-by-step order progress timelines.
- **Customer Care Built-in**: Integrated 1-tap WhatsApp support directly connects shoppers to customer service.

---

## 📱 App Walkthrough & Screenshots

Here is a visual tour of all the screens in TechFusion, divided into the **Customer Experience** and the **Admin Control Center**.

---

### Part 1: Getting Started (Authentication)

We make it easy for users to get in and start shopping. They can create an account with email and password or tap one button to sign in with Google or Facebook.

<p align="center">
  <img src="assets/Github-images/01_login_screen.jpeg" width="30%" alt="Login Screen" />
  &nbsp;&nbsp;&nbsp;
  <img src="assets/Github-images/02_signup_screen.jpeg" width="30%" alt="Sign Up Screen" />
</p>

| Screen | What It Does |
| :--- | :--- |
| **Welcome Back (Login)** | Clean login screen supporting email/password, plus Google & Facebook quick sign-in. |
| **Create Account (Sign Up)** | Simple registration form with password confirmation and quick navigation. |

---

### Part 2: Exploring the Store (Home, Categories & Search)

The store's home screen is designed to feel like a high-end gaming shop. Customers can check out animated promotions, jump into specific categories (Consoles, Headsets, Keyboards, Mice, Chairs), or search for specific models.

<p align="center">
  <img src="assets/Github-images/03_home_screen.jpeg" width="22%" alt="Home Screen" />
  <img src="assets/Github-images/04_navigation_drawer.jpeg" width="22%" alt="Navigation Drawer" />
  <img src="assets/Github-images/05_all_categories.jpeg" width="22%" alt="All Categories" />
  <img src="assets/Github-images/06_search_products.jpeg" width="22%" alt="Search Products" />
</p>

| Screen | What It Does |
| :--- | :--- |
| **Home Showcase** | Auto-sliding banners, circular category shortcuts, and hot deals section with discount badges. |
| **Slide-Out Menu (Drawer)** | Quick access to the user's profile, past orders, special deals, settings, and logout. |
| **All Categories** | Visual card grid showing every gaming category with custom hardware icons. |
| **Instant Search** | Fast search bar that filters gear immediately as the user types. |

---

### Part 3: Wishlist & Shopping Cart

Shoppers can bookmark items they're saving up for or drop them into their cart. The cart calculates subtotals, checks for free delivery qualification, and updates prices instantly as quantities change.

<p align="center">
  <img src="assets/Github-images/07_wishlist.jpeg" width="30%" alt="Wishlist" />
  &nbsp;&nbsp;&nbsp;
  <img src="assets/Github-images/08_shopping_cart.jpeg" width="30%" alt="Shopping Cart" />
</p>

| Screen | What It Does |
| :--- | :--- |
| **Wishlist** | Save favorite items for later and move them into the cart with one tap. |
| **Shopping Cart** | Increase or decrease item count, delete items, view live subtotal, and proceed to checkout. |

---

### Part 4: 3-Step Checkout & Animated Payment

I wanted the checkout to feel safe and enjoyable rather than boring. The checkout process is broken into 3 clean steps:

1. **Shipping Details**: Country, State, and City picker to ensure accurate delivery.
2. **Payment Selection**: Choose between Credit/Debit card or Cash on Delivery. When entering card details, the card on screen dynamically updates in real-time and even flips over to show the CVV box on the back!
3. **Summary & Confirmation**: Final review of items, delivery address, and payment method before placing the order.

<p align="center">
  <img src="assets/Github-images/09_checkout_shipping.jpeg" width="22%" alt="Shipping Address" />
  <img src="assets/Github-images/10_checkout_payment_method.jpeg" width="22%" alt="Payment Selection" />
  <img src="assets/Github-images/11_checkout_card_cvv_flip.jpeg" width="22%" alt="Card CVV Flip" />
  <img src="assets/Github-images/12_checkout_card_filled.jpeg" width="22%" alt="Live Card Preview" />
</p>

<p align="center">
  <img src="assets/Github-images/13_checkout_order_summary.jpeg" width="30%" alt="Order Summary" />
  &nbsp;&nbsp;&nbsp;
  <img src="assets/Github-images/14_order_success_confirmation.jpeg" width="30%" alt="Order Placed Success" />
</p>

| Screen | What It Does |
| :--- | :--- |
| **Step 1: Shipping Details** | Structured address form with dynamic location selectors. |
| **Step 2: Choose Payment** | Select payment type with an interactive digital credit card. |
| **Interactive Card Flip** | Tapping the CVV field flips the card around just like a real bank card! |
| **Live Card Preview** | Shows cardholder name, formatted card number, and expiration date as you type. |
| **Step 3: Review & Place** | Clear summary showing items, shipping address, and payment method. |
| **Order Confirmation** | Instant green success notification confirming the order has been received. |

---

### Part 5: Live Order Tracking, Wallet & Customer Support

Once an order is placed, customers don't have to wonder where their package is. A vertical progress timeline shows each stage: **Order Placed &rarr; Approved &rarr; Shipped &rarr; Delivered**. There's also built-in wallet tracking, status filtering, and a direct link to chat with support on WhatsApp.

<p align="center">
  <img src="assets/Github-images/15_user_account_dashboard.jpeg" width="22%" alt="Account Dashboard" />
  <img src="assets/Github-images/16_order_tracking_active.jpeg" width="22%" alt="Active Order Progress" />
  <img src="assets/Github-images/17_order_tracking_delivered.jpeg" width="22%" alt="Delivered Order" />
  <img src="assets/Github-images/18_order_tracking_refunded.jpeg" width="22%" alt="Refunded Order" />
</p>

<p align="center">
  <img src="assets/Github-images/19_notifications_screen.jpeg" width="22%" alt="Notifications" />
  <img src="assets/Github-images/20_membership_perks.jpeg" width="22%" alt="Membership Perks" />
  <img src="assets/Github-images/21_profile_settings.jpeg" width="22%" alt="Profile Settings" />
  <img src="assets/Github-images/22_whatsapp_support.jpeg" width="22%" alt="WhatsApp Support" />
</p>

| Screen | What It Does |
| :--- | :--- |
| **Account Dashboard** | View available TechFusion Wallet balance ($400.00) and order status buckets. |
| **Active Order Tracking** | Live step-by-step timeline showing current status (e.g. Pending warehouse processing). |
| **Delivered Orders** | Verified delivery status with unique tracking ID (e.g. `TF-OXE4QQNNSJ`). |
| **Returns & Refunds** | Clear notification when an item return has been accepted and refunded. |
| **Notifications Center** | In-app alerts for shipped packages, flash sales, and security logins. |
| **TechFusion+ Perks** | Explains VIP membership perks like free shipping and extra warranty discounts. |
| **Profile Settings** | Profile verification score (75%), account security, and notification switches. |
| **WhatsApp Support** | Floating button that opens WhatsApp directly to chat with support. |

---

### Part 6: Admin Mode (Store Management & Live Analytics)

For store owners and managers, TechFusion includes a complete **Admin Panel**. When an admin signs in, they unlock controls to oversee the entire business in real-time.

<p align="center">
  <img src="assets/Github-images/23_admin_drawer_menu.jpeg" width="22%" alt="Admin Menu" />
  <img src="assets/Github-images/24_admin_dashboard_overview.jpeg" width="22%" alt="Admin Dashboard" />
  <img src="assets/Github-images/25_admin_revenue_user_growth.jpeg" width="22%" alt="Revenue & User Growth" />
  <img src="assets/Github-images/26_admin_analytics_charts.jpeg" width="22%" alt="Analytics Charts" />
</p>

<p align="center">
  <img src="assets/Github-images/27_admin_product_management_hub.jpeg" width="22%" alt="Product Hub" />
  <img src="assets/Github-images/28_admin_manage_inventory.jpeg" width="22%" alt="Manage Inventory" />
  <img src="assets/Github-images/29_admin_orders_management.jpeg" width="22%" alt="Orders Management" />
  <img src="assets/Github-images/30_admin_update_order_status.jpeg" width="22%" alt="Update Shipping Status" />
</p>

<p align="center">
  <img src="assets/Github-images/31_admin_user_management.jpeg" width="30%" alt="User Management" />
</p>

| Screen | What It Does |
| :--- | :--- |
| **Admin Navigation** | Dedicated drawer menu for quick navigation across the management suite. |
| **Dashboard Overview** | Live KPI counters: Total Users (18), Total Orders (4), and Total Revenue ($9,913.96). |
| **Revenue & Growth Graphs** | Interactive Syncfusion area and line graphs tracking sales curve and sign-ups over time. |
| **Product & Order Breakdown** | Bar chart showing top-selling products and a donut chart breaking down order statuses. |
| **Manage Products Hub** | Central hub to manage New Arrivals, Recommended Gear, and Special Deals. |
| **Inventory Management** | Full CRUD form to add new hardware with title, description, price, category, and photo. |
| **Live Orders Center** | Review incoming customer orders, assign tracking numbers, or process returns. |
| **Update Status Modal** | Simple popup to advance an order's status (Pending &rarr; Shipped &rarr; Delivered). |
| **User Management** | View all registered accounts, see who has Admin vs User privileges, and manage roles. |

---

## 🛠️ Technology Stack & Architecture

Here are the tools and packages that power the application:

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | **Flutter (Dart SDK 3.6+)** | Cross-platform mobile development with native performance. |
| **Backend & Cloud** | **Google Firebase** | `firebase_auth` for secure login, `cloud_firestore` for database. |
| **State Management** | **Provider** | Lightweight, predictable state management for Cart, Wishlist, and Products. |
| **Charts & Analytics** | **Syncfusion Flutter Charts** | Interactive line graphs, bar charts, and donut charts in Admin mode. |
| **Order Timelines** | **timeline_tile** | Vertical progress tracking showing delivery stages. |
| **Payment UI** | **flutter_credit_card** | Realistic animated credit card with CVV flip animation. |
| **External Integration**| **url_launcher** | Seamlessly connects customer support button to WhatsApp. |
| **Location Selector** | **csc_picker** | Country, State, and City cascading dropdowns for checkout. |
| **Animations** | **Lottie & Carousel Slider**| Engaging onboarding slides, banners, and delivery loading states. |

---

## 📂 Project Organization

```text
flutter_techfusion_project/
├── android/                     # Android native project files
├── assets/
│   ├── animations/              # Lottie animated JSON files
│   ├── banners/                 # Promotional sale banners
│   └── Github-images/           # High-resolution screenshots for README
├── images/                      # App branding, logos, and product graphics
├── ios/                         # iOS native project files
├── lib/
│   ├── adminpanel/              # Admin dashboard, orders, inventory & user management
│   ├── authentication/          # Firebase Auth, Google Sign-In & Facebook logic
│   ├── database/                # Firestore service helpers and order models
│   ├── products/                # Product details and category-filtered pages
│   ├── profile_page_settings/   # Settings, password change & 2FA screens
│   ├── shoppingCart/            # Cart providers, wishlist, checkout flow & order models
│   ├── about.dart               # About TechFusion information screen
│   ├── card_membership.dart     # TechFusion+ perks screen
│   ├── login_page.dart          # Sign-in screen
│   ├── main.dart                # App entry point & Firebase initialization
│   ├── mainpage.dart            # Main bottom navigation & home screen
│   ├── search_product_page.dart # Real-time search page
│   └── signup_page.dart         # User registration screen
└── pubspec.yaml                 # Dependencies and asset declarations
```

---

## 🚀 How to Run This Project on Your Machine

### Prerequisites
Make sure you have the following installed on your computer:
1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.6 or newer)
2. [Dart SDK](https://dart.dev/get-dart)
3. Android Studio (with an Android Emulator) or VS Code
4. Git

### Steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/alisami200092/Tech-Fusion.git
   cd Tech-Fusion
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**:
   - Create a project on [Firebase Console](https://console.firebase.google.com/).
   - Enable **Authentication** (Email/Password, Google).
   - Enable **Cloud Firestore Database**.
   - Download your `google-services.json` and place it inside `android/app/`.
   - *(Optional for Admin script)*: Rename `serviceAccountKey.json.example` to `serviceAccountKey.json` and add your private key if you want to run `setCustomClaims.js`.

4. **Run the app**:
   ```bash
   flutter run
   ```
