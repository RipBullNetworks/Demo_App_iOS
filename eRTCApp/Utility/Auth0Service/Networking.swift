//
//  Networking.swift
//  eRTCApp
//
//  Created by Logan on 19/10/2022.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

import Foundation
import Alamofire

@objc
class Networking: NSObject {
    static let shared = Networking()
    
    private var manager: Alamofire.Session!

    let baseUrl = ""
    
    @objc class var sharedInstance: Networking {
        return Networking.shared
    }
    
    public func url(_ path: String, baseURL: String? = nil) -> String {
        
        if path.contains("http")  {
            return path.replacingOccurrences(of: "http://", with: "https://")
        }
        return (baseURL ?? self.baseUrl) + path
    }
}

extension Networking {
    func createRequest(_ path: String,
                       method: HTTPMethod = .get,
                       token: String? = nil,
                       isLoggingEnable: Bool = true,
                       parameters: [String: Any]? = nil,
                       headers: HTTPHeaders = HTTPHeaders.default,
                       encoding: ParameterEncoding = URLEncoding.default) -> DataRequest {
        var headers: HTTPHeaders = HTTPHeaders()
        
        if let token = token {
            headers.add( .authorization(bearerToken: token))
        }
        headers.add(name: "X-nonce", value: "12345")
        headers.add(name: "X-Request-Signature", value: "82e457bffa31f544c363a060b5f6fd42799b2e8323ae644886d6ec2191afa1cf")
        
        let encoding = (method == .post || method == .patch) ? JSONEncoding.default : encoding
        
        return AF
            .request(self.url(path),
                     method: method,
                     parameters: parameters,
                     encoding: encoding,
                     headers: headers)
            .validate(statusCode: 200..<300)
                    .printLog(isLoggingEnable: isLoggingEnable)
    }
}

extension Networking {
    func cancelAllRequest() {
        manager.cancelAllRequests()
        manager.session.getAllTasks { (tasks) in
            for task in tasks {
                task.cancel()
            }
        }
    }
}

extension DataRequest {
    func printLog(queue: DispatchQueue? = nil, isLoggingEnable: Bool = true) -> DataRequest
    {
        return responseData(queue: queue ?? .main)
        { response in
            safePrint("++++++++++++++++++++++++++++++")
            let requestBodyPercentEncoded: String = String(data: response.request?.httpBody ?? Data() , encoding: .utf8) ?? ""
            let requestUrl: String = response.request?.url?.absoluteString ?? ""
            let requestMethod: String = response.request?.method?.rawValue ?? ""
            let requestHeader = response.request?.allHTTPHeaderFields ?? [:]
            let requestBody = (requestBodyPercentEncoded).removingPercentEncoding
            safePrint("++ Request url: \(requestMethod): \(requestUrl)" )
            safePrint("++ All Response Info: \(response)")
            
            if let utf8Text = String(data: response.data ?? Data(), encoding: .utf8)?.removingPercentEncoding {
                safePrint("++ Data: \(utf8Text)")
            }
        }
    }
}
