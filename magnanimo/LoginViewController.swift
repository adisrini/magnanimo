//
//  LoginViewController.swift
//  magnanimo
//
//  Created by Aditya Srinivasan on 9/11/19.
//  Copyright © 2019 Aditya Srinivasan. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = FBLoginButton(permissions: ["public_profile", "email"])
        loginButton.center = view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential, completion: { user, error in
                if let err = error {
                    print("Error signing into Firebase: %@", err)
                    return
                }
                self.performSegue(withIdentifier: "login", sender: self)
            })
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let err = error {
            print(err)
        } else {
            if let res = result {
                if res.isCancelled {
                    print("Login cancelled")
                } else {
                    print("Login successful")
                }
            } else {
                print("No login result")
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out of Firebase: %@", signOutError)
        }
        print("Logged out")
    }
        
}

