//
//  StripeCharge.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation

class StripeCharge: NSObject {
    var id: String
    var token: String
    var amountInCents: Double
    var customerId: String
    var isPublic: Bool
    var organizationId: String
    var type: String
    var created: Date
    
    
    public init(id: String, token: String, amountInCents: Double, customerId: String, isPublic: Bool, organizationId: String, type: String, created: Date) {
        self.id = id
        self.token = token
        self.amountInCents = amountInCents
        self.customerId = customerId
        self.isPublic = isPublic
        self.organizationId = organizationId
        self.type = type
        self.created = created
    }
    
    convenience init(id: String, map: [String: Any]) {
        self.init(
            id: map["id"] as! String,
            token: id,
            amountInCents: map["amount"] as! Double,
            customerId: map["customer"] as! String,
            isPublic: map["is_public"] as! Bool,
            organizationId: map["organization_id"] as! String,
            type: map["type"] as! String,
            created: Date(timeIntervalSince1970: map["created"] as! TimeInterval)
        )
    }
}

