//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 19/12/2023.
//

import Foundation
import Vapor
import GoGrocerySharedDTO

extension RegisterResponceDTO: Content {
    
}

extension LoginResponceDTO: Content {
    
}

extension GroceryCategoryResponseDTO: Content {
    init?(_ groceryCategory: GroceryCategory) {
        guard let userId = groceryCategory.id else {
            return nil
        }
        self.init(id: userId, title: groceryCategory.title, colorCode: groceryCategory.colorCode)
    }
}

extension GroceryCategoryRequestDTO: Content {
    
}
