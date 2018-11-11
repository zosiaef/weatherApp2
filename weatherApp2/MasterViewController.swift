//
//  MasterViewController.swift
//  weatherApp2
//
//  Created by Zosia on 09/11/2018.
//  Copyright © 2018 Zosia. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    
    var jsons: [[String: Any]] = []
    
    var cities: [City] = [City(city: "Warsaw", id: 523920), City(city: "Prague",id: 796597), City(city: "Amsterdam", id: 727232)]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        for city in cities {
            self.getJson(woeid: city.woeid)
        }
    }

    func getJson(woeid: Int){
        let urlString = "https://www.metaweather.com/api/location/\(woeid)/"
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                print(usableData)
                do {
                    guard let json = try JSONSerialization.jsonObject(with: usableData, options: []) as? [String: Any] else { return }
                    self.jsons.append(json)
                    print("added city \(woeid)")
                    
                    
                    DispatchQueue.main.async {
                        self.updateView(woeid)
                    }
                } catch {
                    return
                }
            }
        }
        task.resume()
    }
    
    func updateView(_ woeid: Int){
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! ViewController
                controller.fullJson = jsons[indexPath.row]
               // controller.detailItem = object
               // controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
               // controller.navigationItem.leftItemsSupplementBackButton = true
                
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
// ta do nadpisania
        var weather: [[String:Any]?] = jsons[indexPath.row]["consolidated_weather"] as! [[String : Any]?]
        let type = String(weather[0]?["weather_state_abbr"] as! String);
        
        cell.textLabel!.text = self.cities[indexPath.row].city
        cell.detailTextLabel!.text = String((weather[0]?["the_temp"] as! Double).rounded())

        if let theImage = try? UIImage(data: Data(contentsOf: URL(string: "https://www.metaweather.com/static/img/weather/png/64/\(type).png")!)) {
            cell.imageView!.image = theImage;
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

