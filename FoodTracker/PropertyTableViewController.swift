//
//  PropertyTableViewController.swift
//  FoodTracker
//
//  Created by Vic on 4/12/21.
//  Copyright © 2021 Harrisburg. All rights reserved.
//

import UIKit
import os.log

class PropertyTableViewController: UITableViewController {
    
    //MARK: Properties
     
    var properties = [Property]()
    let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProperties() { [weak self] (properties) in
            self?.properties = properties
            print(properties)
            DispatchQueue.main.async {
              self?.tableView.reloadData()
            }
        }
    }
    
    // MarK: Actions
    @IBAction func unwindPropertyToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DisplayResultsControllerViewController, let property = sourceViewController.property {
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                properties[selectedIndexPath.row] = property
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: properties.count, section: 0)
                properties.append(property)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return properties.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PropertyTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PropertyTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let property = properties[indexPath.row]
        
        let decodedimage: UIImage?
        
        if property.photo == "Property1" || property.photo == "Property2" || property.photo == "Property3" || property.photo == "Property4" {
            decodedimage = UIImage(named: property.photo)!
        } else {
            decodedimage = self.retrieveImage(forKey: property.address + "image")
        }

        cell.nameLabel.text = property.address
        cell.photoImageView.image = decodedimage
        cell.resultLabel.text = property.result

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let prop = properties[indexPath.row]
            deleteJSON(property: prop) {(json) in
                print(json)
            }
            properties.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func deleteJSON(property: Property?, completionHandler: @escaping (Response) -> Void) {
        dispatchGroup.enter()
        let url = URL(string: "http://localhost:3000/properties/deleteProp")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let json = try! JSONEncoder().encode(property)
        
            URLSession.shared.uploadTask(with: request, from: json) { data, response, error in
                if error != nil {
                    os_log("Error deleting item.", log: OSLog.default, type: .debug)
                } else {
                    os_log("Successfully deleted item.", log: OSLog.default, type: .debug)
                }
            }.resume()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new property.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let propDetailViewController = segue.destination as? PropertyViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPropCell = sender as? PropertyTableViewCell
                else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPropCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedProp = properties[indexPath.row]
            
            propDetailViewController.property = selectedProp
            
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    func loadProperties(completionHandler: @escaping ([Property]) -> Void) {
        let url = URL(string: "http://localhost:3000/properties")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if let error = error {
                print("There was an error calling properties GET")
                print(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = try? JSONDecoder().decode([Property].self, from: data!) {
                completionHandler(data)
            }
            
        })
        task.resume()
    }
    
    // MARK: Private Methods
    private func store(image: UIImage, forKey key: String) {
        if let pngRepresentation = image.pngData() {
            UserDefaults.standard.set(pngRepresentation, forKey: key)
        }
    }
    
    private func retrieveImage(forKey key: String) -> UIImage? {
        if let imageData = UserDefaults.standard.object(forKey: key) as? Data, let image = UIImage(data: imageData) {
            return image
        } else {
            return nil
        }
    }

}
