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
    
    fileprivate let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.Blueprint.DarkGray.DarkGray1
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        return titleLabel
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = UIColor.Blueprint.DarkGray.DarkGray5
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        
        return descriptionLabel
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(closeButton)

        positionTitle()
        positionDescription()
        positionCloseButton()
    }
    
    func positionTitle() {
        let guide = view.safeAreaLayoutGuide
        titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20).isActive = true
    }
    
    func positionDescription() {
        let guide = view.safeAreaLayoutGuide
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
    }
    
    func positionCloseButton() {
        let guide = view.safeAreaLayoutGuide
        closeButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
    }
    
    @objc func handleCloseButtonTapped() {
        performSegue(withIdentifier: "unwindToHome", sender: self)
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
