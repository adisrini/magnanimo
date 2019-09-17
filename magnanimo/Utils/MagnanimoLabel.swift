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
        case Title, Subtitle, Header, Text, SubtleText
    }
    
    init(type: MagnanimoLabelType) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = colorForType(type)
        self.font = fontForType(type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func colorForType(_ type: MagnanimoLabelType) -> UIColor {
        switch type {
        case .Title:
            return UIColor.Magnanimo.Title
        case .Subtitle:
            return UIColor.Magnanimo.Muted
        case .Header:
            return UIColor.Magnanimo.Title
        case .Text:
            return UIColor.Magnanimo.Text
        case .SubtleText:
            return UIColor.Magnanimo.Muted
        }
    }
    
    private func fontForType(_ type: MagnanimoLabelType) -> UIFont {
        switch type {
        case .Title:
            return UIFont.Magnanimo.Title
        case .Subtitle:
            return UIFont.Magnanimo.Subtitle
        case .Header:
            return UIFont.Magnanimo.Header
        case .Text:
            return UIFont.Magnanimo.Text
        case .SubtleText:
            return UIFont.Magnanimo.SmallText
        }
    }

}
