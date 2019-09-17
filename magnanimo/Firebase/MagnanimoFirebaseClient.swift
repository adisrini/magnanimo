//
//  MagnanimoFirebaseClient.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class MagnanimoFirebaseClient {
    
    typealias MagnanimoFirebaseCompletion<T> = (Array<T>) -> Void
    
    static let db = Firestore.firestore()
    
    private static func handleSnapshotCompletion<T>(
        completion: @escaping MagnanimoFirebaseCompletion<T>,
        createObjectFn: @escaping (DocumentSnapshot) -> T
    ) -> FIRQuerySnapshotBlock {
        return { (querySnapshot, err) in
            if let err = err {
                print("Error fetching documents: \(err)")
                return
            } else {
                let mapped = querySnapshot!.documents.map({ doc in createObjectFn(doc) })
                completion(mapped)
            }
        }
    }
    
    static func getOrganizations(completion: @escaping MagnanimoFirebaseCompletion<Organization>) {
        self.db.collection("organizations").getDocuments(
            completion: handleSnapshotCompletion(
                completion: completion,
                createObjectFn: { doc in Organization(id: doc.documentID, map: doc.data()! )}
            )
        )
    }
    
    static func getCategories(completion: @escaping MagnanimoFirebaseCompletion<Category>) {
        self.db.collection("categories").getDocuments(
            completion: handleSnapshotCompletion(
                completion: completion,
                createObjectFn: { doc in Category(id: doc.documentID, map: doc.data()! )}
            )
        )
    }
    
    /**
     * Gets all successful user charges (where status == succeeded)
     */
    static func getSuccessfulUserCharges(completion: @escaping MagnanimoFirebaseCompletion<StripeCharge>) {
        self.db.collection("stripe_customers")
            .document(Auth.auth().currentUser!.uid)
            .collection("charges")
            .whereField("status", isEqualTo: "succeeded")
            .order(by: "created", descending: true)
            .getDocuments(
                completion: handleSnapshotCompletion(
                    completion: completion,
                    createObjectFn: { doc in StripeCharge(id: doc.documentID, map: doc.data()! )}
                )
            )
    }

    static func getSuccessfulUserChargesForOrganization(
        organizationId: String,
        completion: @escaping MagnanimoFirebaseCompletion<StripeCharge>
    ) {
        self.db.collection("stripe_customers")
            .document(Auth.auth().currentUser!.uid)
            .collection("charges")
            .whereField("status", isEqualTo: "succeeded")
            .whereField("organization_id", isEqualTo: organizationId)
            .order(by: "created", descending: true)
            .getDocuments(
                completion: handleSnapshotCompletion(
                    completion: completion,
                    createObjectFn: { doc in StripeCharge(id: doc.documentID, map: doc.data()! )}
                )
        )
    }
    
    static func customerRef() -> DocumentReference {
        return self.db.collection("stripe_customers").document((Auth.auth().currentUser?.uid)!)
    }
    
    static func createPaymentSource(token: String) {
        self.customerRef()
            .collection("tokens")
            .document(token)
            .setData([
                "token": token
                ])
    }
    
    static func createCharge(token: String, amount: Decimal, currency: String, type: String, isPublic: Bool, organizationId: String) {
        self.customerRef()
            .collection("charges")
            .document(token)
            .setData([
                "amount": amount,
                "currency": currency,
                "type": type,
                "is_public": isPublic,
                "organization_id": organizationId
                ])
    }
    
}
