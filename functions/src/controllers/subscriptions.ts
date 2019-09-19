import { Controller } from "../model/types";
import { userFacingMessage } from "../helpers/errors";
import {
  _getCustomerForUserId,
  _tryAttachingSource,
  _getAllObjects
} from "../helpers/utils";
import Stripe = require("stripe");

export const subscriptionsController: Controller = {
  path: "/subscriptions",
  register: (router, stripe, firestore) => {
    const _getSubscriptionsForCustomerId = async (customerId: string) =>
      _getAllObjects<
        Stripe.subscriptions.ISubscription,
        Stripe.subscriptions.ISubscriptionListOptions,
        Stripe.resources.Subscriptions
      >(stripe.subscriptions, { customer: customerId });

    // get all subscriptions for user
    router.get("/user/:userId", async (req, res) => {
      const { userId } = req.params;

      const customer = await _getCustomerForUserId(firestore, userId);

      if (!customer) {
        res.status(500).send({ error: "User does not exist" });
        return;
      }

      const { customer_id } = customer;

      res.status(200).send({
        subscriptions: await _getSubscriptionsForCustomerId(customer_id)
      });
    });

    // get subscription for organization for user
    router.get(
      "/user/:userId/organization/:organizationId",
      async (req, res) => {
        const { userId, organizationId } = req.params;

        const customer = await _getCustomerForUserId(firestore, userId);

        if (!customer) {
          res.status(500).send({ error: "User does not exist" });
          return;
        }

        const { customer_id } = customer;

        res.status(200).send({
          subscription: (await _getSubscriptionsForCustomerId(
            customer_id
          )).find(
            subscription =>
              subscription.metadata.organization_id === organizationId
          )
        });
      }
    );

    // create subscription for user
    router.post("/user/:userId", async (req, res) => {
      try {
        const {
          amount,
          currency,
          interval,
          interval_count,
          product_id,
          organization_id,
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
          interval,
          interval_count
        };
        const stripePlan = await stripe.plans.create(plan);

        // 3. try attaching source
        await _tryAttachingSource(stripe, source, customer_id);

        // 4. subscribe the customer
        const subscription: Stripe.subscriptions.ISubscriptionCreationOptions = {
          customer: customer_id,
          metadata: {
            is_public,
            organization_id
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

    // update subscription for user
    router.put("/:id", async (req, res) => {
      try {
        const {
          amount,
          currency,
          interval,
          interval_count,
          is_public,
          product_id,
          idempotency_key
        } = req.body;
        const { id } = req.params;

        // 1. update the subscription
        const subscription = await stripe.subscriptions.retrieve(id);
        let response = await stripe.subscriptions.update(
          id,
          {
            metadata: {
              ...subscription.metadata,
              is_public
            }
          },
          {
            idempotency_key: idempotency_key
          }
        );

        // 2. if necessary, create a new plan and attach to subscription
        const subscriptionLineItem = subscription.items.data[0];
        const plan = await stripe.plans.retrieve(subscriptionLineItem.plan.id);

        if (
          amount !== plan.amount ||
          currency !== plan.currency ||
          interval !== plan.interval ||
          interval_count !== plan.interval_count
        ) {
          const newPlan = await stripe.plans.create({
            product: product_id,
            amount,
            currency,
            interval,
            interval_count
          });
          response = await stripe.subscriptions.update(id, {
            items: [
              {
                id: subscriptionLineItem.id,
                plan: newPlan.id
              }
            ]
          });
        }

        res.status(200).send(response);
      } catch (error) {
        res.status(500).send({ error: userFacingMessage(error) });
      }
    });

    router.delete("/:id", async (req, res) => {
      try {
        const { id } = req.params;
        const response = await stripe.subscriptions.del(id);
        res.status(200).send(response);
      } catch (error) {
        res.status(500).send({ error: userFacingMessage(error) });
      }
    });
  }
};
