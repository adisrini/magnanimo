//
//  MagnanimoClient
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Alamofire
import SwiftyJSON

class MagnanimoClient {
    
    typealias MagnanimoCompletion<T> = (T) -> Void
    typealias MagnanimoFailure = MagnanimoCompletion<String>
    typealias MagnanimoFirebaseSuccess = MagnanimoCompletion<QuerySnapshot>
    typealias MagnanimoHTTPSuccess = MagnanimoCompletion<JSON>
    
    // MARK: - Constants
    static let db = Firestore.firestore()
    static let baseURL = "https://us-central1-magnanimo-app.cloudfunctions.net/api"
    static let organizations = db.collection("organizations")
    static let categories = db.collection("categories")
    static let user = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    
    // MARK: - Organizations

    static func getAllOrganizations(
        failure: @escaping MagnanimoFailure,
        success: @escaping MagnanimoCompletion<Array<Organization>>
    ) {
        organizations.getDocuments(
            completion: handleSnapshotCompletion(
                failure: failure,
                success: { querySnapshot in
                    success(querySnapshot.documents.map({ doc in Organization(id: doc.documentID, map: doc.data()!) }))
                }
            )
        )
    }
    
    
    // MARK: - Categories
    
    static func getAllCategories(
        failure: @escaping MagnanimoFailure,
        success: @escaping MagnanimoCompletion<Array<Category>>
        ) {
        categories.getDocuments(
            completion: handleSnapshotCompletion(
                failure: failure,
                success: { querySnapshot in
                    success(querySnapshot.documents.map({ doc in Category(id: doc.documentID, map: doc.data()!) }))
                }
            )
        )
    }
    
    
    // MARK: - Charges

    static func getUserCharges(
        failure: @escaping MagnanimoFailure,
        success: @escaping MagnanimoCompletion<Array<StripeCharge>>
    ) {
        executeHTTPRequest(
            request: AF.request(
                baseURL + "/charges/user/" + Auth.auth().currentUser!.uid,
                method: .get
            ),
            failure: failure,
            success: { json in
                success(json["charges"].arrayValue.map({ cjson in StripeCharge(json: cjson.dictionaryValue) }))
            }
        )
    }

    static func getUserChargesForOrganization(
        organizationId: String,
        failure: @escaping MagnanimoFailure,
        success: @escaping MagnanimoCompletion<Array<StripeCharge>>
        ) {
        self.getUserCharges(
            failure: failure,
            success: { charges in success(charges.filter({ charge in charge.organizationId == organizationId })) }
        )
    }
    
    static func createCharge(
        token: String,
        amount: Decimal,
        currency: String,
        type: String,
        isPublic: Bool,
        organizationId: String,
        failure: @escaping MagnanimoFailure,
        success: @escaping MagnanimoCompletion<StripeCharge>
        ) {
        executeHTTPRequest(
            request: AF.request(
                baseURL + "/charges/user/" + Auth.auth().currentUser!.uid,
                method: .post,
                parameters: [
                    "token": token,
                    "amount": amount,
                    "currency": currency,
                    "is_public": isPublic,
                    "organization_id": organizationId
                ]
            ),
            failure: failure,
            success: { charge in
                success(StripeCharge(json: charge.dictionaryValue))
            }
        )
    }
    
    
    // MARK: - Helpers
    
    /**
     * Executes a Firebase request. Handles errors, calling the appropriate completion.
     */
    private static func handleSnapshotCompletion(
        failure: @escaping MagnanimoFailure,
        success: @escaping MagnanimoFirebaseSuccess
        ) -> FIRQuerySnapshotBlock {
        return { (querySnapshot, err) in
            if let err = err {
                failure(err.localizedDescription)
                print(err)
                return
            } else if let querySnapshot = querySnapshot {
                success(querySnapshot)
                return
            } else {
                let errorMessage = "No data"
                failure(errorMessage)
                print(errorMessage)
                return
            }
        }
    }
    
    /**
     * Executes an HTTP request. Parses data and handles errors, calling the appropriate completion.
     */
    private static func executeHTTPRequest(
        request: DataRequest,
        failure: @escaping MagnanimoFailure,
        success: @escaping MagnanimoHTTPSuccess
        ) {
        request.validate().responseJSON { response in
            if let data = response.data, let json = try? JSON(data: data) {
                switch response.result {
                case .success:
                    success(json)
                    return
                case .failure:
                    let errorMessage = json["error"].string ?? "Unknown error"
                    failure(errorMessage)
                    print(errorMessage)
                    return
                }
            } else {
                let errorMessage = "Bad response"
                failure(errorMessage)
                print(errorMessage + ": \(response)")
                return
            }
        }
    }
}
