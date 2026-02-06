//
//  SingUpViewController.swift
//  Login_App_Anime
//
//  Created by Tardes on 6/2/26.
//

import UIKit

import FirebaseAuth


class SingUpViewController: UIViewController {

    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthdateDatePicker: UIDatePicker!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUp(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().createUser(withEmail: username, password: password) { [unowned self] authResult, error in
            if let error = error {
                print("Error creating account: \(error.localizedDescription)")
                return
            }
            
            print("Account created successfully")
        }
    }

    

}
