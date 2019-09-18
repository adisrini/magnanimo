import { Controller } from "../model/types";
import * as Stripe from "stripe";
import { userFacingMessage } from "../helpers/errors";
import { _getCustomerForUserId, _tryAttachingSource } from "../helpers/utils";

export const chargesController: Controller = {
  path: "/charges",
  register: (router, stripe, firestore) => {
    const _getChargesForCustomerId = (customerId: string) =>
      stripe.charges
        .list({
          customer: customerId
        })
        .then(r => r.data);

    // get charges for user
    router.get("/user/:userId", async (req, res) => {
      const { userId } = req.params;

      const customer = await _getCustomerForUserId(firestore, userId);

      if (!customer) {
        res.status(500).send({ error: "User does not exist" });
        return;
      }

      const { customer_id } = customer;

      res
        .status(200)
        .send({ charges: await _getChargesForCustomerId(customer_id) });
    });

    // get charges for customer
    router.get("/customer/:customerId", async (req, res) => {
      const { customerId } = req.params;
      res
        .status(200)
        .send({ charges: await _getChargesForCustomerId(customerId) });
    });

    // post charge for user
    router.post("/user/:userId", async (req, res) => {
      try {
        const {
          source,
          amount,
          currency,
          type,
          is_public,
          organization_id,
          idempotency_key
        } = req.body;
        const { userId } = req.params;

        // 1. get user
        const customerDocument = await _getCustomerForUserId(firestore, userId);

        if (!customerDocument) {
          res.status(500).send({ error: "User does not exist" });
          return;
        }

        const { customer_id } = customerDocument;

        // 2. try attaching source
        await _tryAttachingSource(stripe, source, customer_id);

        const charge: Stripe.charges.IChargeCreationOptions = {
          amount,
          currency,
          customer: customer_id,
          metadata: {
            type,
            is_public,
            organization_id
          }
        };

        // 3. create charge
        const response = await stripe.charges.create(charge, {
          idempotency_key: idempotency_key
        });

        res.status(200).send(response);
      } catch (error) {
        res.status(500).send({ error: userFacingMessage(error) });
      }
    });
  }
};
