//
//  OneTimePaymentViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/16/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class OneTimePaymentViewController: UIViewController {
    
    var organization: Organization?
    
    fileprivate let headerLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.text = "Enter your amount"
        
        return label
    }()
    
    fileprivate let amountField = MagnanimoCurrencyField()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        positionHeader()
        positionField()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func positionHeader() {
        view.addSubview(headerLabel)
        
        let guide = view.safeAreaLayoutGuide
        headerLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
    }
    
    private func positionField() {
        view.addSubview(amountField)
        
        let guide = view.safeAreaLayoutGuide
        amountField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 3 * Constants.GRID_SIZE).isActive = true
        amountField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -2 * Constants.GRID_SIZE).isActive = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
