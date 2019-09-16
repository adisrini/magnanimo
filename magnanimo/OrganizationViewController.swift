//
//  OrganizationViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/13/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class OrganizationViewController: UIViewController {
    
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
            let attributedString = NSMutableAttributedString(string: category.name.uppercased())
            attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.4), range: NSRange(location: 0, length: category.name.count))
            categoryLabel.attributedText = attributedString
            categoryLabel.layer.backgroundColor = category.baseColor.withAlphaComponent(0.15).cgColor
            categoryLabel.textColor = category.accentColor
        }
    }
    
    fileprivate let titleLabel = MagnanimoLabel(type: .Title)
    
    fileprivate let categoryLabel = TagLabel()
    
    fileprivate let descriptionLabel = MagnanimoLabel(type: .Text)
    
    fileprivate let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("X", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let donateLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.text = "Donate"
        return label
    }()
    
    fileprivate let oneTimeDonateButton: UIButton = {
        let button = DonateButton(label: "One-time")
        button.addTarget(self, action: #selector(handleOneTimeDonateButtonTapped), for: .touchUpInside)
        
        return button
    }()

    
    fileprivate let subscribeDonateButton: UIButton = {
        let button = DonateButton(label: "Subscribe")
        button.addTarget(self, action: #selector(handleSubscribeDonateButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let historyLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.text = "Your History"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(titleLabel)
        view.addSubview(categoryLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(closeButton)
        view.addSubview(donateLabel)
        view.addSubview(oneTimeDonateButton)
        view.addSubview(subscribeDonateButton)
        view.addSubview(historyLabel)

        positionTitle()
        positionCategoryLabel()
        positionDescription()
        positionCloseButton()
        positionDonateSection()
        positionHistoryLabel()
    }
    
    func positionTitle() {
        let guide = view.safeAreaLayoutGuide
        titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20).isActive = true
    }
    
    func positionCategoryLabel() {
        let guide = view.safeAreaLayoutGuide
        categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        categoryLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
    }
    
    func positionDescription() {
        let guide = view.safeAreaLayoutGuide
        descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
    }
    
    func positionCloseButton() {
        let guide = view.safeAreaLayoutGuide
        closeButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
    }
    
    func positionDonateSection() {
        let guide = view.safeAreaLayoutGuide
        donateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40).isActive = true
        donateLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        oneTimeDonateButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        oneTimeDonateButton.topAnchor.constraint(equalTo: donateLabel.bottomAnchor, constant: 20).isActive = true
        subscribeDonateButton.leadingAnchor.constraint(equalTo: oneTimeDonateButton.trailingAnchor, constant: 20).isActive = true
        subscribeDonateButton.topAnchor.constraint(equalTo: donateLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    func positionHistoryLabel() {
        let guide = view.safeAreaLayoutGuide
        historyLabel.topAnchor.constraint(equalTo: oneTimeDonateButton.bottomAnchor, constant: 40).isActive = true
        historyLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
    }
    
    @objc func handleCloseButtonTapped() {
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    @objc func handleOneTimeDonateButtonTapped() {
        print("One-time")
    }
    
    @objc func handleSubscribeDonateButtonTapped() {
        print("Subscribe")
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

class DonateButton: UIButton {
    
    let inset = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
    
    init(label: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(label, for: .normal)

        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        // change layer
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
        self.layer.cornerRadius = Constants.CORNER_RADIUS
        
        // colors
        self.layer.backgroundColor = UIColor.white.cgColor
        self.setTitleColor(UIColor.Blueprint.DarkGray.DarkGray1, for: .normal)
        
        // padding
        self.titleEdgeInsets = inset
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += self.inset.left + self.inset.right
        intrinsicContentSize.height += self.inset.top + self.inset.bottom
        return intrinsicContentSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
