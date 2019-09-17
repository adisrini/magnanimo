//
//  OrganizationViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/13/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class OrganizationViewController: UIViewController {
    
    let impact = UIImpactFeedbackGenerator()
    
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
    
    fileprivate let categoryLabel = MagnanimoTag()
    
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
        let button = MagnanimoButton(title: "One-time", subtitle: "Make a single payment.", shadowType: .Small).withIcon("dollar")
        button.addTarget(self, action: #selector(handleOneTimeDonateButtonTapped), for: .touchUpInside)

        return button
    }()

    
    fileprivate let subscribeDonateButton: UIButton = {
        let button = MagnanimoButton(title: "Subscribe", subtitle: "Schedule payments to repeat.", shadowType: .Small).withIcon("clock")
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
    
    private func positionTitle() {
        let guide = view.safeAreaLayoutGuide
        titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -Constants.GRID_SIZE).isActive = true
    }
    
    private func positionCategoryLabel() {
        let guide = view.safeAreaLayoutGuide
        categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        categoryLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
    }
    
    private func positionDescription() {
        let guide = view.safeAreaLayoutGuide
        descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
    }
    
    private func positionCloseButton() {
        let guide = view.safeAreaLayoutGuide
        closeButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
    }
    
    private func positionDonateSection() {
        let guide = view.safeAreaLayoutGuide
        donateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2 * Constants.GRID_SIZE).isActive = true
        donateLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        oneTimeDonateButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        oneTimeDonateButton.topAnchor.constraint(equalTo: donateLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        subscribeDonateButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        subscribeDonateButton.topAnchor.constraint(equalTo: oneTimeDonateButton.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
    }
    
    private func positionHistoryLabel() {
        let guide = view.safeAreaLayoutGuide
        historyLabel.topAnchor.constraint(equalTo: subscribeDonateButton.bottomAnchor, constant: 2 * Constants.GRID_SIZE).isActive = true
        historyLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
    }
    
    @objc func handleCloseButtonTapped() {
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    @objc func handleOneTimeDonateButtonTapped() {
        impact.impactOccurred()
        performSegue(withIdentifier: "showOneTimePayment", sender: self)
    }
    
    @objc func handleSubscribeDonateButtonTapped() {
        impact.impactOccurred()
        print("Subscribe")
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOneTimePayment" {
            if let destinationVC = segue.destination as? OneTimePaymentViewController {
                destinationVC.organization = self.organization
            }
        }
    }
    
    @IBAction func unwindToOrganization(segue: UIStoryboardSegue) {}

}
