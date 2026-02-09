//
//  ViewController.swift
//  Login_App_Anime
//
//  Created by Tardes on 5/2/26.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "NavigateToHome", sender: nil)
        }
        
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
    
    @IBAction func signInWithGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            // Sign in on Firebase
            Auth.auth().signIn(with: credential) { [unowned self] authResult, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }
                
                print("Sign in successfully")
                performSegue(withIdentifier: "NavigateToHome", sender: nil)
            }
        }
    }
}
