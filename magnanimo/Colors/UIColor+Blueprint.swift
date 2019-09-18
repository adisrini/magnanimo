//
//  UIColor+Blueprint.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

struct BlueprintPalette {
    let _1: UIColor
    let _2: UIColor
    let _3: UIColor
    let _4: UIColor
    let _5: UIColor
}

extension UIColor {

    struct Blueprint {
        static let DarkGray = BlueprintPalette(
            _1: UIColor(netHex: 0x182026),
            _2: UIColor(netHex: 0x202B33),
            _3: UIColor(netHex: 0x293742),
            _4: UIColor(netHex: 0x30404D),
            _5: UIColor(netHex: 0x394B59)
        )
        
        static let Gray = BlueprintPalette(
            _1: UIColor(netHex: 0x5C7080),
            _2: UIColor(netHex: 0x738694),
            _3: UIColor(netHex: 0x8A9BA8),
            _4: UIColor(netHex: 0xA7B6C2),
            _5: UIColor(netHex: 0xBFCCD6)
        )
        
        static let LightGray = BlueprintPalette(
            _1: UIColor(netHex: 0xCED9E0),
            _2: UIColor(netHex: 0xD8E1E8),
            _3: UIColor(netHex: 0xE1E8ED),
            _4: UIColor(netHex: 0xEBF1F5),
            _5: UIColor(netHex: 0xF5F8FA)
        )
        
        static let Indigo = BlueprintPalette(
            _1: UIColor(netHex: 0x5642A6),
            _2: UIColor(netHex: 0x634DBF),
            _3: UIColor(netHex: 0x7157D9),
            _4: UIColor(netHex: 0x9179F2),
            _5: UIColor(netHex: 0xAD99FF)
        )
        
        static let Turquoise = BlueprintPalette(
            _1: UIColor(netHex: 0x008075),
            _2: UIColor(netHex: 0x00998C),
            _3: UIColor(netHex: 0x00B3A4),
            _4: UIColor(netHex: 0x14CCBD),
            _5: UIColor(netHex: 0x2EE6D6)
        )
        
        static let Forest = BlueprintPalette(
            _1: UIColor(netHex: 0x1D7324),
            _2: UIColor(netHex: 0x238C2C),
            _3: UIColor(netHex: 0x29A634),
            _4: UIColor(netHex: 0x43BF4D),
            _5: UIColor(netHex: 0x62D96B)
        )
        
        static let Red = BlueprintPalette(
            _1: UIColor(netHex: 0xA82A2A),
            _2: UIColor(netHex: 0xC23030),
            _3: UIColor(netHex: 0xDB3737),
            _4: UIColor(netHex: 0xF55656),
            _5: UIColor(netHex: 0xFF7373)
        )
        
        static let Green = BlueprintPalette(
            _1: UIColor(netHex: 0x0A6640),
            _2: UIColor(netHex: 0x0D8050),
            _3: UIColor(netHex: 0x0F9960),
            _4: UIColor(netHex: 0x15B371),
            _5: UIColor(netHex: 0x3DCC91)
        )
        
        static let Orange = BlueprintPalette(
            _1: UIColor(netHex: 0xA66321),
            _2: UIColor(netHex: 0xBF7326),
            _3: UIColor(netHex: 0xD9822B),
            _4: UIColor(netHex: 0xF29D49),
            _5: UIColor(netHex: 0xFFB366)
        )
        
        struct Util {
            static let Transparent = UIColor(white: 0, alpha: 0)
        }
    }
}
