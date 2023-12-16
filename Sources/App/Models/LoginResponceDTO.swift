//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 15/12/2023.
//

import Foundation
import Vapor

struct LoginResponceDTO: Content {
    let error: Bool
    let reason: String?
    let token: String?
    let userId: UUID
}
