//
//  TokenDetailed.swift
//  API Tokencash
//
//  Created by Luis Perez on 06/01/17.
//  Copyright © 2017 Tokencash. All rights reserved.
//

import Foundation

public class TokenDetailed {
    struct parameterKeys {
        static let tokenId = "TOK_ID"
        static let tokenNumber = "TOK_NUMERO"
        static let vendorName = "NOMBRE"
        static let tokenDate = "FECHA_HORA"
        static let tokenStatus = "ESTADO"
        static let tokenAmount = "MONTO"
        static let tokenOriginalAmount = "MONTO_ORIGINAL"
        static let tokenPayedAmount = "MONTO_ABONADO"
        static let tokenTipAmount = "MONTO_PROPINA"
        static let reference = "REFERENCIA"
        static let rewardName = "RECOMPENSA_NOMBRE"
        static let rewardAmount = "RECOMPENSA_MONTO"
        static let payments = "LISTA_ABONOS"
    }
    var tokenID: String
    var tokenNumber: String
    var vendorName: String
    var tokenDate: String
    var tokenStatus: String
    var tokenAmount: String
    var tokenOriginalAmount: String
    var tokenPayedAmount: String
    var tokenTipAmount: String
    var reference: String
    var rewardName: String
    var rewardAmount: String
    var paymentList: [Payments]?
    
    init(tokenId: String, tokenNumber: String, vendorName: String, tokenDate: String, tokenStatus: String, tokenAmount: String, tokenOriginalAmount: String, tokenPayedAmount: String, tokenTipAmount: String, reference: String, rewardName: String, rewardAmount: String) {
        self.tokenID = tokenId
        self.tokenNumber = tokenNumber
        self.vendorName = vendorName
        self.tokenDate = tokenDate
        self.tokenStatus = tokenStatus
        self.tokenAmount = tokenAmount
        self.tokenOriginalAmount = tokenOriginalAmount
        self.tokenPayedAmount = tokenPayedAmount
        self.tokenTipAmount = tokenTipAmount
        self.reference = reference
        self.rewardName = rewardName
        self.rewardAmount = rewardAmount
    }
}
