import * as express from "express";
import * as admin from "firebase-admin";
import * as Stripe from "stripe";
import * as functions from "firebase-functions";

export interface Controller {
  path: string;
  register: (
    router: express.Router,
    stripe: Stripe,
    firestore: admin.firestore.Firestore
  ) => void;
}

export type Hook<T> = (
  stripe: Stripe,
  firestore: admin.firestore.Firestore
) => functions.CloudFunction<T>;
