//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 12/12/2023.
//

import Foundation
import Fluent
import Vapor

final class User: Model, Content, Validatable {
    static let schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.email, customFailureDescription: "Username Can not be empty")
        validations.add("password", as: String.self, is: !.empty, required: true, customFailureDescription: "Password Can not be empty")
        validations.add("password", as: String.self, is: .count(6...24), customFailureDescription: "Password most be between 6 to 24 characters")
    }
    
}
