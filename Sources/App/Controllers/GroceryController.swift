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
        let groceryCollection = routes.grouped("users", ":userId").grouped(JWTAuthenticator())
        
        groceryCollection.post("grocery_categories", use: saveGroceryCategory)
        
        groceryCollection.get("grocery_categories", use: getGroceryCategoriesByUser)
        
        groceryCollection.delete("grocery_categories", ":groceryCategoryId", use: deleteCategory)
        
        groceryCollection.post("grocery_categories", ":groceryCategoryId", "grocery_items", use: saveGroceryItems)
        
        groceryCollection.get("grocery_categories", ":groceryCategoryId", "grocery_items", use: getGroceryItemsByGroceryCategory)
        
        groceryCollection.delete("grocery_categories", ":groceryCategoryId", "grocery_items", ":itemId", use: deleteItem)
    }
    
    func getGroceryItemsByGroceryCategory(req: Request) async throws -> [GroceryItemResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let categoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.badRequest)
        }
        
        guard let groceryCetegory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == categoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        return try await GroceryItem.query(on: req.db)
            .filter(\.$groceryCategory.$id == groceryCetegory.id!)
            .all()
            .compactMap(GroceryItemResponseDTO.init)
    }
    
    func deleteItem(req: Request) async throws -> GroceryItemResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let categoryId = req.parameters.get("groceryCategoryId", as: UUID.self),
              let itemId = req.parameters.get("itemId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let groceryCetegory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == categoryId)
            .first() else {
                throw Abort(.notFound)
            }
        
        guard let groceryItem = try await GroceryItem.query(on: req.db)
            .filter(\.$groceryCategory.$id == groceryCetegory.id!)
            .filter(\.$id == categoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        try await groceryItem.delete(on: req.db)
        
        guard let deletedItem = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        
        return deletedItem
    }
    
    func saveGroceryItems(req: Request) async throws -> GroceryItemResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
                throw Abort(.notFound)
            }
        
        let groceryItemRequestDTO = try req.content.decode(GroceryItemRequestDTO.self)
        
        let groceyItem = GroceryItem(title: groceryItemRequestDTO.title, price: groceryItemRequestDTO.price, quantity: groceryItemRequestDTO.quantity, groceryCategoryId: groceryCategory.id!)
        
        try await groceyItem.save(on: req.db)
        
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceyItem) else {
            throw Abort(.internalServerError)
        }
        
        return groceryItemResponseDTO
    }
    
    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
        print(groceryCategoryRequestDTO)
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
