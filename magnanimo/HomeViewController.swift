//
//  HomeViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit
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
        cv.register(OrganizationCell.self, forCellWithReuseIdentifier: "organizationCell")
        cv.register(LastCell.self, forCellWithReuseIdentifier: "lastCell")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeGreeting()
        initializeOrganizations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAmountDonated()
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
    
    private func initializeOrganizations() {
        self.view.addSubview(collectionView)
        let guide = view.safeAreaLayoutGuide
        collectionView.backgroundColor = UIColor.Blueprint.Util.Transparent
        collectionView.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadOrganizations()
    }
    
    private func loadOrganizations() {
        MagnanimoFirebaseClient.getOrganizations() { organizations in
            MagnanimoFirebaseClient.getCategories() { categories in
                let categoriesById = Dictionary(uniqueKeysWithValues: categories.map({ category in (category.id, category) }))
                self.data = organizations.map({ org in ["organization": org, "category": categoriesById[org.categoryId]!] })
                self.collectionView.reloadData()
            }
        }
    }
    
    private func loadAmountDonated() {
        amountLabel.showAnimatedGradientSkeleton()
        self.totalAmountDonated = 0
        
        MagnanimoFirebaseClient.getSuccessfulUserCharges() { charges in
            for charge in charges {
                self.totalAmountDonated += charge.amountInCents
            }
            self.amountLabel.hideSkeleton()
            self.totalAmountDonated /= 100
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - (3 * Constants.GRID_SIZE), height: collectionView.frame.height - Constants.GRID_SIZE)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.data?.count {
            return count + 1
        } else {
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let count = self.data?.count {
            if indexPath.row < count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "organizationCell", for: indexPath) as! OrganizationCell
                cell.organization = self.data?[indexPath.row]["organization"] as? Organization
                cell.category = self.data?[indexPath.row]["category"] as? Category
                cell.showButton.addTarget(self, action: #selector(handleShowButtonTapped), for: .touchUpInside)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lastCell", for: indexPath) as! LastCell
                let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLastCellTapped))
                gesture.numberOfTapsRequired = 1
                cell.contentView.addGestureRecognizer(gesture)
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "organizationCell", for: indexPath) as! OrganizationCell
            return cell
        }
    }
    
    @objc func handleShowButtonTapped(sender: ShowOrganizationButton!) {
        let organization = sender.organization
        let category = sender.category
        print("Selecting organization: " + organization.debugDescription)
        self.selectedOrganization = organization
        self.selectedCategory = category
        performSegue(withIdentifier: "showOrganization", sender: self)
    }
    
    @objc func handleLastCellTapped() {
        tabBarController?.selectedIndex = 1
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
            categoryLabel = categoryLabel.withTextAndColor(text: category.name, baseColor: category.baseColor, accentColor: category.accentColor)
            
            showButton.layer.backgroundColor = category.baseColor.withAlphaComponent(0.15).cgColor
            showButton.category = category
        }
    }
    
    fileprivate let titleLabel = MagnanimoLabel(type: .Title)
    fileprivate let descriptionLabel = MagnanimoLabel(type: .Text)
    fileprivate var categoryLabel = MagnanimoTag()
    
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


class LastCell: UICollectionViewCell {
    fileprivate let lastCellTitleLabel: UILabel = {
        let label = MagnanimoLabel(type: .Title)
        label.text = "Browse all organizations"
        
        return label
    }()
    
    fileprivate let lastCellSubtitleLabel: UILabel = {
        let label = MagnanimoLabel(type: .Subtitle)
        label.text = "Find another cause to support"
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(lastCellTitleLabel)
        contentView.addSubview(lastCellSubtitleLabel)
        contentView.backgroundColor = UIColor.Blueprint.LightGray.LightGray3
        
        lastCellSubtitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        lastCellSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        lastCellSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
        lastCellTitleLabel.bottomAnchor.constraint(equalTo: lastCellSubtitleLabel.topAnchor).isActive = true
        lastCellTitleLabel.leadingAnchor.constraint(equalTo: lastCellSubtitleLabel.leadingAnchor).isActive = true
        lastCellTitleLabel.trailingAnchor.constraint(equalTo: lastCellSubtitleLabel.trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
