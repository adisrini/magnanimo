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
    
    let INTERVAL_OPTIONS = [
        "day",
        "week",
        "month",
        "year"
    ]
    
    var organization: Organization?
    var subscription: StripeSubscription? {
        didSet {
            guard let subscription = subscription else { return }
            amountField.text = Formatter.currency.string(for: subscription.amount / 100)
            publicSwitch.isOn = subscription.isPublic
            selectedInterval = subscription.interval
            selectedIntervalCount = subscription.intervalCount
        }
    }
    
    var selectedInterval: String? {
        didSet {
            guard let interval = selectedInterval, let count = selectedIntervalCount else { return }
            frequencyTextField.text = count > 1 ? interval + "s" : interval
        }
    }

    var selectedIntervalCount: Int? {
        didSet {
            guard let interval = selectedInterval, let count = selectedIntervalCount else { return }
            frequencyCountTextField.text = String(count)
            frequencyTextField.text = count > 1 ? interval + "s" : interval
        }
    }
    
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
        label.text = "every"
        
        return label
    }()
    
    fileprivate let frequencyCountTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    fileprivate let frequencyTextField: UITextField = {
        let field = UITextField(frame: .zero)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    fileprivate let frequencyCountPicker: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
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
    
    fileprivate let applePayButton: PKPaymentButton = PKPaymentButton(paymentButtonType: .subscribe, paymentButtonStyle: .black)
    
    fileprivate let cancelButton: MagnanimoButton = MagnanimoButton()
        .withTitle(title: "Cancel")
        .withIcon(Constants.CANCEL_ICON)
        .withPalette(palette: UIColor.Blueprint.Red)
        .withShadowType(type: .Small)
        .isLoadable()
    
    fileprivate let saveButton: MagnanimoButton = MagnanimoButton()
        .withTitle(title: "Update")
        .withIcon(Constants.SAVE_ICON)
        .withShadowType(type: .Small)
        .isLoadable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        positionHeader()
        positionField()
        positionPicker()
        positionSwitch()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        positionActions(subscription: self.subscription)
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
        view.addSubview(frequencyCountTextField)
        
        frequencyTextField.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 2 * Constants.GRID_SIZE).isActive = true
        frequencyTextField.trailingAnchor.constraint(equalTo: amountField.trailingAnchor).isActive = true
        
        frequencyCountTextField.topAnchor.constraint(equalTo: frequencyTextField.topAnchor).isActive = true
        frequencyCountTextField.trailingAnchor.constraint(equalTo: frequencyTextField.leadingAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        frequencyLabel.centerYAnchor.constraint(equalTo: frequencyTextField.centerYAnchor).isActive = true
        frequencyLabel.trailingAnchor.constraint(equalTo: frequencyCountTextField.leadingAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        frequencyTextField.inputView = frequencyPicker
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
        
        frequencyCountTextField.inputView = frequencyCountPicker
        frequencyCountPicker.dataSource = self
        frequencyCountPicker.delegate = self
        
        selectedInterval = INTERVAL_OPTIONS[0]
        selectedIntervalCount = 1
    }
    
    private func positionSwitch() {
        view.addSubview(publicLabel)
        view.addSubview(publicSwitch)
        
        publicSwitch.topAnchor.constraint(equalTo: frequencyTextField.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        publicSwitch.trailingAnchor.constraint(equalTo: amountField.trailingAnchor).isActive = true
        
        publicLabel.centerYAnchor.constraint(equalTo: publicSwitch.centerYAnchor).isActive = true
        publicLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor).isActive = true
    }
    
    private func positionActions(subscription: StripeSubscription?) {
        if let subscription = subscription {
            view.addSubview(cancelButton)
            view.addSubview(saveButton)
            
            cancelButton.topAnchor.constraint(equalTo: publicSwitch.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
            cancelButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor).isActive = true
            cancelButton.addTarget(self, action: #selector(handleCancelButtonTapped), for: .touchUpInside)
            
            saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
            saveButton.trailingAnchor.constraint(equalTo: publicSwitch.trailingAnchor).isActive = true
            saveButton.addTarget(self, action: #selector(handleSaveButtonTapped), for: .touchUpInside)
            
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
            
            let count = subscription.intervalCount
            let interval = subscription.interval
            frequencyTextField.text = count > 1 ? interval + "s" : interval
            frequencyCountTextField.text = String(count)
        } else {
            view.addSubview(applePayButton)
            applePayButton.translatesAutoresizingMaskIntoConstraints = false
            
            applePayButton.isEnabled = Stripe.deviceSupportsApplePay()
            applePayButton.topAnchor.constraint(equalTo: publicSwitch.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
            applePayButton.trailingAnchor.constraint(equalTo: publicSwitch.trailingAnchor).isActive = true
            applePayButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor).isActive = true
            applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func handleCancelButtonTapped() {
        if let subscription = self.subscription {
            cancelButton.showLoading()
            MagnanimoClient.deleteSubscription(
                id: subscription.id,
                failure: { err in
                    self.cancelButton.hideLoading()
                    Toast.make(self.view, err, .Danger)
                },
                success: { subscription in
                    self.cancelButton.hideLoading()
                    Toast.make(self.view, "Subscription cancelled", .None)
                    Functions.setTimeout(millis: 1000, action: self.unwindToOrganization)
                }
            )
        }
    }
    
    @objc func handleSaveButtonTapped() {
        // update subscription
        if let organization = self.organization, let interval = self.selectedInterval, let intervalCount = self.selectedIntervalCount, let subscription = self.subscription {
            saveButton.showLoading()
            MagnanimoClient.updateSubscription(
                id: subscription.id,
                amount: self.amountField.decimal * 100,
                currency: "usd",
                interval: interval,
                intervalCount: intervalCount,
                isPublic: self.publicSwitch.isOn,
                productId: organization.productId,
                failure: { err in
                    self.saveButton.hideLoading()
                    Toast.make(self.view, err, .Danger)
                },
                success: { subscription in
                    self.saveButton.hideLoading()
                    Toast.make(self.view, "Subscription updated", .Success)
                    Functions.setTimeout(millis: 1000, action: self.unwindToOrganization)
                }
            )
        }
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
        switch pickerView {
        case frequencyPicker:
            return INTERVAL_OPTIONS.count
        case frequencyCountPicker:
            return frequencyCountOptions()
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case frequencyPicker:
            return INTERVAL_OPTIONS[row]
        case frequencyCountPicker:
            return String(row + 1)
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case frequencyPicker:
            selectedInterval = INTERVAL_OPTIONS[row]
            selectedIntervalCount = 1
        case frequencyCountPicker:
            selectedIntervalCount = row + 1
        default:
            return
        }
    }
    
    private func frequencyCountOptions() -> Int {
        if selectedInterval == "year" {
            return 1
        } else if selectedInterval == "month" {
            return 12
        } else if selectedInterval == "week" {
            return 52
        } else if selectedInterval == "day" {
            return 365
        } else {
            return 0
        }
    }
    
}

extension SubscriptionPaymentViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Use Stripe to charge the user
        STPAPIClient.shared().createSource(with: payment) { (source, error) in
            guard error == nil, let interval = self.selectedInterval, let intervalCount = self.selectedIntervalCount, let organization = self.organization, let s = source, s.flow == .none, s.status == .chargeable else {
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
                intervalCount: intervalCount,
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
