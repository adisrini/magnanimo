import { Controller } from "../model/types";
import { userFacingMessage } from "../helpers/errors";
import { _getCustomerForUserId, _tryAttachingSource } from "../helpers/utils";
import Stripe = require("stripe");

export const subscriptionsController: Controller = {
  path: "/subscriptions",
  register: (router, stripe, firestore) => {
    // post subscription for user
    router.post("/user/:userId", async (req, res) => {
      try {
        const {
          amount,
          currency,
          interval,
          product_id,
          is_public,
          source,
          idempotency_key
        } = req.body;
        const { userId } = req.params;

        // 1. get customer
        const customerDocument = await _getCustomerForUserId(firestore, userId);

        if (!customerDocument) {
          res.status(500).send({ error: "User does not exist" });
          return;
        }

        const { customer_id } = customerDocument;

        // 2. create plan
        const plan: Stripe.plans.IPlanCreationOptions = {
          product: product_id,
          amount,
          currency,
          interval
        };
        const stripePlan = await stripe.plans.create(plan);

        // 3. try attaching source
        await _tryAttachingSource(stripe, source, customer_id);

        // 4. subscribe the customer
        const subscription: Stripe.subscriptions.ISubscriptionCreationOptions = {
          customer: customer_id,
          metadata: {
            is_public
          },
          items: [
            {
              plan: stripePlan.id
            }
          ]
        };

        const response = await stripe.subscriptions.create(subscription, {
          idempotency_key: idempotency_key
        });

        res.status(200).send(response);
      } catch (error) {
        res.status(500).send({ error: userFacingMessage(error) });
      }
    });
  }
};
