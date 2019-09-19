//
//  StripeSubscription.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/18/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import SwiftyJSON

class StripeSubscription: NSObject {
    var id: String
    var created: Date
    var currentPeriodEnd: Date
    var amount: Double
    var currency: String
    var interval: String
    var intervalCount: Int
    var organizationId: String
    var isPublic: Bool
    var productId: String
    var planId: String
    
    public init(
        id: String,
        created: Date,
        currentPeriodEnd: Date,
        amount: Double,
        currency: String,
        interval: String,
        intervalCount: Int,
        organizationId: String,
        isPublic: Bool,
        productId: String,
        planId: String
    ) {
        self.id = id
        self.created = created
        self.currentPeriodEnd = currentPeriodEnd
        self.amount = amount
        self.currency = currency
        self.interval = interval
        self.intervalCount = intervalCount
        self.organizationId = organizationId
        self.isPublic = isPublic
        self.productId = productId
        self.planId = planId
    }
    
    convenience init(json: [String: JSON]) {
        let plan = json["items"]!["data"].arrayValue[0]["plan"].dictionaryValue
        self.init(
            id: json["id"]!.stringValue,
            created: Date(timeIntervalSince1970: json["created"]!.doubleValue),
            currentPeriodEnd: Date(timeIntervalSince1970: json["current_period_end"]!.doubleValue),
            amount: plan["amount"]!.doubleValue,
            currency: plan["currency"]!.stringValue,
            interval: plan["interval"]!.stringValue,
            intervalCount: plan["interval_count"]!.intValue,
            organizationId: json["metadata"]!["organization_id"].stringValue,
            isPublic: json["metadata"]!["is_public"].boolValue,
            productId: plan["product"]!.stringValue,
            planId: plan["id"]!.stringValue
        )
    }
}

