//
//  ViewController.swift
//  Login_App_Anime
//
//  Created by Tardes on 5/2/26.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    @IBAction func singUp(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        
        
        Auth.auth().createUser(withEmail: username, password: password) {[unowned self]  authResult, error in
          // ...
            if let error = error  {
                print ("Error creating user \(error.localizedDescription)")
                return
            }
            
            print ("Account created sucessfully")
        }
    }

    
    @IBAction func singIn(_ sender: Any) {
        
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: username, password: password) { [unowned self] authResult, error in
            if let error = error  {
            print ("Error creating user \(error.localizedDescription)")
            return
        }
        
        print ("SING IN sucessfully")
            
            performSegue(withIdentifier: "NavigateToHome", sender: nil)
            
        }
        }
    }


