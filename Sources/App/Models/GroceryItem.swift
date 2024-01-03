//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 30/12/2023.
//

import Foundation
import Fluent
import Vapor

final class GroceryItem: Model, Content, Validatable {
    static let schema: String = "grocery_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "quantity")
    var quantity: Int
    
    @Parent(key: "grocery_category_id")
    var groceryCategory: GroceryCategory
    
    init() {    }
    
    init(id: UUID? = nil, title: String, price: Double, quantity: Int, groceryCategoryId: UUID) {
        self.id = id
        self.title = title
        self.price = price
        self.quantity = quantity
        self.$groceryCategory.id = groceryCategoryId
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty, required: true, customFailureDescription: "Item name cann't be Empety")
    }
}
