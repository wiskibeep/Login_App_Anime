//
//  ViewController.swift
//  Login_App_Anime
//
//  Created by Tardes on 5/2/26.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    

    
    
    @IBAction func signIn(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: username, password: password) { [unowned self] authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            print("Sign in successfully")
            performSegue(withIdentifier: "NavigateToHome", sender: nil)
        }
    }
}
