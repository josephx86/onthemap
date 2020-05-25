//
//  ListLinksViewController.swift
//  OnTheMap
//
//  Created by Joseph on 5/19/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

class ListLinksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshLocations))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        let logoutButton = UIBarButtonItem(title: "LOGOUT", style: .done, target: self, action: #selector(logout))
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.setLeftBarButton(logoutButton, animated: true)
        tabBarController?.navigationItem.setRightBarButtonItems([addButton, refreshButton], animated: true)
        navigationController?.navigationBar.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        loadLocations(forceDownload: false)
    }
    
    @objc func refreshLocations() {
        loadLocations(forceDownload: true)
    }
    
    func loadLocations(forceDownload: Bool) {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        getStudents(forceDownload: forceDownload, studentHandler: handleStudents(_:))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let errorMessage = "That location does not have a valid tagged URL"
        if let cell = tableView.cellForRow(at: indexPath) {
            openUrl(string: cell.detailTextLabel?.text)
        } else {
            showAlert(message: errorMessage)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let appDelegate = UIApplication.shared.delegate as! AppDelegate? {
            if let studentList = appDelegate.studentsList {
                return studentList.students.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")!
        if let appDelegate = UIApplication.shared.delegate as! AppDelegate? {
            if let studentList = appDelegate.studentsList {
                let studentInfo = studentList.students[indexPath.row]
                cell.textLabel?.text = studentInfo.getFullname()
                cell.detailTextLabel?.text = studentInfo.mediaURL
            }
        }
        return cell
    }
    
    func handleStudents(_ _: [StudentInformation]) {
        DispatchQueue.main.async {
            // Remove existing data...
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
        }
    }
}
