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

class HomeViewController: UIViewController {

    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var subgreetingLabel: UILabel!
    @IBOutlet var dollarAmount: UILabel!
    @IBOutlet var centAmount: UILabel!
    
    let SIZE_FACTOR: CGFloat = 2.3
    
    var data: [[String: NSObject]]?
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 50, left: 10, bottom: 50, right: 10)
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
    
    func initializeGreeting() {
        let displayName = (Auth.auth().currentUser?.displayName)!
        let firstName = String(displayName.split(separator: " ").first!)
        self.greetingLabel.text = "Hello, \(firstName)."
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
        collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
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
        return cell
    }
    
    
}

class TagLabel: UILabel {
    
    let inset = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
    
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += self.inset.left + self.inset.right
        intrinsicContentSize.height += self.inset.top + self.inset.bottom
        return intrinsicContentSize
    }
}

class OrganizationCell: UICollectionViewCell {
    var organization: Organization? {
        didSet {
            guard let organization = organization else { return }
            titleLabel.text = organization.name
            descriptionLabel.text = organization.desc
        }
    }
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            categoryLabel.text = category.name
            categoryLabel.layer.backgroundColor = category.color.withAlphaComponent(0.6).cgColor
        }
    }
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.Blueprint.LightGray.LightGray4
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.Blueprint.LightGray.LightGray1
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    fileprivate let categoryLabel: UILabel = {
        let label = TagLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // round corners and add shadows
        self.contentView.backgroundColor = UIColor.Blueprint.DarkGray.DarkGray4
        self.contentView.layer.opacity = 0.9
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 8
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
