//
//  ProfileViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit
import FacebookCore

class ProfileViewController: UIViewController {
    
    @IBOutlet var profileName: UILabel!
    @IBOutlet var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let accessToken = AccessToken.current {
            let connection = GraphRequestConnection()
            connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "name, picture.type(large)"], tokenString: Optional.some(accessToken.tokenString), version: Optional.none, httpMethod: HTTPMethod.get)) { httpResponse, result, error in
                if let err = error {
                    print(err)
                    return
                }
                if let res = result as? [String: AnyObject] {
                    if let name = res["name"] as? String {
                        self.profileName.text = name
                    }
                    
                    if let picture = res["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
                        self.profileImage.image = try? UIImage(data: Data(contentsOf: URL(string: url)!)) as! UIImage
                    }
                }
            }
            connection.start()
        }
    }
    
    
}
