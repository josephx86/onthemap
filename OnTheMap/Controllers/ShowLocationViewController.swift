//
//  ShowLocationViewController.swift
//  OnTheMap
//
//  Created by Joseph on 5/20/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ShowLocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var submittingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var student: StudentInformation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        navigationItem.title = "Add Location"
        addAnnotation()
        updateUi(posting: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func addAnnotation() { 
        mapView.removeAnnotations(self.mapView.annotations)
        let pin = MKPointAnnotation()
        pin.title = student.mapString
        pin.subtitle = student.mediaURL
        pin.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
        mapView.addAnnotation(pin)
        mapView.showAnnotations([pin], animated: true)
    }
    
    func handlePostResult(success: Bool, errorMessage: String?, response: Data?) {
        DispatchQueue.main.async {
            self.updateUi(posting: false)
            if success {
                // Save the last posted info
                if let appDelegate = UIApplication.shared.delegate as! AppDelegate? {
                    appDelegate.lastPostedInfo = self.student
                }
                
                self.pop()
            } else {
                if let errorMessage = errorMessage {
                    self.showAlert(message: errorMessage)
                }
            }
        }
    }
    
    func updateUi(posting: Bool) {
           submittingLabel.isHidden = !posting
           finishButton.isHidden = posting
           if posting {
               activityIndicator.startAnimating()
           } else {
               activityIndicator.stopAnimating()
           }
       }
    
    @IBAction func finish(_ sender: Any) {
        let encoder = JSONEncoder();
        if let data = try? encoder.encode(student),
            let json = String(data: data, encoding: .utf8) {
            updateUi(posting: true)
            HttpHelper.postPlace(json: json, handler: handlePostResult(success:errorMessage:response:)) 
        } 
    }
}
