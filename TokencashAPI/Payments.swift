//
//  Payments.swift
//  API Tokencash
//
//  Created by Luis Perez on 06/01/17.
//  Copyright © 2017 Tokencash. All rights reserved.
//

import Foundation

public class Payments {
    struct parametersKeys {
        static let paymentDate = "FECHAHORA"
        static let user = "USUARIO_TELEFONO"
        static let amount = "MONTO"
        static let tip = "PROPINA"
        static let rewardAmount = "RECOMPENSA_MONTO"
    }
    var paymentDate: String
    var user: String
    var amount: String
    var tip: String
    var rewardAmount: String
    
    init(paymentDate: String, user: String, amount: String, tip: String, rewardAmount: String) {
        self.paymentDate = paymentDate
        self.user = user
        self.amount = amount
        self.tip = tip
        self.rewardAmount = rewardAmount
    }
}
