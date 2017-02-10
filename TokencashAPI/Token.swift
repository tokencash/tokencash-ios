//
//  Token.swift
//  API Tokencash
//
//  Created by Luis Perez on 05/01/17.
//  Copyright © 2017 Tokencash. All rights reserved.
//

import Foundation

public class Token {
    struct parameterKeys {
        static let amount = "MONTO"
        static let reference = "REFERENCIA"
        static let reward = "RECOMPENSA"
        static let establishment = "ESTABLECIMIENTO"
        static let tokenNumber = "TOK_NUMERO"
        static let transaction = "TRANSACCION"
        static let tokenNumberForChange = "TOK_NUMERO"
    }
    var amount: Double
    var reference: String?
    var reward: Int?
    init(amount: Double) {
        self.amount = amount
    }
    private var tokenNumber: String?
    private var transaction: String?
    private var establishment: String?
    
    func setTokenNumber(tokenNumber: String) {
        self.tokenNumber = tokenNumber
    }
    func setTokentransaction(tokenTransaction: String) {
        transaction = tokenTransaction
    }
    func setTokenEstablishment(tokenEstablishment: String) {
        establishment = tokenEstablishment
    }
    func obtainTokenNumber() -> String?{
        return tokenNumber
    }
    func obtainTokentransaction() -> String? {
        return transaction
    }
    func obtainTokenEstablishment() -> String?{
        return establishment
    }
}
