//
//  Organization.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation

class Organization: NSObject {
    var id: String
    var name: String
    var desc: String
    var categoryId: String
    var productId: String
    
    public init(id: String, name: String, desc: String, categoryId: String, productId: String) {
        self.id = id
        self.name = name
        self.desc = desc
        self.categoryId = categoryId
        self.productId = productId
    }
    
    convenience init(id: String, map: [String: Any]) {
        self.init(
            id: id,
            name: map["name"] as! String,
            desc: map["description"] as! String,
            categoryId: map["categoryId"] as! String,
            productId: map["product_id"] as! String
        )
    }
}
