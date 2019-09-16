//
//  TagLabel.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/13/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class TagLabel: UILabel {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfLines = 0
        self.layer.cornerRadius = Constants.CORNER_RADIUS
        self.font = UIFont.boldSystemFont(ofSize: 12)
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
}
