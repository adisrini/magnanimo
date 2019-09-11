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
    var name: String
    var color: UIColor
    
    public init(name: String, color: String) {
        self.name = name
        self.color = UIColor(netHex: Int(color, radix: 16)!)
    }
    
    convenience init(map: [String: Any]) {
        self.init(name: map["name"] as! String, color: map["color"] as! String)
    }
}
