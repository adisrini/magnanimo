//
//  OrganizationViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/13/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit

class OrganizationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let impact = UIImpactFeedbackGenerator()
    
    var historicalCharges: Array<StripeCharge>?
    var existingSubscription: StripeSubscription? {
        didSet {
            let _ = subscribeDonateButton
                .withTitleAndSubtitle(title: "Subscribed", subtitle: "You've subscribed.")
                .withIcon(Constants.SUBSCRIBED_ICON)
                .withPalette(palette: UIColor.Blueprint.Green)
        }
    }
    
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
    
    fileprivate let titleLabel: UILabel = {
        let label = MagnanimoLabel(type: .Title)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate let categoryLabel = MagnanimoTag()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = MagnanimoLabel(type: .Text)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate let closeButton: UIButton = {
        let button = MagnanimoCloseButton()
        button.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = UIColor.Magnanimo.Background
        sv.isExclusiveTouch = false
        sv.delaysContentTouches = false

        return sv
    }()
    
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let donateLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.text = "Donate"
        return label
    }()
    
    fileprivate let oneTimeDonateButton: MagnanimoButton = {
        let button = MagnanimoButton()
            .withTitleAndSubtitle(title: "One-time", subtitle: "Make a single payment.")
            .withShadowType(type: .Small)
            .withIcon(Constants.ONE_TIME_ICON)

        button.addTarget(self, action: #selector(handleOneTimeDonateButtonTapped), for: .touchUpInside)

        return button
    }()
    
    fileprivate var subscribeDonateButton: MagnanimoButton = {
        let button = MagnanimoButton()
            .withTitleAndSubtitle(title: "Subscribe", subtitle: "Schedule payments to repeat.")
            .withShadowType(type: .Small)
            .withIcon(Constants.SUBSCRIBE_ICON)
        button.addTarget(self, action: #selector(handleSubscribeDonateButtonTapped), for: .touchUpInside)
        button.isSkeletonable = true
        
        return button
    }()
    
    fileprivate let historyLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.text = "Your History"
        return label
    }()
    
    fileprivate let historicalAmountLabel: UILabel = {
        let label = MagnanimoLabel(type: .Header)
        label.font = UIFont.Magnanimo.Money
        label.textColor = UIColor.Magnanimo.Money
        label.text = "$0.00"
        label.isSkeletonable = true
        return label
    }()
    
    fileprivate let historyTable: UITableView = {
        let table = MagnanimoChargeTableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MagnanimoChargeTableViewCell.self, forCellReuseIdentifier: MagnanimoChargeTableViewCell.ID)
        table.rowHeight = UITableView.automaticDimension;
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(titleLabel)
        view.addSubview(categoryLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(closeButton)
        view.addSubview(scrollView)

        scrollView.addSubview(containerView)
        
        containerView.addSubview(donateLabel)
        scrollView.addSubview(oneTimeDonateButton)
        scrollView.addSubview(subscribeDonateButton)
        containerView.addSubview(historyLabel)
        containerView.addSubview(historicalAmountLabel)
        containerView.addSubview(historyTable)

        positionTitle()
        positionCategoryLabel()
        positionDescription()
        positionCloseButton()
        positionScrollView()
        positionDonateSection()
        positionHistorySection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadSubscription()
        loadHistory()
    }
    
    // MARK: - Positioning

    private func positionTitle() {
        let guide = view.safeAreaLayoutGuide
        titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.GRID_SIZE).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -Constants.GRID_SIZE).isActive = true
    }
    
    private func positionCategoryLabel() {
        categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
    }
    
    private func positionCloseButton() {
        let guide = view.safeAreaLayoutGuide
        closeButton.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.GRID_SIZE).isActive = true
    }
    
    private func positionDescription() {
        descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor).isActive = true
    }
    
    private func positionScrollView() {
        let guide = view.safeAreaLayoutGuide
        scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    private func positionDonateSection() {
        donateLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.GRID_SIZE).isActive = true
        donateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        oneTimeDonateButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        oneTimeDonateButton.topAnchor.constraint(equalTo: donateLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        subscribeDonateButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        subscribeDonateButton.topAnchor.constraint(equalTo: oneTimeDonateButton.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
    }
    
    private func positionHistorySection() {
        historyLabel.topAnchor.constraint(equalTo: subscribeDonateButton.bottomAnchor, constant: 2 * Constants.GRID_SIZE).isActive = true
        historyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        
        historicalAmountLabel.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        historicalAmountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        
        historyTable.topAnchor.constraint(equalTo: historicalAmountLabel.bottomAnchor, constant: Constants.GRID_SIZE).isActive = true
        historyTable.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        historyTable.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor).isActive = true
        historyTable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.GRID_SIZE).isActive = true
        
        historyTable.delegate = self
        historyTable.dataSource = self
    }
    
    // MARK: - Data loading
    
    private func loadSubscription() {
        if let organization = organization {
            subscribeDonateButton.showAnimatedGradientSkeleton()
            MagnanimoClient.getSubscriptionForOrganization(
                organizationId: organization.id,
                failure: { s in print(s) },
                success: { subscription in
                    self.subscribeDonateButton.hideSkeleton()
                    if let sub = subscription {
                        self.existingSubscription = sub
                    }
                }
            )
        }
    }

    private func loadHistory() {
        historicalAmountLabel.showAnimatedGradientSkeleton()
        if let organization = organization {
            MagnanimoClient.getUserChargesForOrganization(
                organizationId: organization.id,
                failure: { _ in },
                success: { charges in
                    self.historicalCharges = charges
                    var totalAmount: Double = 0
                    for charge in charges {
                        totalAmount += charge.amount
                    }
                    self.historicalAmountLabel.hideSkeleton()
                    self.historicalAmountLabel.text = Formatter.currency.string(from: NSNumber(value: totalAmount / 100))
                    self.historyTable.reloadData()
                }
            )
        }
    }
    
    // MARK: - Button handlers

    @objc func handleCloseButtonTapped() {
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    @objc func handleOneTimeDonateButtonTapped() {
        impact.impactOccurred()
        performSegue(withIdentifier: "showOneTimePayment", sender: self)
    }
    
    @objc func handleSubscribeDonateButtonTapped() {
        impact.impactOccurred()
        performSegue(withIdentifier: "showSubscriptionPayment", sender: self)
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOneTimePayment" {
            if let destinationVC = segue.destination as? OneTimePaymentViewController {
                destinationVC.organization = self.organization
            }
        } else if segue.identifier == "showSubscriptionPayment" {
            if let destinationVC = segue.destination as? SubscriptionPaymentViewController {
                destinationVC.organization = self.organization
                destinationVC.subscription = self.existingSubscription
            }
        }
    }
    
    @IBAction func unwindToOrganization(segue: UIStoryboardSegue) {}

    
    // MARK: - TableView functions

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historicalCharges?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagnanimoChargeTableViewCell.ID, for: indexPath) as! MagnanimoChargeTableViewCell
        
        if let charges = historicalCharges {
            let charge = charges[indexPath.row]
            cell.charge = charge
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.GRID_SIZE * 4
    }
}
