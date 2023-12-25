//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 20/12/2023.
//

import Foundation
import Fluent

final class CreateGroceryCategoryTableMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("grocery_categories")
            .id()
            .field("title", .string, .required)
            .field("color_code", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("grocery_categories")
            .delete()
    }
}
