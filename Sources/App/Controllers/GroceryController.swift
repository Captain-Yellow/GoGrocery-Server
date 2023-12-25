//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 20/12/2023.
//

import Foundation
import Vapor
import Fluent
import GoGrocerySharedDTO

class GroceryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groceryCollection = routes.grouped("users", ":userId")
        
        groceryCollection.post("grocery_categories", use: saveGroceryCategory)
        
        groceryCollection.get("grocery_categories", use: getGroceryCategoriesByUser)
        
        groceryCollection.delete("grocery_categories", ":groceryCategoryId", use: deleteCategory)
    }
    
    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
        
        let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)
        
        try await groceryCategory.save(on: req.db)
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.badRequest)
        }
        
        return groceryCategoryResponseDTO
    }
        
    func getGroceryCategoriesByUser(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()
            .compactMap(GroceryCategoryResponseDTO.init)
    }
    
    func deleteCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self), let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let deletedGroceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
                throw Abort(.notFound)
            }
        
        try await deletedGroceryCategory.delete(on: req.db)
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(deletedGroceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
    }
}
