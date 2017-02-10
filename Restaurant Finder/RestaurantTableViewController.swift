//
//  RestaurantTableViewController.swift
//  Restaurant Finder
//
//  Created by Nicholas Ellis on 2/10/17.
//  Copyright © 2017 Nicholas Ellis. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RestaurantTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var restauratns: [Restaurant] = []
    var pm: CLPlacemark?
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
        foodNearMeRequest()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restauratns.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        
        // Configure the cell...
        let food = restauratns[indexPath.row]
        cell.textLabel?.text = food.name
        
        return cell
    }
    
    // // MARK: - Location Services
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        if let location = locations.last {
            let displayString = "Lat: \(location.coordinate.latitude) Long: \(location.coordinate.longitude)"
            print(displayString)
        }
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
            if error != nil {
                print("Error geocoding")
            }
            
            guard let placemark = placemark?.last, let header = placemark.locality else { return }
            DispatchQueue.main.async {
                self.title = "\(header)"
                self.pm = placemark
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error:\(error)")
    }
    
    // MARK: - Map Services
    
    func foodNearMeRequest() {
        restauratns.removeAll()
        locationManager.startUpdatingLocation()
        let req = MKLocalSearchRequest()
        req.naturalLanguageQuery = "Restaurants"
        let search = MKLocalSearch.init(request: req)
        self.restauratns = []
        search.start { (respose, error) in
            guard let reponse = respose else {
                return
            }
            
            for i in reponse.mapItems {
                guard let name = i.name else { return }
                let food = Restaurant(name: name)
                self.restauratns.append(food)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.locationManager.stopUpdatingLocation()
            }
        }
        
    }
    
    @IBAction func clickMeButtonTapped(_ sender: Any) {
        foodNearMeRequest()
    }
   
}
