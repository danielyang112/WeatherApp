//
//  ViewController.swift
//  WeatherApp
//
//  Created by Daniel Yang on 2018-02-21.
//  Copyright © 2018 Daniel Yang. All rights reserved.
//

import UIKit
import MapKit

let kAnnotations = "annotations"

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager? = nil
    var tappedCoordinate: CLLocationCoordinate2D?
    
    var myAnnotation: MKPointAnnotation? = nil
    
    var annotations: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Map"
        
        // Add clear button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Clear", style: .done, target: self, action: #selector(onClear(sender:)))
        
        // Load cached annotations
        self.annotations = UserDefaults.standard.stringArray(forKey: kAnnotations) ?? []
        self.loadAnnotations()
        
        // Add double tap gesture to map
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(onMapDoubleTapped(sender:)))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
        mapView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if locationManager == nil {
            determineCurrentLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Map Functions
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthorizationStatus()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager?.startUpdatingLocation()
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func loadAnnotations() {
        // Load annotations
        for annotationString in annotations {
            var string = annotationString.replacingOccurrences(of: "{", with: "")
            string = string.replacingOccurrences(of: "}", with: "")
            let array = string.components(separatedBy: ",")
            let lat = CLLocationDegrees(array[0])
            let lon = CLLocationDegrees(array[1])
            
            let annotation: MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            mapView.addAnnotation(annotation)
        }
    }
    
    func saveAnnotation(_ coordinate: CLLocationCoordinate2D) {
        // Save annotation locally
        let cordString = "{\(String(format: "%f", coordinate.latitude)),\(String(format: "%f", coordinate.longitude))}"
        
        // Check if corrdinate exists
        if !annotations.contains(cordString) {
            annotations.append(cordString)
            UserDefaults.standard.set(annotations, forKey: kAnnotations)
        }
    }
    
    // MARK: - Selectors
    
    @objc func onClear(sender: UITapGestureRecognizer) {
        // clear annotations
        
        for annotation in annotations {
            UserDefaults.standard.removeObject(forKey: annotation)
        }
        
        annotations = []
        UserDefaults.standard.set(annotations, forKey: kAnnotations)
        
        // remove annotations from map except current location one
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(myAnnotation!)
    }
    
    @objc func onMapDoubleTapped(sender: UITapGestureRecognizer) {
        // add new annotation
        let location = sender.location(in: mapView)
        tappedCoordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        saveAnnotation(tappedCoordinate!)
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate!
        mapView.addAnnotation(annotation)
        
        self.performSegue(withIdentifier: "segueWeather", sender: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let weatherVC = segue.destination as! WeatherViewController
        weatherVC.coordinate = tappedCoordinate
        
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
//        saveAnnotation(center)
        
        // Drop a pin at user's Current Location
        myAnnotation = MKPointAnnotation()
        myAnnotation?.coordinate = center
//        myAnnotation?.title = "Current location"
        mapView.addAnnotation(myAnnotation!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        // Show weather data for the annotation
        self.tappedCoordinate = view.annotation?.coordinate
        self.performSegue(withIdentifier: "segueWeather", sender: nil)
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

