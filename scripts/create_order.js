const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Configuration
const CANTEEN_ID = 'canteen_1';
const USER_ID = 'wX96U4gEhAbdbxekFPTMtp2AFUo1'; // Change this to your test user ID

/**
 * Create a new order
 */
async function createOrder() {
  console.log('\n📦 Creating new order...');

  // Calculate fulfillment slot (30 minutes from now to satisfy cutoff rule)
  const now = new Date();
  const fulfillmentTime = new Date(now.getTime() + 30 * 60000);

  const order = {
    canteen_id: CANTEEN_ID,
    user_id: USER_ID,
    items: [
      {
        id: 'item_masala_dosa',
        name: 'Masala Dosa',
        quantity: 2,
        price: 45.00
      },
      {
        id: 'item_chai',
        name: 'Masala Chai',
        quantity: 1,
        price: 15.00
      }
    ],
    total_amount: 105.00, // (45 * 2) + 15
    fulfillment_slot: admin.firestore.Timestamp.fromDate(fulfillmentTime),
    fulfillment_type: 'pickup',
    status: 'pending',
    delivery_fee: 0,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp()
  };

  try {
    const ordersRef = db.collection('orders');
    const docRef = await ordersRef.add(order);

    console.log(`✅ Order created successfully!`);
    console.log(`   Order ID: ${docRef.id}`);
    console.log(`   User ID: ${order.user_id}`);
    console.log(`   Canteen ID: ${order.canteen_id}`);
    console.log(`   Total Amount: ₹${order.total_amount}`);
    console.log(`   Fulfillment Time: ${fulfillmentTime.toLocaleString()}`);
    console.log(`   Items:`);
    order.items.forEach(item => {
      console.log(`     - ${item.quantity}x ${item.name} @ ₹${item.price}`);
    });
    console.log(`   Status: ${order.status}`);
    console.log(`   Type: ${order.fulfillment_type}\n`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating order:', error.message);
    process.exit(1);
  }
}

// Run the script
createOrder();
