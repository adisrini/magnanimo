//
//  TagLabel.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/13/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class TagLabel: UILabel {
    
    let inset = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfLines = 0
        self.layer.cornerRadius = 4
        self.font = UIFont.boldSystemFont(ofSize: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += self.inset.left + self.inset.right
        intrinsicContentSize.height += self.inset.top + self.inset.bottom
        return intrinsicContentSize
    }
}
