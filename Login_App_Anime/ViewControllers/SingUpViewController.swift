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
    
    let userRepository = UserRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUp(_ sender: Any) {
        if !validateForm() {
            return
        }
        
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Task { [weak self] in
            guard let self else { return }
            do {
                // Crear usuario en Firebase Auth y obtener uid
                let authResult = try await Auth.auth().createUser(withEmail: username, password: password)
                let userId = authResult.user.uid
                
                // Recoger datos del formulario
                let firstName = firstNameTextField.text ?? ""
                let lastName = lastNameTextField.text ?? ""
                let gender = genderSegmentedControl.selectedSegmentIndex
                
                // Calcular birthdate en milisegundos desde 1970 (sin necesidad de extensión)
                let birthdateMilliseconds = Int64(birthdateDatePicker.date.timeIntervalSince1970 * 1000)
                
                // Construir tu modelo User (el tuyo, Codable)
                let user = User(
                    id: userId,
                    firstName: firstName,
                    lastName: lastName,
                    email: username,
                    gender: gender,
                    birthdate: birthdateMilliseconds,
                    photoUrl: nil
                )
                
                // Guardar en Firestore con tu repositorio
                try userRepository.create(user: user)
                
                // Confirmación opcional
                await MainActor.run {
                    self.showAlert(title: "Cuenta creada", message: "Tu cuenta se creo correctamente.")
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func validateForm() -> Bool {
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let passwordRepeat = passwordRepeatTextField.text ?? ""
        
        if firstName.isEmpty {
            showAlert(title: "Validación", message: "El nombre es obligatorio.")
            return false
        }
        if lastName.isEmpty {
            showAlert(title: "Validación", message: "Los apellidos son obligatorios.")
            return false
        }
        if username.isEmpty {
            showAlert(title: "Validación", message: "El email es obligatorio.")
            return false
        }
        if !username.isValidEmail() {
            showAlert(title: "Validación", message: "El email no tiene un formato válido.")
            return false
        }
        if password.count < 6 {
            showAlert(title: "Validación", message: "La contraseña debe tener al menos 6 caracteres.")
            return false
        }
        if password != passwordRepeat {
            showAlert(title: "Validación", message: "Las contraseñas no coinciden.")
            return false
        }
        return true
    }
    
    private func showAlert(title: String, message: String, actionTitle: String = "Aceptar") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

