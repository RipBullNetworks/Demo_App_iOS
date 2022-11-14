//
//  AuthManager.swift
//  eRTCApp
//
//  Created by Logan on 06/10/2022.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

import Foundation
import Auth0
import UIKit

@objc
class AuthManager: NSObject {
    static let shared = AuthManager()
    
    @objc class var sharedInstance: AuthManager {
        return AuthManager.shared
    }
    
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication(clientId: Constant.clientId, domain: Constant.domain))
    var user: AuthUser?
    var credentials: Credentials?
    private (set) var userInfo: UserInfo?
    
    private override init() {
        super.init()
    }
    
    
    @objc func isAuthed(_ completion: @escaping (_ error: String?) -> Void) {
        if credentialsManager.hasValid() {
            self.userInfo = credentialsManager.user
            credentialsManager.credentials(callback: { response in
                switch response {
                    case .success(let cred):
                        self.credentials = cred
                        self.storeDataForeRTC()
                        completion(nil)
                    case .failure(let error):
                        print("Fail to load credentials: \(error)")
                        completion(error.errorDescription)
                }
            })
        }else
//            Namespace niravjj1.dev.ertc.com
//            Access Code vuioj54w
//            Username mailto:inapptest1.nrvjj@yopmail.com
//            Password W3kb2k->
        if credentialsManager.canRenew() {
            credentialsManager.credentials { result in
                switch result {
                    case .success(let credentials):
                        // You do not need to call store(credentials:) afterward. The Credentials Manager automatically persists the renewed credentials.
                        self.userInfo = self.credentialsManager.user
                        self.credentials = credentials
                        self.storeDataForeRTC()
                        completion(nil)
                    case .failure(let error):
                        print("Failed with: \(error)")
                        completion(error.errorDescription)
                }
            }
        }else{
            completion(NSString(string: "") as String)
        }
    }
    
    @objc func login(_ completion: @escaping (String?) -> Void) {
        Auth0
            .webAuth(clientId: Constant.clientId,
                     domain: Constant.domain)
            .logging(enabled: true)
            .start { result in
                switch result {
                    case .success(let credentials):
                        self.credentials = credentials
                        self.user = AuthUser(from: credentials.idToken)
                        safePrint("Saving geteRTCUserID: ", self.geteRTCUserID())
                        self.storeDataForeRTC()
                        self.storeToKeychain(credentials)
                        completion(nil)
                    case .failure(let error):
                        print("Failed with: \(error)")
                        completion(error.debugDescription)
                }
            }
    }//please use this email : mailto:d.bol1986@yahoo.com
    
    @objc func loadUserInfo() {
        guard let credentials = credentials else {
            return
        }

        Auth0
            .authentication()
            .userInfo(withAccessToken: credentials.accessToken)
            .start { result in
                switch result {
                    case .success(let user):
                        print("Obtained user: \(user)")
                        self.userInfo = user
                    case .failure(let error):
                        print("Failed with: \(error)")
                }
            }
    }
    
    @objc func getEmail() -> String {
        return userInfo?.email ?? user?.email ?? ""
    }
    
    @objc func getID() -> String {
        return user?.id ?? ""
    }
    
    @objc func geteRTCUserID() -> String {
        let eRTCID = String((user?.id ?? "").split(separator: "|").last ?? "")
        return eRTCID
    }
    
    @objc func getIdToken() -> String {
        return credentials?.idToken ?? ""
    }
    
    @discardableResult
    @objc func logout() -> Bool {
        let didClear = credentialsManager.clear()
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
        }
        return didClear
    }
    
    @discardableResult
    private func storeToKeychain(_ credentials: Credentials?) -> Bool {
        if let credentials = credentials {
            let didStore = credentialsManager.store(credentials: credentials)
            storeDataForeRTC()
            return didStore
        }
        return false
    }
    
    private func storeDataForeRTC() {
        safePrint("Saving geteRTCUserID: ", self.geteRTCUserID())

        // Id Token from Auth0
        UserDefaults.standard.set(self.getIdToken(), forKey: "chatAccess_token")
        UserDefaults.standard.set(self.getIdToken(), forKey: "userAccess_token")
        UserDefaults.standard.set(self.getIdToken(), forKey: "userAccessRefresh_token")
        
        // UserId from Auth0
        UserDefaults.standard.set(self.geteRTCUserID(), forKey: "baseLoginUserId")
        UserDefaults.standard.set(self.geteRTCUserID(), forKey: "eRTCUserId")
        UserDefaults.standard.set(self.geteRTCUserID(), forKey: "userId")

        // User Email from Auth0
        UserDefaults.standard.set(self.getEmail(), forKey: "appUserId")
        
        UserDefaults.standard.synchronize()
    }
}

