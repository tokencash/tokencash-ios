//
//  Bag.swift
//  API Tokencash
//
//  Created by Luis Perez on 07/02/17.
//  Copyright © 2017 Tokencash. All rights reserved.
//

import Foundation

public class Bag {
    struct bagParameterKeys {
        static let bag = "BOLSA"
        static let id = "ID"
        static let name = "NOMBRE"
    }
    var bag: String
    var id: String
    var name: String
    
    init(bag: String, id: String, name: String) {
        self.bag = bag
        self.id = id
        self.name = name
    }
}
