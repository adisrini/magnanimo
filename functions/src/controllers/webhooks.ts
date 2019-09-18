import { Controller } from "../model/types";

export const webhooksController: Controller = {
  path: "/webhooks",
  register: (router, stripe, firestore) => {
    router.post("/invoice-payment-succeeded", async (req, res) => {
      const event = req.body;
      switch (event.type) {
        case "invoice.payment_succeeded":
          try {
            const invoice = event.data.object;

            const subscriptionId = invoice.lines.data[0].subscription;
            const chargeId = invoice.charge;

            const subscription = await stripe.subscriptions.retrieve(
              subscriptionId
            );

            const response = stripe.charges.update(chargeId, {
              metadata: {
                type: "subscription",
                is_public: subscription.metadata.is_public,
                organization_id: subscription.metadata.organization_id
              }
            });

            res.status(200).send(response);
            return;
          } catch (err) {
            res.status(500).send(err);
          }
        default:
          // Unexpected event type
          res.status(400).end();
          return;
      }
    });
  }
};
