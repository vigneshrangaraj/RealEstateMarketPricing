//
//  PropertyViewController.swift
//  FoodTracker
//
//  Created by Vic on 3/28/21.
//  Copyright © 2021 Harrisburg. All rights reserved.
//

import UIKit

struct Response: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }

    let data: Double
}

class PropertyViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var lotAreaTextField: UITextField!
    @IBOutlet weak var totalBsmtTextField: UITextField!
    @IBOutlet weak var grdLivingAreaTextField: UITextField!
    @IBOutlet weak var noFullBathsTextField: UITextField!
    @IBOutlet weak var ttlRmsAbvGrdTextField: UITextField!
    @IBOutlet weak var ttlBdRmsAbvGrdTextField: UITextField!
    @IBOutlet weak var wdDckTextField: UITextField!
    @IBOutlet weak var fstFlrTextField: UITextField!
    @IBOutlet weak var scdFlrTextField: UITextField!
    @IBOutlet weak var noOfCrsGrgTextField: UITextField!
    @IBOutlet weak var saveProps: UIBarButtonItem!
    
    var poolArea: Double? = 0.0
    var lotArea: Double? = 0.0
    var basement: Double? = 0.0
    var livingArea: Double? = 0.0
    var baths: Double? = 0.0
    var rooms: Double? = 0.0
    var bedRooms: Double? = 0.0
    var deck: Double? = 0.0
    var firstFloor: Double? = 0.0
    var secondFloor: Double? = 0.0
    var carsGarage: Double? = 0.0
    var addressField: String? = ""
    var imageString: String? = ""
    var uuid: UUID?
    
    var result: String? = "0.0"
    
    var urlDone = false
    
    var property: Property?
    
    var task = URLSessionUploadTask();
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lotAreaTextField.delegate = self
        totalBsmtTextField.delegate = self
        grdLivingAreaTextField.delegate = self
        noFullBathsTextField.delegate = self
        ttlRmsAbvGrdTextField.delegate = self
        ttlBdRmsAbvGrdTextField.delegate = self
        wdDckTextField.delegate = self
        fstFlrTextField.delegate = self
        scdFlrTextField.delegate = self
        noOfCrsGrgTextField.delegate = self
        
        if let property = property {
            lotAreaTextField.text = String(format: "%.1f", property.lotArea!)
            totalBsmtTextField.text = String(format: "%.1f", property.basement!)
            grdLivingAreaTextField.text = String(format: "%.1f", property.livingArea!)
            noFullBathsTextField.text = String(format: "%.1f", property.baths!)
            ttlRmsAbvGrdTextField.text = String(format: "%.1f", property.rooms!)
            ttlBdRmsAbvGrdTextField.text = String(format: "%.1f", property.bedRooms!)
            wdDckTextField.text = String(format: "%.1f", property.deck!)
            fstFlrTextField.text = String(format: "%.1f", property.firstFloor!)
            scdFlrTextField.text = String(format: "%.1f", property.secondFloor!)
            noOfCrsGrgTextField.text = String(format: "%.1f", property.carsGarage!)
            
            lotArea = property.lotArea
            basement = property.basement
            livingArea = property.livingArea
            baths = property.baths
            rooms = property.rooms
            bedRooms = property.bedRooms
            deck = property.deck
            firstFloor = property.firstFloor
            secondFloor = property.secondFloor
            carsGarage = property.carsGarage
            addressField = property.address
            imageString = property.photo
            uuid = property.uuid
        }
        
        updateSaveButtonState()
        
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        if (textField == lotAreaTextField) {
            lotArea = Double(textField.text!)
        }
        
        if (textField == totalBsmtTextField) {
            basement = Double(textField.text!)
        }
        
        if (textField == grdLivingAreaTextField) {
            livingArea = Double(textField.text!)
        }
        
        if (textField == noFullBathsTextField) {
            baths = Double(textField.text!)
        }
        
        if (textField == ttlRmsAbvGrdTextField) {
            rooms = Double(textField.text!)
        }
        
        if (textField == ttlBdRmsAbvGrdTextField) {
            bedRooms = Double(textField.text!)
        }
        
        if (textField == wdDckTextField) {
            deck = Double(textField.text!)
        }
        
        if (textField == fstFlrTextField) {
            firstFloor = Double(textField.text!)
        }
        
        if (textField == scdFlrTextField) {
            secondFloor = Double(textField.text!)
        }
        
        if (textField == noOfCrsGrgTextField) {
            carsGarage = Double(textField.text!)
        }
    }
    
    
    //MARK: Actions
    @IBAction func submitNumbers(_ sender: UIBarButtonItem) {
        postJson { (json) in
            print(json)
            self.result = String(Int(json.data))
        }
        self.task.resume()
        
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while !self.urlDone
        
        let vc = self.storyboard?.instantiateViewController(identifier: "ResultsVC") as! DisplayResultsControllerViewController
        vc.resultNum = String(self.result!)
        vc.lotArea = lotArea
        vc.basement = basement
        vc.livingArea = livingArea
        vc.baths = baths
        vc.rooms = rooms
        vc.bedRooms = bedRooms
        vc.deck = deck
        vc.firstFloor = firstFloor
        vc.secondFloor = secondFloor
        vc.carsGarage = carsGarage
        vc.addressField = addressField
        vc.imageString = imageString
        vc.uuid = uuid
        let isPresentingInAddPropMode = presentingViewController is UINavigationController
        if isPresentingInAddPropMode {
            vc.presentingMode = "AddItem"
        } else if navigationController != nil{
            vc.presentingMode = "EditItem"
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
        
        self.present(vc, animated: true)
    }
    
    func postJson(completion: @escaping (Response) -> ()) {
        dispatchGroup.enter()
        let url = URL(string: "http://localhost:3000/predict")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let json = [
            "LotArea": lotArea,
            "TotalBsmtSF": basement,
            "GrLivArea": livingArea,
            "FullBath": baths,
            "BedroomAbvGr": bedRooms,
            "TotRmsAbvGrd": rooms,
            "WoodDeckSF": deck,
            "1stFlrSF": firstFloor,
            "2ndFlrSF": secondFloor,
            "GarageCars": carsGarage
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            self.task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    if String(data: data, encoding: .utf8) != nil {
                        let json = try! decoder.decode(Response.self, from: data)
                        self.result = String(json.data)
                        print(json)
                        self.urlDone = true
                    }
                }
            }
        }
    }
    
    func editJson(completion: @escaping (Response) -> ()) {
        dispatchGroup.enter()
        let url = URL(string: "http://localhost:3000/predict")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let json = [
            "LotArea": lotArea,
            "TotalBsmtSF": basement,
            "GrLivArea": livingArea,
            "FullBath": baths,
            "BedroomAbvGr": bedRooms,
            "TotRmsAbvGrd": rooms,
            "WoodDeckSF": deck,
            "1stFlrSF": firstFloor,
            "2ndFlrSF": secondFloor,
            "GarageCars": carsGarage
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            self.task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    if String(data: data, encoding: .utf8) != nil {
                        let json = try! decoder.decode(Response.self, from: data)
                        self.result = String(json.data)
                        print(json)
                        self.urlDone = true
                    }
                }
            }
        }
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        saveProps.isEnabled = !(lotAreaTextField.text ?? "").isEmpty &&
            !(totalBsmtTextField.text ?? "").isEmpty &&
            !(grdLivingAreaTextField.text ?? "").isEmpty &&
            !(noFullBathsTextField.text ?? "").isEmpty &&
            !(ttlRmsAbvGrdTextField.text ?? "").isEmpty &&
            !(ttlBdRmsAbvGrdTextField.text ?? "").isEmpty &&
            !(wdDckTextField.text ?? "").isEmpty &&
            !(fstFlrTextField.text ?? "").isEmpty &&
            !(scdFlrTextField.text ?? "").isEmpty &&
            !(noOfCrsGrgTextField.text ?? "").isEmpty
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddPropMode = presentingViewController is UINavigationController
        if isPresentingInAddPropMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
}

