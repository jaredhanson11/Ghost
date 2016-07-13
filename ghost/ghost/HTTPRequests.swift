//
//  HTTPRequests.swift
//  ghost
//
//  Created by John Clarke on 6/1/16.
//  Copyright © 2016 hck. All rights reserved.
//

import Foundation
import Alamofire

class HTTPRequests {
    
    let host: String
    let port: String
    let resource: String
    let params: [String:String]
    
    init(host: String, port: String, resource: String, params: [String:String] = [:]) {
        self.host = host
        self.port = port
        self.resource = resource
        self.params = params
    }
    
    // TODO: parameter validation
    // TODO: error handling
    func POST(callback: (json: [String:AnyObject]) -> Void) {
        let url: String = "http://" + host + ":" + port + "/" + resource + "/"
        Alamofire.request(.POST, url, parameters: self.params, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success(let data):
                    let data = data as! [String:AnyObject]
                    callback(json: data)
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    // A simple get http request
    // TODO: parameter validation
    func GET(callback: (json: [String:AnyObject]) -> Void) {
        let url: String = "http://" + host + ":" + port + "/" + resource + "/"
        Alamofire.request(.GET, url).responseJSON { response in
            switch response.result {
            case .Success(let data):
                let data = data as! [String:AnyObject]
                callback(json: data)
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
}