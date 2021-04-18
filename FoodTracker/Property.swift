//
//  Train.swift
//  FoodTracker
//
//  Created by Vic on 4/3/21.
//  Copyright © 2021 Harrisburg. All rights reserved.
//

import UIKit

class Property: Codable {
    var address: String
    var photo: String
    var result: String
    
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
    
    var uuid: UUID?
    
    
    init? (add: String, photo: String, result: String, lotArea: Double = 0, basement: Double = 0, livingArea: Double = 0, baths: Double = 0, rooms: Double = 0, bedRooms: Double = 0, deck: Double = 0, firstFloor: Double = 0, secondFloor: Double = 0, carsGarage: Double = 0, uuid: UUID?) {
        self.address = add
        self.photo = photo
        self.result = result
        self.lotArea = lotArea
        self.basement = basement
        self.livingArea = livingArea
        self.baths = baths
        self.rooms = rooms
        self.bedRooms = bedRooms
        self.deck = deck
        self.firstFloor = firstFloor
        self.secondFloor = secondFloor
        self.carsGarage = carsGarage
        if uuid == nil {
            self.uuid = UUID()
        } else {
            self.uuid = uuid
        }
        
    }
}
