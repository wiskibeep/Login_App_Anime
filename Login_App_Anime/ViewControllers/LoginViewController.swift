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
    
    let userRepository = UserRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Si ya hay usuario autenticado, navega directamente
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "NavigateToHome", sender: nil)
        }
    }

    @IBAction func signIn(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        Task {
            do {
                // Inicia sesión con email y contraseña
                _ = try await Auth.auth().signIn(withEmail: username, password: password)
                performSegue(withIdentifier: "NavigateToHome", sender: nil)
            } catch {
                print(error.localizedDescription)
                // Aquí podrías mostrar un alerta al usuario si quieres
            }
        }
    }

    @IBAction func signInWithGoogle(_ sender: Any) {
        Task {
            do {
                // Configuración de Google Sign-In
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config

                // Presenta el flujo de Google
                let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                    GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let result = result {
                            continuation.resume(returning: result)
                        } else {
                            continuation.resume(throwing: NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown Google Sign-In error"]))
                        }
                    }
                }

                let user = result.user
                guard let idToken = user.idToken?.tokenString else { return }

                // Crea credencial de Firebase y autentica
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                let authResult = try await Auth.auth().signIn(with: credential)

                // Verifica si el usuario existe en tu colección de Firestore; si no, créalo
                let uid = authResult.user.uid
                if try await userRepository.getUserBy(id: uid) == nil {
                    let email = authResult.user.email ?? ""
                    let displayName = authResult.user.displayName ?? ""
                    let nameParts = displayName.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                    let firstName = nameParts.first.map(String.init) ?? ""
                    let lastName = nameParts.count > 1 ? String(nameParts[1]) : ""

                    let userModel = User(
                        id: uid,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        gender: nil,
                        birthdate: nil,
                        photoUrl: authResult.user.photoURL?.absoluteString
                    )
                    try userRepository.create(user: userModel)
                }

                performSegue(withIdentifier: "NavigateToHome", sender: nil)
            } catch {
                print(error.localizedDescription)
                // Aquí podrías mostrar un alerta al usuario si quieres
            }
        }
    }
}

