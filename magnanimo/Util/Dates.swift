//
//  Dates.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/17/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import Foundation

class Dates {
    
    static let readableDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        
        return formatter
    }()

}
