//
//  MagnanimoButton.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/16/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class MagnanimoButton: UIButton {
    
    enum MagnanimoButtonShadowType {
        case None, Small, Medium, Large
    }
    
    init(title: String, shadowType: MagnanimoButtonShadowType) {
        super.init(frame: .zero)
        
        // ignore sizing
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // set title
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        // change layer
        applyShadow(shadowType)
        
        // rounded corners
        self.layer.cornerRadius = Constants.CORNER_RADIUS
        
        // default colors
        self.layer.backgroundColor = UIColor.white.cgColor
        self.setTitleColor(UIColor.Blueprint.DarkGray.DarkGray1, for: .normal)
        
        // padding
        self.titleEdgeInsets = Constants.INSETS
    }
    
    func applyShadow(_ shadowType: MagnanimoButtonShadowType) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = shadowRadiusForType(shadowType)
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
    }
    
    fileprivate func shadowRadiusForType(_ shadowType: MagnanimoButtonShadowType) -> CGFloat {
        switch shadowType {
        case .None:
            return 0
        case .Small:
            return 2
        case .Medium:
            return 4
        case .Large:
            return 6
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += Constants.INSETS.left + Constants.INSETS.right
        intrinsicContentSize.height += Constants.INSETS.top + Constants.INSETS.bottom
        return intrinsicContentSize
    }
    
}

