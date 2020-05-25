//
//  extensions.swift
//  OnTheMap
//
//  Created by Joseph on 5/20/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @objc func pop() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func add() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "PostViewControllerNav") {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func logout() {
        HttpHelper.deleteUserSession() { (success, errorMessage, data) in
            // Since this is logging out, app will not notify user if something went wrong
            // but print a debug message to help during development
            if !success {
                if let errorMessage = errorMessage {
                    print(errorMessage)
                }
            }
            DispatchQueue.main.async {
                if let navigator = self.navigationController {
                    navigator.popToRootViewController(animated: true)
                }
            }
        }
    } 
    
    func getStudents(forceDownload: Bool, studentHandler: @escaping ([StudentInformation]) -> Void) {
        // Check if there are cached locations
        if let appDelegate = UIApplication.shared.delegate as! AppDelegate?   {
            if !forceDownload {
                if let studentList = appDelegate.studentsList {
                    if studentList.students.count >= 100 {
                        studentHandler(studentList.students)
                        return
                    }
                }
            }
            
            // Download data
            HttpHelper.getFirst100Locations { (success, errorMessage, data) in
                let generalErrorMessage = "Oops! Something went wrong while getting student locations"
                if success {
                    let decoder = JSONDecoder()
                    if let studentList = try? decoder.decode(StudentInformationList.self, from: data!) {
                        
                        // Sort by newest
                        var sortableList = studentList
                        sortableList.students.sort { (s1, s2) -> Bool in
                            let result = s1.createdAt .compare(s2.createdAt).rawValue
                            switch result {
                            case ComparisonResult.orderedDescending.rawValue:
                                return true
                            default:
                                return false
                            }
                        }
                        
                        appDelegate.studentsList = sortableList
                        studentHandler(studentList.students)
                    }else {
                        self.showAlert(message: generalErrorMessage)
                    }
                } else {
                    if let errorMessage = errorMessage {
                        self.showAlert(message: errorMessage)
                    }
                }
            }
        }
    }
    
    func openUrl(string webAddress: String?) {
        let errorMessage = "That location does not have a valid tagged URL"
        if let webAddress = webAddress {
            var address = webAddress
            if !webAddress.starts(with: "http") {
                address = "https://\(webAddress.trimmingCharacters(in: .whitespaces))"
            } 
            if let url = URL(string: address) {
                UIApplication.shared.open(url)
            } else {
                showAlert(message: errorMessage)
            }
        } else {
            showAlert(message: errorMessage)
        }
    }
}
