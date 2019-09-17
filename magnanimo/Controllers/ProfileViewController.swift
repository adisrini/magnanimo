//
//  ProfileViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit
import FacebookCore
import FirebaseAuth

class ProfileViewController: MagnanimoViewController {
    
    @IBOutlet var profileName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let user = Auth.auth().currentUser {
            profileName.text = user.displayName!
        }
    }
    
    
}
