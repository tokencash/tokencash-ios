//
//  Reward.swift
//  API Tokencash
//
//  Created by Luis Perez on 07/02/17.
//  Copyright © 2017 Tokencash. All rights reserved.
//

import Foundation


public class Reward {
    struct parameterKeys {
        static let id = "ID"
        static let amount = "MONTO"
        static let name = "NOMBRE"
    }
    var id: Int
    var amount: Double
    var name: String
    
    init(id: Int, amount: Double, name: String) {
        self.id = id
        self.amount = amount
        self.name = name
    }
}
