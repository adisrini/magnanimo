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
import { subscriptionsController } from "./controllers/subscriptions";

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
  chargesController,
  // :: /api/subscriptions
  subscriptionsController
]);

exports.api = functions.https.onRequest(app);
exports.createUserCustomer = createUserCustomer(stripe, admin.firestore());
exports.deleteUserCustomer = deleteUserCustomer(stripe, admin.firestore());
