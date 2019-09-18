import * as admin from "firebase-admin";
import * as Stripe from "stripe";

export const _getCustomerForUserId = async (
  firestore: admin.firestore.Firestore,
  userId: string
) => {
  const customerSnapshot = await firestore
    .collection("users")
    .doc(userId)
    .get();

  return customerSnapshot.data();
};

export const _tryAttachingSource = async (
  stripe: Stripe,
  source: string,
  customerId: string
) => {
  // TODO: may need to adjust for non-card sources
  const getUniqueIdentifier = (_stripeSource: Stripe.sources.ISource) =>
    _stripeSource.card!.fingerprint;

  const stripeSource = await stripe.sources.retrieve(source);
  const stripeCustomer = await stripe.customers.retrieve(customerId);
  const uniqueIdentifier = getUniqueIdentifier(stripeSource);
  const maybeExistingCard = stripeCustomer.sources!.data.find(
    s => s.object === "source" && uniqueIdentifier === getUniqueIdentifier(s)
  );

  if (!maybeExistingCard) {
    await stripe.customers.createSource(customerId, {
      source
    });
    await stripe.customers.update(customerId, {
      default_source: source
    });
  }
};

export async function _getAllObjects<
  O extends { id: string },
  S extends Stripe.IListOptions,
  R extends { list: (options: S) => Stripe.IListPromise<O> }
>(resource: R, options: S) {
  const LIMIT = 50;

  const objects: O[] = [];

  const firstResponse = await resource.list({
    ...options,
    limit: LIMIT
  });

  objects.push(...firstResponse.data);
  let hasMore = firstResponse.has_more;

  while (hasMore) {
    const lastObjectId = objects[objects.length - 1].id;
    const response = await resource.list({
      ...options,
      limit: LIMIT,
      starting_after: lastObjectId
    });
    objects.push(...response.data);
    hasMore = response.has_more;
  }

  return objects;
}
