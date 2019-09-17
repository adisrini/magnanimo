//
//  OneTimePaymentViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/16/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import PassKit
import Stripe

class OneTimePaymentViewController: UIViewController {
    
    var organization: Organization?
    
    fileprivate let headerLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.text = "Enter your amount"
        
        return label
    }()
    
    fileprivate let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("X", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let amountField = MagnanimoCurrencyField()
    
    fileprivate let publicLabel: UILabel = {
        let label = MagnanimoLabel(type: .Text)
        label.text = "Make public"
        
        return label
    }()
    
    fileprivate let publicSwitch: UISwitch = {
        let uiSwitch = UISwitch(frame: .zero)
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.isOn = true

        return uiSwitch
    }()
    
    fileprivate let applePayButton: PKPaymentButton = PKPaymentButton(paymentButtonType: .donate, paymentButtonStyle: .black)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        positionHeader()
        positionField()
        positionSwitch()
        positionPayment()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func positionHeader() {
        view.addSubview(headerLabel)
        view.addSubview(closeButton)
        
        let guide = view.safeAreaLayoutGuide
        headerLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        closeButton.topAnchor.constraint(equalTo: headerLabel.topAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
    }
    
    private func positionField() {
        view.addSubview(amountField)
        
        amountField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 3 * Constants.GRID_SIZE).isActive = true
        amountField.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor).isActive = true
    }
    
    private func positionSwitch() {
        view.addSubview(publicLabel)
        view.addSubview(publicSwitch)
        
        publicSwitch.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 2 * Constants.GRID_SIZE).isActive = true
        publicSwitch.trailingAnchor.constraint(equalTo: amountField.trailingAnchor).isActive = true
        
        publicLabel.centerYAnchor.constraint(equalTo: publicSwitch.centerYAnchor).isActive = true
        publicLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor).isActive = true
    }
    
    private func positionPayment() {
        view.addSubview(applePayButton)
        applePayButton.translatesAutoresizingMaskIntoConstraints = false

        applePayButton.isEnabled = Stripe.deviceSupportsApplePay()
        applePayButton.topAnchor.constraint(equalTo: publicSwitch.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        applePayButton.trailingAnchor.constraint(equalTo: publicSwitch.trailingAnchor).isActive = true
        applePayButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor).isActive = true
        applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
    }
    
    @objc func handleCloseButtonTapped() {
        unwindToOrganization()
    }
    
    private func unwindToOrganization() {
        performSegue(withIdentifier: "unwindToOrganization", sender: self)
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

extension OneTimePaymentViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Use Stripe to charge the user
        STPAPIClient.shared().createToken(with: payment) { (stripeToken, error) in
            guard error == nil, let organization = self.organization, let stripeToken = stripeToken else {
                print(error!)
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error!]))
                return
            }
            
            let token = stripeToken.tokenId
            
            let db = Firestore.firestore()
            let stripeCustomerRef = db.collection("stripe_customers").document((Auth.auth().currentUser?.uid)!)
            
            // Add payment source
            stripeCustomerRef
                .collection("tokens")
                .document(token)
                .setData([
                    "token": token
                    ])
            
            // Create charge
            stripeCustomerRef
                .collection("charges")
                .document(token)
                .setData([
                    "amount": self.amountField.decimal * 100,
                    "type": "one-time",
                    "is_public": self.publicSwitch.isOn,
                    "organization_id": organization.id
                    ])
            
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            self.unwindToOrganization()
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss the Apple Pay UI
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleApplePayButtonTapped(sender: UIButton!) {
        let amount = amountField.decimal
        
        if amount == 0 {
            return
        }

        // Cards that should be accepted
        let paymentNetworks:[PKPaymentNetwork] = [.amex, .masterCard, .visa]
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            
            request.merchantIdentifier = Constants.MERCHANT_ID
            request.countryCode = "US"
            request.currencyCode = "USD"
            request.supportedNetworks = paymentNetworks

            // This is based on using Stripe
            request.merchantCapabilities = .capability3DS
            
            let donation = PKPaymentSummaryItem(label: "Donation to " + organization!.name, amount: NSDecimalNumber(decimal: amount), type: .final)
            let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(decimal: amount), type: .final)

            request.paymentSummaryItems = [donation, total]
            
            let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
            
            if let viewController = authorizationViewController {
                viewController.delegate = self
                
                present(viewController, animated: true, completion: nil)
            }
        }
    }
}
