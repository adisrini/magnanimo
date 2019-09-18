//
//  Toast.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/18/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import Toast_Swift

class Toast {
    
    public static func make(_ view: UIView, _ message: String) {
        view.makeToast(message, duration: 3.0, position: .top)
    }
    
}
