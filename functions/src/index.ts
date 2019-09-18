import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as Stripe from "stripe";
import * as express from "express";
import * as cors from "cors";
import * as bodyParser from "body-parser";
import { registerControllers } from "./helpers/register";
import { webhooksController } from "./controllers/webhooks";
import { chargesController } from "./controllers/charges";
import { createUserCustomer, deleteUserCustomer } from "./hooks/users";

// initialize
const stripe = new Stripe(functions.config().stripe.secret_key_test);
admin.initializeApp();
const app = express();

// middleware
app.use(cors({ origin: true }));
app.use(bodyParser.json());

// register controllers
registerControllers(app, stripe, admin.firestore(), [
  // :: /api/webhooks
  webhooksController,
  // :: /api/charges
  chargesController
]);

exports.api = functions.https.onRequest(app);
exports.createUserCustomer = createUserCustomer(stripe, admin.firestore());
exports.deleteUserCustomer = deleteUserCustomer(stripe, admin.firestore());

// /**
//  * FIRESTORE HOOKS
//  */

// // [START chargecustomer]
// // Charge the Stripe customer whenever an amount is created in Cloud Firestore
// exports.createStripeCharge = functions.firestore
//   .document("stripe_customers/{userId}/charges/{id}")
//   .onCreate(async (snap, context) => {
//     const val = snap.data()!;
//     try {
//       // Look up the Stripe customer id written in createStripeCustomer
//       const snapshot = await admin
//         .firestore()
//         .collection(`stripe_customers`)
//         .doc(context.params.userId)
//         .get();
//       const snapval = snapshot.data()!;
//       const customer = snapval.customer_id;
//       // Create a charge using the pushId as the idempotency key
//       // protecting against double charges
//       const amount = val.amount;
//       const currency = val.currency;
//       const idempotencyKey = context.params.id;
//       const charge = {
//         amount,
//         currency,
//         customer
//       };
//       const maybeExists = await stripe.charges.retrieve(idempotencyKey);
//       if (!maybeExists.id) {
//         const response = await stripe.charges.create(charge, {
//           idempotency_key: idempotencyKey
//         });
//         // If the result is successful, write it back to the database
//         return snap.ref.set(response, { merge: true });
//       }
//     } catch (error) {
//       // We want to capture errors and render them in a user-friendly way, while
//       // still logging an exception with StackDriver
//       console.log(error);
//       await snap.ref.set({ error: userFacingMessage(error) }, { merge: true });
//       return reportError(error, { user: context.params.userId });
//     }
//   });
// // [END chargecustomer]]

// exports.createStripeSubscription = functions.firestore
//   .document("stripe_customers/{userId}/subscriptions/{id}")
//   .onCreate(async (subscriptionSnapshot, context) => {
//     const subscriptionDocument = subscriptionSnapshot.data()!;
//     try {
//       // Look up the Stripe customer id written in createStripeCustomer
//       const customerSnapshot = await admin
//         .firestore()
//         .collection(`stripe_customers`)
//         .doc(context.params.userId)
//         .get();
//       const customer = customerSnapshot.data()!;
//       const { customer_id } = customer;

//       // Create a Stripe plan
//       const {
//         amount,
//         currency,
//         interval,
//         product_id,
//         is_public
//       } = subscriptionDocument;
//       const plan = {
//         product: product_id,
//         amount,
//         currency,
//         interval
//       };
//       const planResponse = await stripe.plans.create(plan);

//       // Subscribe the customer
//       const subscription = {
//         customer: customer_id,
//         metadata: {
//           is_public
//         },
//         items: [
//           {
//             plan: planResponse.id
//           }
//         ]
//       };

//       const subscriptionResponse = await stripe.subscriptions.create(
//         subscription
//       );

//       // If the result is successful, write it back to the database
//       return subscriptionSnapshot.ref.set(subscriptionResponse, {
//         merge: true
//       });
//     } catch (error) {
//       // We want to capture errors and render them in a user-friendly way, while
//       // still logging an exception with StackDriver
//       console.log(error);
//       await subscriptionSnapshot.ref.set(
//         { error: userFacingMessage(error) },
//         { merge: true }
//       );
//       return reportError(error, { user: context.params.userId });
//     }
//   });

// // Add a payment source (card) for a user by writing a stripe payment source token to Cloud Firestore
// exports.addPaymentSource = functions.firestore
//   .document("/stripe_customers/{userId}/tokens/{pushId}")
//   .onCreate(async (snap, context) => {
//     const source = snap.data()!;
//     const token = source.token;
//     if (source === null) {
//       return null;
//     }

//     try {
//       const snapshot = await admin
//         .firestore()
//         .collection("stripe_customers")
//         .doc(context.params.userId)
//         .get();
//       const customer = snapshot.data()!.customer_id;
//       const response = await stripe.customers.createSource(customer, {
//         source: token
//       });
//       return admin
//         .firestore()
//         .collection("stripe_customers")
//         .doc(context.params.userId)
//         .collection("sources")
//         .doc(response.fingerprint)
//         .set(response, { merge: true });
//     } catch (error) {
//       await snap.ref.set({ error: userFacingMessage(error) }, { merge: true });
//       return reportError(error, { user: context.params.userId });
//     }
//   });
