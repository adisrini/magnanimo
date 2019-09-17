//
//  MagnanimoCurrencyField.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/16/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class MagnanimoCurrencyField: UITextField {
    var string: String { return text ?? "" }

    var decimal: Decimal {
        return string.decimal /
            pow(10, Formatter.currency.maximumFractionDigits)
    }

    var decimalNumber: NSDecimalNumber { return decimal.number }

    var doubleValue: Double { return decimalNumber.doubleValue }

    var integerValue: Int { return decimalNumber.intValue }

    let maximum: Decimal = 1_000_000.00

    private var lastValue: String?
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = UIColor.Magnanimo.Disabled
        self.font = UIFont.Magnanimo.Money
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        keyboardType = .numberPad
        textAlignment = .right
        editingChanged()
    }

    override func deleteBackward() {
        text = string.digits.dropLast().string
        editingChanged()
    }

    @objc func editingChanged() {
        guard decimal <= maximum else {
            text = lastValue
            return
        }
        text = Formatter.currency.string(for: decimal)
        lastValue = text
        if (decimal == 0) {
            self.textColor = UIColor.Magnanimo.Disabled
        } else {
            self.textColor = UIColor.Magnanimo.Money
        }
    }
}

extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
    }
}

extension Formatter {
    static let currency = NumberFormatter(numberStyle: .currency)
}

extension String {
    var digits: String { return filter { $0.isWholeNumber } }
    var decimal: Decimal { return Decimal(string: digits) ?? 0 }
}

extension Decimal {
    var number: NSDecimalNumber { return NSDecimalNumber(decimal: self) }
}

extension LosslessStringConvertible {
    var string: String { return .init(self) }
}
