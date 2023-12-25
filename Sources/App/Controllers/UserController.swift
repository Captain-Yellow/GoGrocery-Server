//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 13/12/2023.
//

import Foundation
import Fluent
import Vapor
import GoGrocerySharedDTO

class UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userAuthentication = routes.grouped("authentication")
        
        userAuthentication.post("registeration", use: userRegistration)
        
        userAuthentication.post("login", use: userLogin)
    }
    
    func userLogin(req: Request) async throws -> LoginResponceDTO {
        let user = try req.content.decode(User.self)
        
        guard let existedUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
            print("User not Exist.")
            return LoginResponceDTO(error: true, reason: "User not Exist.")
//            throw Abort(.notFound)
        }
        
        let passCheck = try await req.password.async.verify(user.password, created: existedUser.password)
        
        if !passCheck {
            print("Password is Incorrect")
            return LoginResponceDTO(error: true, reason: "Password is Incorrect")
//            throw Abort(.unauthorized)
        }
        
        let res = try AuthPayload(subject: .init(value: "Commen User"), expiration: .init(value: .distantFuture), userId: existedUser.requireID())
        
        return try LoginResponceDTO(error: false, reason: "susseccfully login", token: req.jwt.sign(res), userId: existedUser.requireID())
    }
    
    func userRegistration(req: Request) async throws -> RegisterResponceDTO {
        try User.validate(content: req)
        
        let user = try req.content.decode(User.self)
        
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.conflict, reason: "Username is already taken.")
        }
        
        let hasedPass = try await req.password.async.hash(user.password)
        user.password = hasedPass
        try await user.save(on: req.db)
        
        return RegisterResponceDTO(error: false, reason: "Successfully User Registered")
    }
}
