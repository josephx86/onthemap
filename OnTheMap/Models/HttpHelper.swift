//
//  HttpHelper.swift
//  OnTheMap
//
//  Created by Joseph on 5/19/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

enum HttpHeader: String {
    case accept = "Accept"
    case contentType = "Content-Type"
    case xsrfToken = "X-XSRF-TOKEN"
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

enum MimeType: String {
    case json = "application/json"
}

enum Endpoint: String {
    case session = "https://onthemap-api.udacity.com/v1/session"
    case first100 = "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100&order=-updatedAt"
    case studentLocation = "https://onthemap-api.udacity.com/v1/StudentLocation"
}

typealias TaskResponse = (Bool, String?, Data?) -> Void

class HttpHelper {
    
    class func postPlace(json: String, handler: @escaping TaskResponse) {
        var request = URLRequest(url: URL(string: Endpoint.studentLocation.rawValue)!)
        request.httpMethod = HttpMethod.post.rawValue
        request.addValue(MimeType.json.rawValue, forHTTPHeaderField:  HttpHeader.contentType.rawValue)
        request.httpBody = json.data(using: .utf8)
        doRequest(request, handler: handler) 
    }
    
    class func getFirst100Locations(handler: @escaping TaskResponse) {
        var request = URLRequest(url: URL(string: Endpoint.first100.rawValue)!)
        request.httpMethod = HttpMethod.get.rawValue
        doRequest(request, handler: handler)
    }
    
    class func deleteUserSession(handler: @escaping TaskResponse) {
        var request = URLRequest(url: URL(string: Endpoint.session.rawValue)!)
        request.httpMethod = HttpMethod.delete.rawValue
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: HttpHeader.xsrfToken.rawValue)
        }
        doRequest(request, handler: handler)
    }
    
    class func getUserSession(emailAddress username: String, password: String, handler: @escaping TaskResponse) {
        var request = URLRequest(url: URL(string: Endpoint.session.rawValue)!)
        request.httpMethod = HttpMethod.post.rawValue
        request.addValue(MimeType.json.rawValue, forHTTPHeaderField: HttpHeader.accept.rawValue)
        request.addValue(MimeType.json.rawValue, forHTTPHeaderField: HttpHeader.contentType.rawValue)
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        doRequest(request, handler: handler)
    }
    
    private class func doRequest(_ request: URLRequest, handler: @escaping TaskResponse) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            let address = request.url!.absoluteString
            var newData = data
            if address == Endpoint.session.rawValue {
                let range = 5 ..< data!.count
                newData = data!.subdata(in: range)
            }
            doHandler(data: newData, response: response, error: error, handler: handler)
        }
        task.resume()
    }
    
    private class func doHandler (data: Data?, response: URLResponse?, error: Error?, handler: @escaping TaskResponse) {
        if let error = error {
            handler(false, error.localizedDescription, nil)
            return
        }
        if let data = data {
            handler(true, nil, data)
            return
        }
    }
}
