//
//  InAppChatWebServices.swift
//  eRTCApp
//
//  Created by Logan on 20/10/2022.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

import Foundation

extension InAppChatWebServices {
    fileprivate enum Path {
        static let login = "https://global-dev.inappchat.io/v1/tenants/%@/users/auth0/login"
    }
}

@objc
class InAppChatWebServices: NSObject {
    
    static let shared = InAppChatWebServices()
    
    private override init(){
        super.init()
    }
    
    @objc class var sharedInstance: InAppChatWebServices {
        return InAppChatWebServices.shared
    }
    
    @objc func auth0Login(userID: String,
                          userEmail: String,
                          token: String,
                          _ completion: @escaping (_ data: Any) -> Void,
                          _ errorHandler: @escaping (_ error: NSError?) -> Void) {
        let userID = String(userID.split(separator: "|").last ?? "")
        Networking.shared.createRequest(
            String(format: Path.login, userID),
            method: .post,
            token: token,
            parameters: ["appUserId": userEmail])
        .printLog()
        .responseJSON { response in
            switch response.result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    errorHandler(error as NSError)
            }
        }
    }
}
