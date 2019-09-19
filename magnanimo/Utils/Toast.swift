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
    
    enum Intent {
        case None, Success, Warning, Danger
    }
    
    public static func make(_ view: UIView, _ message: String, _ intent: Intent = .None) {
        var style = ToastStyle()
        style.cornerRadius = Constants.CORNER_RADIUS
        style.backgroundColor = self.backgroundColorForIntent(intent)
        style.horizontalPadding = Constants.GRID_SIZE
        
        view.makeToast(message, duration: 4.0, position: .top, style: style)
    }
    
    private static func backgroundColorForIntent(_ intent: Intent) -> UIColor {
        switch intent {
        case .None:
            return UIColor.Blueprint.DarkGray._1
        case .Success:
            return UIColor.Blueprint.Green._2
        case .Warning:
            return UIColor.Blueprint.Orange._2
        case .Danger:
            return UIColor.Blueprint.Red._3
        }
    }
    
}
