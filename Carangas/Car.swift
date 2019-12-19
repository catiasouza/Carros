//
//  Car.swift
//  Carangas
//
//  Created by Catia Miranda de Souza on 16/12/19.
//  Copyright © 2019 Eric Brito. All rights reserved.
//

import Foundation

class Car:  Codable{                   //API
    
    var _id: String                 //"_id": "",
    var brand: String               //"brand": "danilo - TESTE ",
    var gasType: Int                //"gasType": 0,
    var name: String                //   "name": "Danilo",
    var price: Int                  //   "price": 200
    
    
    var gas : String{
        switch gasType {
        case 0:
            return "Flex"
        case 1:
            return "Flex"
        default:
            return "Gasolina"
        }
    }
    
}
