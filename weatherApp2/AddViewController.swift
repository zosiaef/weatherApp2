//
//  AddViewController.swift
//  weatherApp2
//
//  Created by Zosia on 09/11/2018.
//  Copyright © 2018 Zosia. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cities: [[String:Any]] = [[:]]
    var selectedCity: City!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var typeField: UITextField!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
        
        //nadpisanie dodawania
        cell.textLabel!.text = cities[indexPath.row]["title"] as? String
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchForCities(_ sender: Any){
        print("In here")
        if let textToSearch = typeField.text?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed){
            print("aaa")
            let urlString = "https://www.metaweather.com/api/location/search/?query=\(textToSearch)"
            print(urlString)
            guard let requestUrl = URL(string:urlString) else { return }
            let request = URLRequest(url:requestUrl)
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                if error == nil,let usableData = data {
                    print(usableData)
                    do {
                        print("parsing....")
                        guard let json = try JSONSerialization.jsonObject(with: usableData, options: .mutableContainers) as? [[String: Any]] else { print("json")
                            return }
                        print ("parsed!")
                        print(json)
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
