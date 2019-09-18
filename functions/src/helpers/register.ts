import * as express from "express";
import * as admin from "firebase-admin";
import * as Stripe from "stripe";
import { Controller } from "../model/types";

export const registerControllers = (
  app: express.Application,
  stripe: Stripe,
  firestore: admin.firestore.Firestore,
  controllers: Controller[]
) =>
  controllers.forEach(controller => {
    const router = express.Router();
    controller.register(router, stripe, firestore);
    app.use(controller.path, router);
  });
