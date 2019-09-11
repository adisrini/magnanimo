//
//  Organization.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation

class Organization: NSObject {
    var name: String
    var desc: String
    var categoryId: String
    
    public init(name: String, desc: String, categoryId: String) {
        self.name = name
        self.desc = desc
        self.categoryId = categoryId
    }
    
    convenience init(map: [String: Any]) {
        self.init(name: map["name"] as! String, desc: map["description"] as! String, categoryId: map["categoryId"] as! String)
    }
}
