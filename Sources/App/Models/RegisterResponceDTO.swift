//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 14/12/2023.
//

import Foundation
import Vapor

struct RegisterResponceDTO: Content {
    let error: Bool
    var reason: String? = nil
}
