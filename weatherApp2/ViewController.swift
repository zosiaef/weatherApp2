//
//  ViewController.swift
//  WeatherApp
//
//  Created by Student on 09.10.2018.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var prevB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var weatherTypre: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDir: UILabel!
    @IBOutlet weak var precipitacion: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var minTempText: UITextField!
    @IBOutlet weak var maxTempText: UITextField!
    @IBOutlet weak var windDirText: UITextField!
    @IBOutlet weak var windSpeedText: UITextField!
    @IBOutlet weak var precText: UITextField!
    @IBOutlet weak var presText: UITextField!
    
    var location: String?;
    var fullJson: [String:Any]!
    var mydict: [String:Any]?;
    var myArr: [[String:Any]?] = [];
    var index: Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = fullJson["title"] as? String
        self.myName.text = "Zofia Franczyk"
        self.prevB.isEnabled = false
        self.prevB.backgroundColor = UIColor.gray
        self.prevB.layer.cornerRadius = 10
    
        
        self.nextB.backgroundColor = UIColor.blue
        self.nextB.layer.cornerRadius = 10
        // Do any additional setup after loading the view, typically from a nib.
        
        self.myArr = self.fullJson["consolidated_weather"] as! [[String:Any]];
                    
        self.updateView()
    }
    
    func updateView(){
        let mydict: [String:Any] = myArr[self.index]!
        self.mydict = mydict;
        let type = String(self.mydict?["weather_state_abbr"] as! String);
        
        DispatchQueue.main.async {
            if let theImage = try? UIImage(data: Data(contentsOf: URL(string: "https://www.metaweather.com/static/img/weather/png/64/\(type).png")!)) {
                self.image.image = theImage;
            }
            self.date.text = String(self.mydict?["applicable_date"] as! String);
            self.minTempText.text = String((self.mydict?["min_temp"] as! Double).rounded());
            self.maxTempText.text = String((self.mydict?["max_temp"] as! Double).rounded());
            self.weatherTypre.text = String(self.mydict?["weather_state_name"] as! String);
            self.windDirText.text = String(self.mydict?["wind_direction_compass"] as! String);
            self.windSpeedText.text = String((self.mydict?["wind_speed"] as! Double).rounded());
            if(self.isNotRaining()){
                self.precText.text = "none";
            } else {
                self.precText.text = String(self.mydict?["weather_state_name"] as! String);
            }
            self.presText.text = String(self.mydict?["air_pressure"] as! Double);
        }
    }
    
    func isNotRaining() -> Bool {
        return ["hc","lc","c"].contains(where: {$0 == self.mydict?["weather_state_abbr"] as! String})
    }
    
    @IBAction func updateNextDay(_ sender: Any) {
        self.index = index + 1
        updateView()
        
        if (index == myArr.count - 1){
            self.nextB.isEnabled = false
            self.nextB.backgroundColor = UIColor.gray
        }
        
        if (index == 1){
            self.prevB.isEnabled = true
            self.prevB.backgroundColor = UIColor.blue
        }
    }
    
    @IBAction func updatePrevDay(_ sender: Any) {
        self.index = index - 1
        updateView()
        
        if (index == myArr.count - 2){
            self.nextB.isEnabled = true
            self.nextB.backgroundColor = UIColor.blue
        }
        
        if (index == 0){
            self.prevB.isEnabled = false
            self.prevB.backgroundColor = UIColor.gray
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Map" {
            let controller = segue.destination as! MapViewController
            
            let coordinates = fullJson["latt_long"] as? String
            let latt_longArray = coordinates!.components(separatedBy: ",")
            
            if let latitude = Double(latt_longArray[0]),
                let longitude = Double(latt_longArray[1]) {
                controller.coordinates =  CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
    }
}

