//
//  Category.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import UIKit

class Category: NSObject {
    var id: String
    var name: String
    var baseColor: UIColor
    var accentColor: UIColor
    
    public init(id: String, name: String, baseColor: String, accentColor: String) {
        self.id = id
        self.name = name
        self.baseColor = UIColor(netHex: Int(baseColor, radix: 16)!)
        self.accentColor = UIColor(netHex: Int(accentColor, radix: 16)!)
    }
    
    convenience init(id: String, map: [String: Any]) {
        self.init(id: id, name: map["name"] as! String, baseColor: map["baseColor"] as! String, accentColor: map["accentColor"] as! String)
    }
}
