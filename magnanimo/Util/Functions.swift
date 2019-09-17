//
//  Functions.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import UIKit

class Functions {

    static func setTimeout(millis: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (millis / 1000)) {
            action()
        }
    }
    
    static func layoutTags(
        view: UIView,
        tags: Array<MagnanimoTag>,
        leadingConstraint: NSLayoutConstraint,
        globalConstraints: Array<(MagnanimoTag) -> NSLayoutConstraint>,
        spacing: CGFloat
    ) {
        var previousTag: MagnanimoTag? = nil

        for tag in tags {
            view.addSubview(tag)
        }
        
        for tag in tags {
            if let prev = previousTag {
                tag.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: spacing).isActive = true
            } else {
                leadingConstraint.isActive = true
            }
            for constraint in globalConstraints {
                constraint(tag).isActive = true
            }
            previousTag = tag
        }
    }
}
