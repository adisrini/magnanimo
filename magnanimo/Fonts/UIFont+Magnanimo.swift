//
//  UIFont+Magnanimo.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/16/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

extension UIFont {
    struct Magnanimo {
        static let Money = UIFont.systemFont(ofSize: 40, weight: UIFont.Weight.heavy)
        static let Title = UIFont.systemFont(ofSize: 26, weight: UIFont.Weight.heavy)
        static let Subtitle = UIFont.systemFont(ofSize: 16)
        static let Header = UIFont.boldSystemFont(ofSize: 22)
        static let Text = UIFont.systemFont(ofSize: 16)
        static let BoldText = UIFont.boldSystemFont(ofSize: 16)
        static let Tag = UIFont.boldSystemFont(ofSize: 12)
        static let SmallText = UIFont.systemFont(ofSize: 12)
    }
}
