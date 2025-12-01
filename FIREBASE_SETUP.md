# Firebase Data Setup Instructions

This guide will help you set up Firebase Firestore with dummy data for the Tap2Eat Admin app.

## ✅ What's Already Done

- ✅ Created `scripts/seed_firestore.js` - automated seed script
- ✅ Created `package.json` with firebase-admin dependency
- ✅ Updated `.gitignore` to exclude service account key

## 🚀 Step-by-Step Instructions

### Step 1: Fix NPM Permissions (One-time fix)

Run this command in your terminal (you'll need to enter your password):

```bash
sudo chown -R 501:20 "/Users/rasal/.npm"
```

### Step 2: Install Dependencies

```bash
cd "/Users/rasal/college project/tap2eat/tap2eat_admin"
npm install
```

This will install `firebase-admin` package.

### Step 3: Get Firebase Service Account Key

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com/project/tap2eat-7642c/settings/serviceaccounts/adminsdk

2. **Generate Private Key:**
   - Click "Generate New Private Key"
   - Confirm by clicking "Generate Key"
   - A JSON file will download

3. **Save the Key:**
   - Rename the downloaded file to `serviceAccountKey.json`
   - Move it to: `/Users/rasal/college project/tap2eat/tap2eat_admin/`
   - ⚠️ **IMPORTANT:** This file contains secrets - never commit it to git!

### Step 4: Run the Seed Script

```bash
cd "/Users/rasal/college project/tap2eat/tap2eat_admin"
npm run seed
```

OR

```bash
cd "/Users/rasal/college project/tap2eat/tap2eat_admin"
node scripts/seed_firestore.js
```

### Step 5: Verify the Data

1. **Open Firebase Console:**
   - Visit: https://console.firebase.google.com/project/tap2eat-7642c/firestore

2. **Check Created Data:**
   - ✅ `users/wX96U4gEhAbdbxekFPTMtp2AFUo1` - should have `canteen_id: "canteen_1"`
   - ✅ `canteens/canteen_1` - Main Campus Canteen
   - ✅ `canteens/canteen_1/menu_items` - 10 menu items (Dosa, Idli, Thali, etc.)
   - ✅ `orders` - 3 sample orders (pending, preparing, ready)
   - ✅ `settings/global` - break slots and cutoff minutes

### Step 6: Update Firestore Security Rules

1. **Go to Firebase Console → Firestore → Rules**
   - Visit: https://console.firebase.google.com/project/tap2eat-7642c/firestore/rules

2. **Replace with these rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }

    // Helper to get user data
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == userId;
    }

    // Canteens collection
    match /canteens/{canteenId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() &&
        (getUserData().role == 'canteen_admin' && getUserData().canteen_id == canteenId)
        || getUserData().role == 'master_admin';

      // Menu items subcollection
      match /menu_items/{itemId} {
        allow read: if isSignedIn();
        allow write: if isSignedIn() &&
          (getUserData().role == 'canteen_admin' && getUserData().canteen_id == canteenId)
          || getUserData().role == 'master_admin';
      }
    }

    // Orders collection
    match /orders/{orderId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() &&
        (getUserData().role == 'canteen_admin' || getUserData().role == 'master_admin');
    }

    // Settings collection (master admin only)
    match /settings/{docId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && getUserData().role == 'master_admin';
    }
  }
}
```

3. **Click "Publish"**

### Step 7: Test the App

1. **Refresh the admin web app** (if it's running)
2. **Navigate to Menu Management**
3. **Try adding a new menu item** - it should work now!
4. **Check the Dashboard** - you should see 3 sample orders

---

## 🎯 What the Seed Script Creates

### User Update
- User ID: `wX96U4gEhAbdbxekFPTMtp2AFUo1`
- Added field: `canteen_id: "canteen_1"`

### Canteen
- ID: `canteen_1`
- Name: Main Campus Canteen
- Max concurrent orders: 20
- Status: Active

### Menu Items (10 items)
- **Breakfast:** Masala Dosa, Idli Vada
- **Lunch:** Veg Thali, Paneer Butter Masala
- **Snacks:** Samosa, Vada Pav
- **Beverages:** Masala Chai, Filter Coffee
- **Desserts:** Gulab Jamun, Vanilla Ice Cream (unavailable)

### Sample Orders (3 orders)
- Order 1: Pending - 2x Masala Dosa (₹90)
- Order 2: Preparing - Veg Thali + Chai (₹95)
- Order 3: Ready - 3x Samosa + 2x Coffee (₹100)

### Settings
- Break slots: 10:30 AM, 1:00 PM, 4:00 PM
- Order cutoff: 5 minutes

---

## ⚠️ Troubleshooting

### Error: "Cannot find module '../serviceAccountKey.json'"
**Solution:** Make sure you downloaded and saved the service account key in the correct location:
```
/Users/rasal/college project/tap2eat/tap2eat_admin/serviceAccountKey.json
```

### Error: "EACCES: permission denied"
**Solution:** Run the npm permissions fix:
```bash
sudo chown -R 501:20 "/Users/rasal/.npm"
```

### Error: "User not found"
**Solution:** Make sure the user `wX96U4gEhAbdbxekFPTMtp2AFUo1` exists in Firestore. Check Firebase Console → Firestore → users collection.

### Script runs but no data appears
**Solution:**
1. Check Firebase Console to verify data was created
2. Make sure Firestore Security Rules are updated
3. Clear browser cache and refresh the app

---

## 🔄 Re-running the Script

The script is **idempotent** - it checks if data already exists before creating it:
- If canteen exists → skips
- If menu items exist → skips
- If orders exist → skips
- If settings exist → skips

You can safely run it multiple times without duplicating data.

---

## 📝 Next Steps After Setup

1. ✅ Verify all data in Firebase Console
2. ✅ Update Security Rules
3. ✅ Test Menu Management (add/edit/delete items)
4. ✅ Test Order Dashboard (update order status)
5. ✅ Ready to continue Phase 4 development!

---

**Created:** 2025-12-01
**Last Updated:** 2025-12-01
