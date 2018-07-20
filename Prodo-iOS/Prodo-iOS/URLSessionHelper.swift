//
//  URLSessionHelper.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/13/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import Foundation

class URLSessionHelper {
    
    static func apiWithAuth(url: String, user: User, methodType: String, body: [String: Any]?, completion: @escaping ( _ res: URLResponse) -> ())   {
        let urlLive = "https://polar-bayou-64862.herokuapp.com"
        //let urltest = "localhost:3000"
        if let url = URL(string:urlLive+url ) {
            print(url)
            var request = URLRequest(url: url)
            // Set headers
            print(user.token)
            request.setValue(user.token, forHTTPHeaderField:"x-auth")
            request.httpMethod = methodType
            
            if let body = body {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let jsonData = try? JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
                print("hello")
                print(body)
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                guard let response = response
                    else {return}
                
                completion(response)
            }).resume()
        }
        
    }
    
    static func apiWithAuth<T: Decodable>(url: String, user: User, methodType: String, body: [String: Any]?, completion: @escaping (T?, _ res: URLResponse) -> ())   {
        let urlLive = "https://polar-bayou-64862.herokuapp.com"
        //let urltest = "localhost:3000"
        if let url = URL(string:urlLive+url ) {
            print(url)
            var request = URLRequest(url: url)
            // Set headers
            print(user.token)
            request.setValue(user.token, forHTTPHeaderField:"x-auth")
            request.httpMethod = methodType
            
            if let body = body {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let jsonData = try? JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
        
            }

            URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                guard let response = response,
                let data = data
                else {return}
                
                do {
                    let obj = try JSONDecoder().decode(T.self, from: data)
                    completion(obj,response)
                    print(obj)
                }
                catch  {
                    print(error)
                }
            }).resume()
        }
        
    }
    
    static func api<T: Decodable>(url: String, methodType: String, body: [String: Any]?, completion: @escaping (T?, _ res: URLResponse) -> ())   {
        let urlLive = "https://polar-bayou-64862.herokuapp.com"
        //let urltest = "localhost:3000"
        if let url = URL(string:urlLive+url ) {
            print(url)
            var request = URLRequest(url: url)
            request.httpMethod = methodType
            
            if let body = body {
                do {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
                    request.httpBody = jsonData
                    print(jsonString)
                }
                catch {
                    print(error)
                }
                
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                guard let response = response,
                    let data = data
                    else {return}
                
                if ((response as! HTTPURLResponse).statusCode != 200) {
                    print("hello")
                    completion(nil,response)
                }

                do {
                    let obj = try JSONDecoder().decode(T.self, from: data)
                    completion(obj,response)
                }
                catch  {
                    print(error)
                }
            }).resume()
        }
    }
    
    static func api(url: String, methodType: String, body: [String: Any]?, completion: @escaping ( _ res: URLResponse) -> ())   {
        let urlLive = "https://polar-bayou-64862.herokuapp.com"
        //let urltest = "localhost:3000"
        if let url = URL(string:urlLive+url ) {
            print(url)
            var request = URLRequest(url: url)
            request.httpMethod = methodType
            
            if let body = body {
                do {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
                    request.httpBody = jsonData
                    print(jsonString)
                }
                catch {
                    print(error)
                }
                
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                guard let response = response
                    else {return}
                
                completion(response)
            
            }).resume()
        }
    }
}
