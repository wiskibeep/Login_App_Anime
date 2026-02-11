//
//  UserRepositories.swift
//  Login_App_Anime
//
//  Created by Tardes on 11/2/26.
//



import FirebaseFirestore

class UserRepository {
    
    let db = Firestore.firestore()
    
    func create(user: User) throws {
        try db.collection("Users").document(user.id).setData(from: user)
    }
    
    func getUserBy(id: String) async throws -> User? {
        let documentRef = db.collection("Users").document(id)
        
        let document = try await documentRef.getDocument()
        if document.exists {
            return try document.data(as: User.self)
        } else {
            return nil
        }
    }
}
