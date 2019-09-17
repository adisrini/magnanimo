//
//  MagnanimoTag.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/13/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class MagnanimoTag: UILabel {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfLines = 0
        self.layer.cornerRadius = Constants.CORNER_RADIUS
        self.font = UIFont.Magnanimo.Tag
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.inset(by: Constants.INSETS))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += Constants.INSETS.left + Constants.INSETS.right
        intrinsicContentSize.height += Constants.INSETS.top + Constants.INSETS.bottom
        return intrinsicContentSize
    }
    
    func withTextAndColor(text: String, palette: BlueprintPalette) -> MagnanimoTag {
        return withTextAndColor(text: text, baseColor: palette._3, accentColor: palette._2)
    }
    
    func withTextAndColor(text: String, baseColor: UIColor, accentColor: UIColor) -> MagnanimoTag {
        let attributedString = NSMutableAttributedString(string: text.uppercased())
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.4), range: NSRange(location: 0, length: text.count))
        self.attributedText = attributedString
        self.layer.backgroundColor = baseColor.withAlphaComponent(0.15).cgColor
        self.textColor = accentColor
        
        return self
    }
}
