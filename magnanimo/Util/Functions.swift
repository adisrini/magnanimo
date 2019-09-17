//
//  Functions.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation

class Functions {

    static func setTimeout(millis: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (millis / 1000)) {
            action()
        }
    }
}
