//
//  MagnanimoLabel.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/13/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class MagnanimoLabel: UILabel {
    
    enum MagnanimoLabelType {
        case Title, Subtitle, Header, Text
    }
    
    init(type: MagnanimoLabelType) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfLines = 0
        self.textColor = colorForType(type)
        self.font = fontForType(type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func colorForType(_ type: MagnanimoLabelType) -> UIColor {
        switch type {
        case .Title:
            return UIColor.Blueprint.DarkGray.DarkGray1
        case .Subtitle:
            return UIColor.Blueprint.Gray.Gray1
        case .Header:
            return UIColor.Blueprint.DarkGray.DarkGray1
        case .Text:
            return UIColor.Blueprint.DarkGray.DarkGray5
        }
    }
    
    func fontForType(_ type: MagnanimoLabelType) -> UIFont {
        switch type {
        case .Title:
            return UIFont.boldSystemFont(ofSize: 26)
        case .Subtitle:
            return UIFont.systemFont(ofSize: 16)
        case .Header:
            return UIFont.systemFont(ofSize: 22)
        case .Text:
            return UIFont.systemFont(ofSize: 16)
        }
    }

}
