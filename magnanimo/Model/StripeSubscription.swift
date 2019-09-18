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
    var intervalCount: Double
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
        intervalCount: Double,
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
        self.init(
            id: json["id"]!.stringValue,
            created: Date(timeIntervalSince1970: json["created"]!.doubleValue),
            currentPeriodEnd: Date(timeIntervalSince1970: json["current_period_end"]!.doubleValue),
            amount: json["plan"]!["amount"].doubleValue,
            currency: json["plan"]!["currency"].stringValue,
            interval: json["plan"]!["interval"].stringValue,
            intervalCount: json["plan"]!["interval_count"].doubleValue,
            organizationId: json["metadata"]!["organization_id"].stringValue,
            isPublic: json["metadata"]!["is_public"].boolValue,
            productId: json["plan"]!["product"].stringValue,
            planId: json["plan"]!["id"].stringValue
        )
    }
}

