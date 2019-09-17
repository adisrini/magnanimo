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
import SkeletonView

class HomeViewController: UIViewController {
    
    var data: [[String: NSObject]]?
    var totalAmountDonated: Double = 0 {
        didSet {
            self.amountLabel.text = Formatter.currency.string(from: NSNumber(value: self.totalAmountDonated))
        }
    }
    
    var selectedOrganization: Organization?
    var selectedCategory: Category?
    
    fileprivate let greetingLabel = MagnanimoLabel(type: .Header)
    fileprivate let greetingSublabel = MagnanimoLabel(type: .Subtitle)
    fileprivate let amountLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.font = UIFont.Magnanimo.Money
        label.textColor = UIColor.Magnanimo.Money
        label.text = "$0.00"
        return label
    }()
    
    fileprivate let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.GRID_SIZE
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2 * Constants.GRID_SIZE, left: Constants.GRID_SIZE, bottom: 2 * Constants.GRID_SIZE, right: Constants.GRID_SIZE)
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
    }
    
    private func initializeGreeting() {
        let displayName = (Auth.auth().currentUser?.displayName)!
        let firstName = String(displayName.split(separator: " ").first!)
        let subtitle = "It all starts with one small step."
        
        greetingLabel.text = "Hello, \(firstName)."
        greetingSublabel.text = subtitle
        
        view.addSubview(greetingLabel)
        view.addSubview(greetingSublabel)
        view.addSubview(amountLabel)
        
        let guide = view.safeAreaLayoutGuide
        greetingLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        greetingLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        greetingSublabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor).isActive = true
        greetingSublabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        amountLabel.topAnchor.constraint(equalTo: greetingSublabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        amountLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        
        amountLabel.isSkeletonable = true
        amountLabel.showAnimatedGradientSkeleton()
    }
    
    private func initializeData() {
        self.view.addSubview(collectionView)
        let guide = view.safeAreaLayoutGuide
        collectionView.backgroundColor = UIColor.Blueprint.Util.Transparent
        collectionView.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
        db.collection("stripe_customers").document(Auth.auth().currentUser!.uid).collection("charges").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting charges: \(err)")
            } else {
                let charges = querySnapshot!.documents.map({ doc in doc.data() })
                for charge in charges {
                    if charge["error"] == nil {
                        self.totalAmountDonated += charge["amount"] as! Double
                    }
                }
                self.totalAmountDonated /= 100
                self.amountLabel.hideSkeleton()
            }
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cell"
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - (3 * Constants.GRID_SIZE), height: collectionView.frame.height - Constants.GRID_SIZE)
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

class ShowOrganizationButton: MagnanimoButton {
    var organization: Organization? = nil
    var category: Category? = nil
    
    init(title: String, shadowType: MagnanimoButton.MagnanimoButtonShadowType) {
        super.init(attributedTitle: NSAttributedString(string: title), shadowType: shadowType)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OrganizationCell: UICollectionViewCell {
    var organization: Organization? {
        didSet {
            guard let organization = organization else { return }
            titleLabel.text = organization.name
            descriptionLabel.text = organization.desc
            showButton.organization = organization
            self.hideSkeleton()
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
            
            showButton.layer.backgroundColor = category.baseColor.withAlphaComponent(0.15).cgColor
            showButton.category = category
        }
    }
    
    fileprivate let titleLabel = MagnanimoLabel(type: .Title)
    fileprivate let descriptionLabel = MagnanimoLabel(type: .Text)
    fileprivate let categoryLabel = MagnanimoTag()
    
    fileprivate let showButton = ShowOrganizationButton(title: "View", shadowType: .Medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // make interactive
        self.contentView.isUserInteractionEnabled = false
        self.isSkeletonable = true
        
        // position button
        self.addSubview(showButton)
        showButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.GRID_SIZE).isActive = true
        showButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        showButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        // round corners and add shadows
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.opacity = 0.9
        self.contentView.layer.cornerRadius = Constants.CORNER_RADIUS
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

        // position titleLabel
        contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        // position categoryLabel
        contentView.addSubview(categoryLabel)
        categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        
        // position descriptionLabel
        contentView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        self.showAnimatedGradientSkeleton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
