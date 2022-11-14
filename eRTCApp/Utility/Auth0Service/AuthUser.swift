//
//  AuthUser.swift
//  eRTCApp
//
//  Created by Logan on 06/10/2022.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

import Foundation
import JWTDecode


struct AuthUser {
    let id: String
    let email: String
    let picture: String
}

extension AuthUser {
    init?(from idToken: String) {
        guard let jwt = try? decode(jwt: idToken),
              let id = jwt.subject,
              let email = jwt["email"].string,
              let picture = jwt["picture"].string
        else { return nil }
        print(id)
        print(email)
        print(picture)

        
        self.id = id
        self.email = email
        self.picture = picture
    }
}
