//
//  StringProtocol.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/16/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation

extension StringProtocol {
    func nsRange(from range: Range<Index>) -> NSRange {
        return .init(range, in: self)
    }
    
    func fullRange() -> NSRange {
        return NSRange(location: 0, length: self.count)
    }
}
