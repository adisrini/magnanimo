import * as functions from "firebase-functions";
import { Hook } from "../model/types";

// When a user is created, register their IDs
export const createUserCustomer: Hook<functions.auth.UserRecord> = (
  stripe,
  firestore
) =>
  functions.auth.user().onCreate(async user => {
    // create in Stripe
    const customer = await stripe.customers.create({
      name: user.displayName,
      email: user.email
    });

    const firebaseId = user.uid;
    const stripeId = customer.id;

    // create in Firebase

    // firebase user ID -> stripe customer ID
    await firestore
      .collection("users")
      .doc(firebaseId)
      .set({ customer_id: customer.id });

    // stripe customer ID -> firebase user ID
    await firestore
      .collection("customers")
      .doc(stripeId)
      .set({ user_id: firebaseId });
  });

// When a user deletes their account, clean up after them
export const deleteUserCustomer: Hook<functions.auth.UserRecord> = (
  stripe,
  firestore
) =>
  functions.auth.user().onDelete(async user => {
    const userSnapshot = await firestore
      .collection("users")
      .doc(user.uid)
      .get();

    const { customer_id } = userSnapshot.data()!;

    // delete from Stripe
    await stripe.customers.del(customer_id);

    // delete from Firebase
    await firestore
      .collection("users")
      .doc(user.uid)
      .delete();

    await firestore
      .collection("customers")
      .doc(customer_id)
      .delete();
  });
