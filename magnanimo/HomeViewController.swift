//
//  HomeViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import PassKit
import Stripe

class HomeViewController: UIViewController {

    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var subgreetingLabel: UILabel!
    @IBOutlet var dollarAmount: UILabel!
    @IBOutlet var centAmount: UILabel!
    
    let SIZE_FACTOR: CGFloat = 2.3
    var data: [[String: NSObject]]?
    
    var selectedOrganization: Organization?
    var selectedCategory: Category?
    
    let applePayButton: PKPaymentButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(OrganizationCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeGreeting()
        initializeData()
        initializePayment()
    }
    
    func initializeGreeting() {
        let displayName = (Auth.auth().currentUser?.displayName)!
        let firstName = String(displayName.split(separator: " ").first!)
        self.greetingLabel.text = "Hello, \(firstName)."
    }
    
    func initializePayment() {
        view.addSubview(applePayButton)
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.isEnabled = Stripe.deviceSupportsApplePay()
        applePayButton.topAnchor.constraint(equalTo: dollarAmount.bottomAnchor, constant: 15).isActive = true
        applePayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
    }
    
    func initializeData() {
        let db = Firestore.firestore()
        db.collection("organizations").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting organizations: \(err)")
            } else {
                let organizations = querySnapshot!.documents.map({ doc in Organization(map: doc.data()) })
                db.collection("categories").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting categories: \(err)")
                    } else {
                        let categories = Dictionary(uniqueKeysWithValues: querySnapshot!.documents.map({ doc in (doc.documentID, Category(map: doc.data())) }))
                        self.data = organizations.map({ org in ["organization": org, "category": categories[org.categoryId]!] })
                        self.initializeOrganizations()
                    }
                }
            }
        }
    }

    func initializeOrganizations() {
        self.view.addSubview(collectionView)
        let guide = view.safeAreaLayoutGuide
        collectionView.backgroundColor = UIColor.Blueprint.Util.Transparent
        collectionView.topAnchor.constraint(equalTo: dollarAmount.bottomAnchor, constant: 40).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
}

extension HomeViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Use Stripe to charge the user
        STPAPIClient.shared().createToken(with: payment) { (stripeToken, error) in
            guard error == nil, let stripeToken = stripeToken else {
                print(error!)
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
                    "amount": 500,
                    "currency": "USD"
                ])
            
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss the Apple Pay UI
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleApplePayButtonTapped(sender: UIButton!) {
        // Cards that should be accepted
        let paymentNetworks:[PKPaymentNetwork] = [.amex,.masterCard,.visa]
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            
            request.merchantIdentifier = "merchant.com.magnanimo"
            request.countryCode = "US"
            request.currencyCode = "USD"
            request.supportedNetworks = paymentNetworks
            // This is based on using Stripe
            request.merchantCapabilities = .capability3DS
            
            let tshirt = PKPaymentSummaryItem(label: "T-shirt", amount: NSDecimalNumber(decimal: 4.00), type: .final)
            let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(decimal: 1.00), type: .final)
            let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(decimal: 5.00), type: .final)
            request.paymentSummaryItems = [tshirt, tax, total]
            
            let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
            
            if let viewController = authorizationViewController {
                viewController.delegate = self
                
                present(viewController, animated: true, completion: nil)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 50, height: collectionView.frame.height - 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OrganizationCell
        cell.organization = self.data?[indexPath.row]["organization"] as? Organization
        cell.category = self.data?[indexPath.row]["category"] as? Category
        cell.showButton.addTarget(self, action: #selector(handleShowButtonTapped), for: .touchUpInside)

        return cell
    }
    
    @objc func handleShowButtonTapped(sender: ShowOrganizationButton!) {
        let organization = sender.organization
        let category = sender.category
        print("Selecting organization: " + organization.debugDescription)
        self.selectedOrganization = organization
        self.selectedCategory = category
        performSegue(withIdentifier: "showOrganization", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOrganization" {
            if let destinationVC = segue.destination as? OrganizationViewController {
                destinationVC.organization = self.selectedOrganization
                destinationVC.category = self.selectedCategory
            }
        }
    }
    
}

class ShowOrganizationButton: UIButton {
    var organization: Organization?
    var category: Category?
}

class OrganizationCell: UICollectionViewCell {
    var organization: Organization? {
        didSet {
            guard let organization = organization else { return }
            titleLabel.text = organization.name
            descriptionLabel.text = organization.desc
            showButton.organization = organization
        }
    }
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            let attributedString = NSMutableAttributedString(string: category.name.uppercased())
            attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.4), range: NSRange(location: 0, length: category.name.count))
            categoryLabel.attributedText = attributedString
            categoryLabel.layer.backgroundColor = category.baseColor.withAlphaComponent(0.15).cgColor
            categoryLabel.textColor = category.accentColor
            
            showButton.setTitleColor(category.accentColor, for: .normal)
            showButton.layer.backgroundColor = category.baseColor.withAlphaComponent(0.15).cgColor
            showButton.category = category
        }
    }
    
    fileprivate let titleLabel = MagnanimoLabel(type: .Title)
    fileprivate let descriptionLabel = MagnanimoLabel(type: .Text)
    fileprivate let categoryLabel = TagLabel()
    
    fileprivate let showButton: ShowOrganizationButton = {
        let button = ShowOrganizationButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // set text
        button.setTitle(">", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        
        // format layer
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // make interactive
        self.contentView.isUserInteractionEnabled = false
        
        // position button
        self.addSubview(showButton)
        showButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        showButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        // round corners and add shadows
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.opacity = 0.9
        self.contentView.layer.cornerRadius = 4
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

        // position titleLabel
        contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        // position categoryLabel
        contentView.addSubview(categoryLabel)
        categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        
        // position descriptionLabel
        contentView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
