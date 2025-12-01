const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// User ID to update
const USER_ID = 'wX96U4gEhAbdbxekFPTMtp2AFUo1';
const CANTEEN_ID = 'canteen_1';

/**
 * Step 1: Update user with canteen_id
 */
async function updateUserWithCanteen() {
  console.log('\n📝 Step 1: Updating user with canteen_id...');

  try {
    const userRef = db.collection('users').doc(USER_ID);
    await userRef.update({
      canteen_id: CANTEEN_ID
    });
    console.log(`✅ User ${USER_ID} updated with canteen_id: ${CANTEEN_ID}`);
  } catch (error) {
    console.error('❌ Error updating user:', error.message);
    throw error;
  }
}

/**
 * Step 2: Create canteen document
 */
async function createCanteen() {
  console.log('\n🏪 Step 2: Creating canteen document...');

  try {
    const canteenRef = db.collection('canteens').doc(CANTEEN_ID);
    const canteenDoc = await canteenRef.get();

    if (canteenDoc.exists) {
      console.log('ℹ️  Canteen already exists, skipping...');
      return;
    }

    await canteenRef.set({
      name: 'Main Campus Canteen',
      max_concurrent_orders: 20,
      is_active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`✅ Canteen ${CANTEEN_ID} created successfully`);
  } catch (error) {
    console.error('❌ Error creating canteen:', error.message);
    throw error;
  }
}

/**
 * Step 3: Create menu items
 */
async function createMenuItems() {
  console.log('\n🍽️  Step 3: Creating menu items...');

  const menuItems = [
    {
      name: 'Masala Dosa',
      description: 'Crispy dosa filled with spiced potato',
      price: 45.00,
      category: 'Breakfast',
      image_url: 'https://images.unsplash.com/photo-1694809956742-e66b8c6e2178?w=400',
      is_available: true
    },
    {
      name: 'Idli Vada',
      description: '2 Idlis and 1 Vada with sambar and chutney',
      price: 40.00,
      category: 'Breakfast',
      image_url: 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400',
      is_available: true
    },
    {
      name: 'Veg Thali',
      description: 'Complete meal with rice, dal, sabzi, roti, and salad',
      price: 80.00,
      category: 'Lunch',
      image_url: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',
      is_available: true
    },
    {
      name: 'Paneer Butter Masala',
      description: 'Rich creamy paneer curry with naan',
      price: 95.00,
      category: 'Lunch',
      image_url: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400',
      is_available: true
    },
    {
      name: 'Samosa',
      description: '2 pieces crispy fried samosa with chutney',
      price: 20.00,
      category: 'Snacks',
      image_url: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
      is_available: true
    },
    {
      name: 'Vada Pav',
      description: 'Mumbai style potato vada in pav',
      price: 25.00,
      category: 'Snacks',
      image_url: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=400',
      is_available: true
    },
    {
      name: 'Masala Chai',
      description: 'Hot tea with aromatic spices',
      price: 15.00,
      category: 'Beverages',
      image_url: 'https://images.unsplash.com/photo-1597318181409-cf64992eabe8?w=400',
      is_available: true
    },
    {
      name: 'Filter Coffee',
      description: 'South Indian style filter coffee',
      price: 20.00,
      category: 'Beverages',
      image_url: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400',
      is_available: true
    },
    {
      name: 'Gulab Jamun',
      description: '2 pieces soft gulab jamun in sugar syrup',
      price: 30.00,
      category: 'Desserts',
      image_url: 'https://images.unsplash.com/photo-1620654681954-c66fef3abbc9?w=400',
      is_available: true
    },
    {
      name: 'Vanilla Ice Cream',
      description: 'Single scoop vanilla ice cream',
      price: 35.00,
      category: 'Desserts',
      image_url: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
      is_available: false
    }
  ];

  try {
    const menuItemsRef = db.collection('canteens').doc(CANTEEN_ID).collection('menu_items');
    const existingItems = await menuItemsRef.limit(1).get();

    if (!existingItems.empty) {
      console.log('ℹ️  Menu items already exist, skipping...');
      return;
    }

    const batch = db.batch();

    menuItems.forEach((item) => {
      const docRef = menuItemsRef.doc();
      batch.set(docRef, item);
    });

    await batch.commit();
    console.log(`✅ Created ${menuItems.length} menu items successfully`);
  } catch (error) {
    console.error('❌ Error creating menu items:', error.message);
    throw error;
  }
}

/**
 * Step 4: Create sample orders
 */
async function createSampleOrders() {
  console.log('\n📦 Step 4: Creating sample orders...');

  const now = new Date();
  const thirtyMinLater = new Date(now.getTime() + 30 * 60000);
  const oneHourLater = new Date(now.getTime() + 60 * 60000);
  const twoHoursLater = new Date(now.getTime() + 120 * 60000);

  const orders = [
    {
      canteen_id: CANTEEN_ID,
      user_id: 'user_student_1',
      items: [
        {
          id: 'item_dosa',
          name: 'Masala Dosa',
          quantity: 2,
          price: 45.00
        }
      ],
      total_amount: 90.00,
      fulfillment_slot: admin.firestore.Timestamp.fromDate(thirtyMinLater),
      fulfillment_type: 'pickup',
      status: 'pending',
      delivery_fee: 0,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    },
    {
      canteen_id: CANTEEN_ID,
      user_id: 'user_student_2',
      items: [
        {
          id: 'item_thali',
          name: 'Veg Thali',
          quantity: 1,
          price: 80.00
        },
        {
          id: 'item_chai',
          name: 'Masala Chai',
          quantity: 1,
          price: 15.00
        }
      ],
      total_amount: 95.00,
      fulfillment_slot: admin.firestore.Timestamp.fromDate(oneHourLater),
      fulfillment_type: 'pickup',
      status: 'preparing',
      delivery_fee: 0,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    },
    {
      canteen_id: CANTEEN_ID,
      user_id: 'user_teacher_1',
      items: [
        {
          id: 'item_samosa',
          name: 'Samosa',
          quantity: 3,
          price: 20.00
        },
        {
          id: 'item_coffee',
          name: 'Filter Coffee',
          quantity: 2,
          price: 20.00
        }
      ],
      total_amount: 100.00,
      fulfillment_slot: admin.firestore.Timestamp.fromDate(twoHoursLater),
      fulfillment_type: 'pickup',
      status: 'ready',
      delivery_fee: 0,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    }
  ];

  try {
    const ordersRef = db.collection('orders');
    const existingOrders = await ordersRef.where('canteen_id', '==', CANTEEN_ID).limit(1).get();

    if (!existingOrders.empty) {
      console.log('ℹ️  Orders already exist, skipping...');
      return;
    }

    const batch = db.batch();

    orders.forEach((order) => {
      const docRef = ordersRef.doc();
      batch.set(docRef, order);
    });

    await batch.commit();
    console.log(`✅ Created ${orders.length} sample orders successfully`);
  } catch (error) {
    console.error('❌ Error creating orders:', error.message);
    throw error;
  }
}

/**
 * Step 5: Create settings document
 */
async function createSettings() {
  console.log('\n⚙️  Step 5: Creating settings document...');

  try {
    const settingsRef = db.collection('settings').doc('global');
    const settingsDoc = await settingsRef.get();

    if (settingsDoc.exists) {
      console.log('ℹ️  Settings already exist, skipping...');
      return;
    }

    const now = new Date();
    const breakSlots = [
      new Date(now.getFullYear(), now.getMonth(), now.getDate(), 10, 30),
      new Date(now.getFullYear(), now.getMonth(), now.getDate(), 13, 0),
      new Date(now.getFullYear(), now.getMonth(), now.getDate(), 16, 0)
    ];

    await settingsRef.set({
      break_slots: breakSlots.map(slot => admin.firestore.Timestamp.fromDate(slot)),
      order_cutoff_minutes: 5
    });

    console.log('✅ Settings document created successfully');
  } catch (error) {
    console.error('❌ Error creating settings:', error.message);
    throw error;
  }
}

/**
 * Main function to orchestrate all operations
 */
async function main() {
  console.log('🚀 Starting Firebase Firestore seed script...');
  console.log('═══════════════════════════════════════════════\n');

  try {
    await updateUserWithCanteen();
    await createCanteen();
    await createMenuItems();
    await createSampleOrders();
    await createSettings();

    console.log('\n═══════════════════════════════════════════════');
    console.log('✨ All done! Database seeded successfully!');
    console.log('\n📋 Summary:');
    console.log(`   - User ${USER_ID} assigned to ${CANTEEN_ID}`);
    console.log('   - Canteen created with max 20 concurrent orders');
    console.log('   - 10 menu items added (Breakfast, Lunch, Snacks, Beverages, Desserts)');
    console.log('   - 3 sample orders created (pending, preparing, ready)');
    console.log('   - Global settings configured');
    console.log('\n🔍 Next steps:');
    console.log('   1. Check Firebase Console to verify data');
    console.log('   2. Update Firestore Security Rules (see plan for rules)');
    console.log('   3. Refresh your admin app and test Menu Management!');
    console.log('\n');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Script failed:', error);
    process.exit(1);
  }
}

// Run the script
main();
