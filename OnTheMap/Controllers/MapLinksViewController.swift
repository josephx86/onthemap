//
//  MapLinksViewController.swift
//  OnTheMap
//
//  Created by Joseph on 5/19/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit
import MapKit

class MapLinksViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    var sessionId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshLocations))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        let logoutButton = UIBarButtonItem(title: "LOGOUT", style: .done, target: self, action: #selector(logout)) 
        tabBarController?.navigationItem.hidesBackButton = true
        tabBarController?.navigationItem.setLeftBarButton(logoutButton, animated: true)
        tabBarController?.navigationItem.setRightBarButtonItems([addButton, refreshButton], animated: true)
        navigationController?.navigationBar.isHidden = false
        mapView.delegate = self
        loadLocations(forceDownload: false)
    }
    
    @objc func refreshLocations() {
        loadLocations(forceDownload: true)
    }
    
    func loadLocations(forceDownload: Bool) {
        activityIndicator.startAnimating()
        mapView.isHidden = true
        getStudents(forceDownload: forceDownload, studentHandler: handleStudents(_:))
    } 
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let errorMessage = "That location does not have a valid tagged URL"
        if let webAddress = view.annotation?.subtitle {
            openUrl(string: webAddress)
        }else {
            showAlert(message: errorMessage)
        }
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
    
    func handleStudents(_ students: [StudentInformation]) {
        DispatchQueue.main.async {
            // Remove existing pins...
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            // ... then add the new pins
            for student in students {
                let pin = MKPointAnnotation() 
                pin.title = student.getFullname()
                pin.subtitle = student.mediaURL
                pin.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
                self.mapView.addAnnotation(pin)
            }
            self.mapView.isHidden = false
            self.activityIndicator.stopAnimating()
        }
    }
}
