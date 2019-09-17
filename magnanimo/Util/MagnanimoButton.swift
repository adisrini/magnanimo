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
    
    convenience init(title: String, shadowType: MagnanimoButtonShadowType) {
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Blueprint.DarkGray._1, range: title.fullRange())
        
        self.init(attributedTitle: attributedTitle, shadowType: shadowType)
    }
    
    convenience init(title: String, subtitle: String, shadowType: MagnanimoButtonShadowType) {
        let combined = title + "\n" + subtitle
        
        let attributedTitle = NSMutableAttributedString(string: combined)

        attributedTitle.addAttributes([
            NSAttributedString.Key.font: UIFont.Magnanimo.BoldText,
            NSAttributedString.Key.foregroundColor: UIColor.Magnanimo.Title
            ], range: combined.nsRange(from: combined.range(of: title)!))

        attributedTitle.addAttributes([
            NSAttributedString.Key.font: UIFont.Magnanimo.SmallText,
            NSAttributedString.Key.foregroundColor: UIColor.Magnanimo.Muted
            ], range: combined.nsRange(from: combined.range(of: subtitle)!))
        
        self.init(attributedTitle: attributedTitle, shadowType: shadowType)
    }
    
    init(attributedTitle: NSAttributedString, shadowType: MagnanimoButtonShadowType) {
        super.init(frame: .zero)
        
        // ignore sizing
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // set title
        self.setAttributedTitle(attributedTitle, for: .normal)
        self.titleLabel?.font = UIFont.Magnanimo.BoldText
        
        // change layer
        applyShadow(shadowType)
        
        // rounded corners
        self.layer.cornerRadius = Constants.CORNER_RADIUS
        
        // default colors
        self.layer.backgroundColor = UIColor.white.cgColor
        
        // padding
        self.titleEdgeInsets = Constants.INSETS
        
        // line breaks
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    private func applyShadow(_ shadowType: MagnanimoButtonShadowType) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = shadowRadiusForType(shadowType)
        self.layer.shadowOpacity = 0.15
        self.layer.masksToBounds = false
    }
    
    private func shadowRadiusForType(_ shadowType: MagnanimoButtonShadowType) -> CGFloat {
        switch shadowType {
        case .None:
            return 0
        case .Small:
            return 3
        case .Medium:
            return 6
        case .Large:
            return 9
        }
    }
    
    public func withIcon(_ iconName: String) -> MagnanimoButton {
        let icon = UIImage(named: iconName)!
        self.setImage(icon, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.GRID_SIZE / 2, bottom: 0, right: Constants.GRID_SIZE / 2)

        return self
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

