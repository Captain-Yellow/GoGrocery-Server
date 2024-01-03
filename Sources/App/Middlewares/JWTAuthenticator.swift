//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 03/01/2024.
//

import Foundation
import Vapor

class JWTAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        try request.jwt.verify(as: AuthPayload.self)
    }
}
