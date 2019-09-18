import { Controller } from "../model/types";
import * as Stripe from "stripe";
import { userFacingMessage } from "../helpers/errors";

export const chargesController: Controller = {
  path: "/charges",
  register: (router, stripe, firestore) => {
    const _getCustomerForUserId = async (userId: string) => {
      const customerSnapshot = await firestore
        .collection("users")
        .doc(userId)
        .get();

      return customerSnapshot.data();
    };

    const _getChargesForCustomerId = (customerId: string) =>
      stripe.charges.list({
        customer: customerId
      });

    // get charges for user
    router.get("/user/:userId", async (req, res) => {
      const { userId } = req.params;

      const customer = await _getCustomerForUserId(userId);

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
          token,
          amount,
          currency,
          type,
          is_public,
          organization_id
        } = req.body;
        const { userId } = req.params;

        const customer = await _getCustomerForUserId(userId);

        if (!customer) {
          res.status(500).send({ error: "User does not exist" });
          return;
        }

        const { customer_id } = customer;

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

        const response = await stripe.charges.create(charge, {
          idempotency_key: token
        });

        res.status(200).send(response);
      } catch (error) {
        res.status(500).send({ error: userFacingMessage(error) });
      }
    });
  }
};
