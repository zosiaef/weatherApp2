//
//  AddViewController.swift
//  weatherApp2
//
//  Created by Zosia on 09/11/2018.
//  Copyright © 2018 Zosia. All rights reserved.
//

import UIKit
import CoreLocation

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var cities: [[String:Any]] = [[:]]
    var selectedCity: City!
    var locationManager: CLLocationManager!
    var currentCoordinates: CLLocationCoordinate2D!
    
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var serachForCities: UIButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
        
        //nadpisanie dodawania
        cell.textLabel!.text = cities[indexPath.row]["title"] as? String
        let distance = cities[indexPath.row]["distance"] as? String
        if (distance != nil){
            cell.detailTextLabel?.text = "\(distance!) km"
        }
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getCurrentLocation()
    }
    
    func getCurrentLocation(){
        print("getting current location..")
        if (CLLocationManager.locationServicesEnabled()){
            print("locationServicesEnabled")
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            
            if let location = locationManager.location {
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("[Uops!] location reverse geocoding went wrong: \(errorString)")
                        return
                    }
                    
                    self.currentLocation.text = "You are in \(placemark.locality!)"
                }
            self.currentCoordinates = locationManager.location?.coordinate
                print("coords saved")
            }
        } else {
            print ("location services not enabled :(")
        }
        
    }
    
    @IBAction func searchCities(_ sender: Any) {
        cities.removeAll()
        let urlString = "https://www.metaweather.com/api/location/search/?lattlong=\(currentCoordinates.latitude),\(currentCoordinates.longitude)"
            self.callApi(urlString)
    }
    
    @IBAction func searchForCities(_ sender: Any){
        cities.removeAll()
        if let textToSearch = typeField.text?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed){
            let urlString = "https://www.metaweather.com/api/location/search/?query=\(textToSearch)"
            self.callApi(urlString)
            
        }
    }
    
    func callApi (_ urlString: String){
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                print(usableData)
                do {
                    guard let json = try JSONSerialization.jsonObject(with: usableData, options: .mutableContainers) as? [[String: Any]] else { print("json")
                        return }
                    self.cities = json
                    
                    DispatchQueue.main.async {
                        self.updateView()
                    }
                } catch {
                    print(error)
                    return
                }
            }
        }
        task.resume()
    }
    
    func updateView(){
        tableView.reloadData()
    }
    
    @IBAction func clear(_ sender: Any){
        typeField.text = ""
        cities.removeAll()
        self.updateView()
    }
    // żeby zwracało counta ile znalazło miast
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath {
        let selectedCityId = cities[indexPath.row]["woeid"] as? Int
        let selectedCityName = cities[indexPath.row]["title"] as? String
        
        let selectedCity = City(city: selectedCityName!, id: selectedCityId!)
        self.selectedCity = selectedCity
        
        return indexPath
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
     */
    
}
