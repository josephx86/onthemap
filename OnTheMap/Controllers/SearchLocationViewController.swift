//
//  SearchLocationViewController.swift
//  OnTheMap
//
//  Created by Joseph on 5/20/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationViewController: UIViewController, UITextFieldDelegate {
    
    var student: StudentInformation!
    let showLocationSegue = "ShowLocation"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(pop))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "Add Location"
        locationNameTextField.delegate = self
        urlTextField.delegate = self
    }
    
    func updateUi(searching: Bool) {
        locationNameTextField.isEnabled = !searching
        urlTextField.isEnabled = !searching
        findButton.isEnabled = !searching
        if searching {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func findLocation(_ sender: Any) {
        let locationMessage = "Enter a location name"
        if let name = locationNameTextField.text {
            if name.isEmpty {
                locationNameTextField.becomeFirstResponder()
                showAlert(message: locationMessage)
                return
            }
            
            let urlMessage = "Enter a URL for the location"
            if let url = urlTextField.text {
                if url.isEmpty {
                    urlTextField.becomeFirstResponder()
                    showAlert(message: urlMessage)
                    return
                }
                
                searchlocation(locationName: name, locationUrl: url)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showLocationSegue {
            if let destination = segue.destination as? ShowLocationViewController {
                destination.student = student
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func searchlocation(locationName: String, locationUrl: String) {
        updateUi(searching: true)
        
        let message = "No matching locations found. Try something different."
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationName
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            if let response = response  {
                if let firstItem = response.mapItems.first {
                    let lat = firstItem.placemark.coordinate.latitude
                    let lon = firstItem.placemark.coordinate.longitude
                    let now = "\(Date())"
                    self.student = StudentInformation(createdAt: now, firstName: "Jane", lastName: "Doe", latitude: lat, longitude: lon, mapString: locationName, mediaURL: locationUrl, uniqueKey: "1234", updatedAt: now)
                    self.performSegue(withIdentifier: self.showLocationSegue, sender: self)
                } else {
                    self.showAlert(message: message)
                }
            } else {
                self.showAlert(message: message)
            }
            self.updateUi(searching: false)
        }
    }
}
