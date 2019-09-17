//
//  MagnanimoChargeTableView.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation
import UIKit

class MagnanimoChargeTableView: UITableView {
    
    init() {
        super.init(frame: .zero, style: .plain)
        self.alwaysBounceVertical = false
        self.isScrollEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class MagnanimoChargeTableViewCell: UITableViewCell {
    
    static let ID = "chargeCell"
    
    var charge: StripeCharge? {
        didSet {
            if let charge = charge {
                // amount
                amountLabel.text = Formatter.currency.string(from: NSNumber(value: charge.amountInCents / 100))
                
                // type
                let isOneTime = charge.type == PaymentType.ONE_TIME
                paymentTypeTag = paymentTypeTag.withTextAndColor(
                    text: isOneTime ? "ONE-TIME" : "SUBSCRIPTION",
                    baseColor: isOneTime ? UIColor.Blueprint.Turquoise.Turquoise3 : UIColor.Blueprint.Forest.Forest3,
                    accentColor: isOneTime ? UIColor.Blueprint.Turquoise.Turquoise2 : UIColor.Blueprint.Forest.Forest2
                )
                
                // is public
                isPublicTag = isPublicTag.withTextAndColor(
                    text: charge.isPublic ? "PUBLIC" : "PRIVATE",
                    baseColor: UIColor.Blueprint.Gray.Gray3,
                    accentColor: UIColor.Blueprint.Gray.Gray2
                )
            }
        }
    }

    var organization: Organization?
    var category: Category?
    
    fileprivate let amountLabel: UILabel = MagnanimoLabel(type: .Header)
    fileprivate var isPublicTag = MagnanimoTag()
    fileprivate var paymentTypeTag = MagnanimoTag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        positionAmount()
        positionTags()
    }
    
    // MARK: - Positioning
    private func positionAmount() {
        self.addSubview(amountLabel)
        amountLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.GRID_SIZE / 2).isActive = true
        amountLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.GRID_SIZE / 2).isActive = true
    }
    
    private func positionTags() {
        let tags = [paymentTypeTag, isPublicTag]
        Functions.layoutTags(
            view: self,
            tags: tags,
            leadingConstraint: paymentTypeTag.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
            globalConstraints: [{ tag in tag.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(Constants.GRID_SIZE / 2)) }],
            spacing: Constants.GRID_SIZE / 2
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
