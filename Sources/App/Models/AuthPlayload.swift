//
//  File.swift
//  
//
//  Created by Mohammad Afshar on 15/12/2023.
//

import Foundation
import JWT
import Vapor

struct AuthPayload: JWTPayload {
    
    typealias Payload = AuthPayload
    
    let subject: SubjectClaim
    let expiration: ExpirationClaim
    
    //custom data in tiken
    let userId: UUID
    
    enum AthPlayload: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case userId = "uid"
    }
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
    
}
