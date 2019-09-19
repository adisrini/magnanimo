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
    
    init() {
        super.init(frame: .zero)
        
        // ignore sizing
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // set title
        self.titleLabel?.font = UIFont.Magnanimo.BoldText
        
        // rounded corners
        self.layer.cornerRadius = Constants.CORNER_RADIUS
        
        // default colors
        self.layer.backgroundColor = UIColor.white.cgColor
        
        // padding
        self.titleEdgeInsets = Constants.BUTTON_INSETS
        
        // line breaks
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    public func withIcon(_ iconName: String) -> MagnanimoButton {
        let icon = UIImage(named: iconName)!
        self.setImage(icon, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.GRID_SIZE / 2, bottom: 0, right: Constants.GRID_SIZE / 2)

        return self
    }
    
    public func withTitleAndSubtitle(title: String, subtitle: String) -> MagnanimoButton {
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
        
        self.setAttributedTitle(attributedTitle, for: .normal)
        
        return self
    }
    
    public func withShadowType(type: MagnanimoButtonShadowType) -> MagnanimoButton {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = shadowRadiusForType(type)
        self.layer.shadowOpacity = 0.15
        self.layer.masksToBounds = false
        
        return self
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
    
    public func withTitle(title: String) -> MagnanimoButton {
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Blueprint.DarkGray._1, range: title.fullRange())
        
        self.setAttributedTitle(attributedTitle, for: .normal)
        
        return self
    }
    
    public func withPalette(palette: BlueprintPalette) -> MagnanimoButton {
        self.backgroundColor = palette._5.withAlphaComponent(0.5)
        return self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += Constants.BUTTON_INSETS.left + Constants.BUTTON_INSETS.right
        intrinsicContentSize.height += Constants.BUTTON_INSETS.top + Constants.BUTTON_INSETS.bottom
        return intrinsicContentSize
    }
    
}

