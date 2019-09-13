//
//  UIColor+Blueprint.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

extension UIColor {
    struct Blueprint {
        struct DarkGray {
            static let DarkGray1 = UIColor(netHex: 0x182026)
            static let DarkGray2 = UIColor(netHex: 0x202B33)
            static let DarkGray3 = UIColor(netHex: 0x293742)
            static let DarkGray4 = UIColor(netHex: 0x30404D)
            static let DarkGray5 = UIColor(netHex: 0x394B59)
        }
        
        struct Gray {
            static let Gray1 = UIColor(netHex: 0x5C7080)
            static let Gray2 = UIColor(netHex: 0x738694)
            static let Gray3 = UIColor(netHex: 0x8A9BA8)
            static let Gray4 = UIColor(netHex: 0xA7B6C2)
            static let Gray5 = UIColor(netHex: 0xBFCCD6)
        }
        
        struct LightGray {
            static let LightGray1 = UIColor(netHex: 0xCED9E0)
            static let LightGray2 = UIColor(netHex: 0xD8E1E8)
            static let LightGray3 = UIColor(netHex: 0xE1E8ED)
            static let LightGray4 = UIColor(netHex: 0xEBF1F5)
            static let LightGray5 = UIColor(netHex: 0xF5F8FA)
        }
        
        struct Indigo {
            static let Indigo1 = UIColor(netHex: 0x5642A6)
            static let Indigo2 = UIColor(netHex: 0x634DBF)
            static let Indigo3 = UIColor(netHex: 0x7157D9)
            static let Indigo4 = UIColor(netHex: 0x9179F2)
            static let Indigo5 = UIColor(netHex: 0xAD99FF)
        }
        
        struct Util {
            static let Transparent = UIColor(white: 0, alpha: 0)
        }
    }
}
