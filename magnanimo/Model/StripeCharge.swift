//
//  StripeCharge.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import SwiftyJSON

class StripeCharge: NSObject {
    var id: String
    var amount: Double
    var customerId: String
    var isPublic: Bool
    var organizationId: String
    var type: String
    var created: Date
    
    
    public init(id: String, amount: Double, customerId: String, isPublic: Bool, organizationId: String, type: String, created: Date) {
        self.id = id
        self.amount = amount
        self.customerId = customerId
        self.isPublic = isPublic
        self.organizationId = organizationId
        self.type = type
        self.created = created
    }
    
    convenience init(json: [String: JSON]) {
        self.init(
            id: json["id"]!.stringValue,
            amount: json["amount"]!.doubleValue,
            customerId: json["customer"]!.stringValue,
            isPublic: json["metadata"]!["is_public"].boolValue,
            organizationId: json["metadata"]!["organization_id"].stringValue,
            type: json["metadata"]!["type"].stringValue,
            created: Date(timeIntervalSince1970: json["created"]!.doubleValue)
        )
    }
}

