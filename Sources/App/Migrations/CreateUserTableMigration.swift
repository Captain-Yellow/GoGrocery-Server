//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 12/12/2023.
//

import Foundation
import Fluent
import FluentPostgresDriver

struct CreateUserTableMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required).unique(on: "username")
            .field("password", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users")
            .delete()
    }
}
