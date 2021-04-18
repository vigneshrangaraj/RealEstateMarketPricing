//
//  DisplayResultsControllerViewController.swift
//  FoodTracker
//
//  Created by Vic on 4/10/21.
//  Copyright © 2021 Harrisburg. All rights reserved.
//

import UIKit
import SwiftUI
import os.log

class DisplayResultsControllerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var resultNum: String? = "0.0"
    var lotArea: Double?

    var basement: Double?

    var livingArea: Double?

    var baths: Double?

    var rooms: Double?

    var bedRooms: Double?

    var deck: Double?

    var firstFloor: Double?

    var secondFloor: Double?

    var carsGarage: Double?
    
    var addressField: String?
    
    var imageString: String?
    
    var presentingMode: String?
    
    var uuid: UUID?
    
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var resultView: UILabel!
    
    var property: Property?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.text = "$" + String(self.resultNum!)
        // Do any additional setup after loading the view.
        switch(presentingMode ?? "") {
        case "AddItem":
            os_log("Adding a new property.", log: OSLog.default, type: .debug)
        case "EditItem":
            photoImageView.image = self.retrieveImage(forKey: imageString!)
            addressTextField.text = addressField
        default:
            os_log("Unknown identifier", log: OSLog.default, type: .debug)        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressTextField.resignFirstResponder()
        return true
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func postJson(completion: @escaping (Response) -> ()) {
        dispatchGroup.enter()
        let url = URL(string: "http://localhost:3000/properties/createProp")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let json = try! JSONEncoder().encode(self.property)
        
            URLSession.shared.uploadTask(with: request, from: json) { data, response, error in
                if error != nil {
                    os_log("Error saving item.", log: OSLog.default, type: .debug)
                } else {
                    os_log("Successfully saved item.", log: OSLog.default, type: .debug)
                }
            }.resume()
    }
    
    func editJson(completion: @escaping (Response) -> ()) {
        dispatchGroup.enter()
        let url = URL(string: "http://localhost:3000/properties/editProp")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let json = try! JSONEncoder().encode(self.property)
        
            URLSession.shared.uploadTask(with: request, from: json) { data, response, error in
                if error != nil {
                    os_log("Error saving item.", log: OSLog.default, type: .debug)
                } else {
                    os_log("Successfully saved item.", log: OSLog.default, type: .debug)
                }
            }.resume()
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIButton, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let address = addressTextField.text ?? ""
        self.store(image: photoImageView.image!, forKey: address + "image")
        let result = resultView.text ?? ""
        
        switch(presentingMode ?? "") {
        case "AddItem":
            property = Property(add: address, photo: address + "image", result: result, lotArea: lotArea!, basement: basement!, livingArea: livingArea!, baths: baths!, rooms: rooms!, bedRooms: bedRooms!, deck: deck!, firstFloor: firstFloor!, secondFloor: secondFloor!, carsGarage: carsGarage!, uuid: UUID())
            os_log("Adding a new property.", log: OSLog.default, type: .debug)
            postJson { (json) in
                print(json)
            }
        case "EditItem":
            property = Property(add: address, photo: address + "image", result: result, lotArea: lotArea!, basement: basement!, livingArea: livingArea!, baths: baths!, rooms: rooms!, bedRooms: bedRooms!, deck: deck!, firstFloor: firstFloor!, secondFloor: secondFloor!, carsGarage: carsGarage!, uuid: uuid)
            os_log("Editing a property.", log: OSLog.default, type: .debug)
            editJson { (json) in
                print(json)
            }
        default:
            os_log("Unknown identifier", log: OSLog.default, type: .debug)
        }
    }
    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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

