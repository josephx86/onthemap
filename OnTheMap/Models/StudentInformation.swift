//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Joseph on 5/20/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

struct StudentInformationList: Codable {
    var students: [StudentInformation]
    
    enum CodingKeys: String, CodingKey {
        case students = "results"
    }
}

struct StudentInformation: Codable {
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String 
    let uniqueKey: String
    let updatedAt: String
    
    func getFullname() -> String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
}
