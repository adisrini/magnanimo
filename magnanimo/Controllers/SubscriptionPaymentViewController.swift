//
//  SubscriptionPaymentViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/18/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit
import PassKit
import Stripe

class SubscriptionPaymentViewController: MagnanimoViewController {
    
    let FREQUENCY_OPTIONS = [
        "day",
        "week",
        "month",
        "year"
    ]
    
    var organization: Organization?
    var subscription: StripeSubscription?
    
    var selectedFrequency: String?
    
    fileprivate let headerLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.text = "Manage your subscription"
        
        return label
    }()
    
    fileprivate let closeButton: UIButton = {
        let button = MagnanimoCloseButton()
        button.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let amountField = MagnanimoCurrencyField()
    
    fileprivate let frequencyLabel: UILabel = {
        let label = MagnanimoLabel(type: .Text)
        label.text = "per"
        
        return label
    }()
    
    fileprivate let frequencyTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    fileprivate let frequencyPicker: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
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
        positionPicker()
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
    
    private func positionPicker() {
        view.addSubview(frequencyLabel)
        view.addSubview(frequencyTextField)
        
        frequencyTextField.text = FREQUENCY_OPTIONS[0]
        frequencyTextField.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 2 * Constants.GRID_SIZE).isActive = true
        frequencyTextField.trailingAnchor.constraint(equalTo: amountField.trailingAnchor).isActive = true
        
        frequencyLabel.centerYAnchor.constraint(equalTo: frequencyTextField.centerYAnchor).isActive = true
        frequencyLabel.trailingAnchor.constraint(equalTo: frequencyTextField.leadingAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        frequencyTextField.inputView = frequencyPicker
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
    }
    
    private func positionSwitch() {
        view.addSubview(publicLabel)
        view.addSubview(publicSwitch)
        
        publicSwitch.topAnchor.constraint(equalTo: frequencyTextField.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
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

extension SubscriptionPaymentViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return FREQUENCY_OPTIONS.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return FREQUENCY_OPTIONS[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFrequency = FREQUENCY_OPTIONS[row]
        frequencyTextField.text = selectedFrequency
    }
    
    
}

extension SubscriptionPaymentViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Use Stripe to charge the user
        STPAPIClient.shared().createSource(with: payment) { (source, error) in
            guard error == nil, let interval = self.selectedFrequency, let organization = self.organization, let s = source, s.flow == .none, s.status == .chargeable else {
                print(error!)
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error!]))
                return
            }
            
            let source = s.stripeID
            
            // Create subscription
            MagnanimoClient.createSubscription(
                source: source,
                amount: self.amountField.decimal * 100,
                currency: "usd",
                interval: interval,
                isPublic: self.publicSwitch.isOn,
                productId: organization.productId,
                organizationId: organization.id,
                failure: { err in
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    Toast.make(self.view, err, .Danger)
            },
                success: { subscription in
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    Functions.setTimeout(millis: 1000, action: self.unwindToOrganization)
            }
            )
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
