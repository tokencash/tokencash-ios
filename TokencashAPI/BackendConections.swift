//
//  BackendConections.swift
//  API Tokencash
//
//  Created by Luis Perez on 28/12/16.
//  Copyright © 2016 Tokencash. All rights reserved.
//

import Foundation

public class BackendConections {
    public lazy var sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
    public lazy var session: URLSession = URLSession(configuration: self.sessionConfiguration)
    private struct host {
        //static let mainHost = "http://pallene.klayware.com:3490/index.php?ACTION=PYXTER_TOKENCASH_EXT4_EXT:C5A.EXT.FORMA_PAGO."
        static let mainHost = "http://narvi.klayware.com/index.php?ACTION=PYXTER_TOKENCASH_EXT4_EXT:C5A.EXT.FORMA_PAGO."
    }
    private struct reservedWords {
        static let apiKey = "APIKEY"
        static let succededKey = "success"
        static let errorKey = "ERROR_CODE"
        static let returned = "RETURN"
        static let userID = "ID"
        static let status = "ESTADO"
    }
    private struct errorsAndMessages{
        static let noAPIKeyAdded = "ERROR: Add an API Key before doing the request"
        static let createTokenInvalidAmount = "ERROR: The amount of the token that you tried to create was incorrect"
        static let errorObtainingError = "ERROR: There was an error obtaining the error code"
        static let errorObtainingResponse = "ERROR: There was an error on the response serialization"
        static let tokenCreated = "The token creation was successfull"
        static let tokenAmountChanged = "The amount of the token was successfully changed"
        static let tokenClosed = "The token was closed successfully"
        static let tokenCanceled = "The token was canceled successfully"
        static let invalidAmount = "ERROR: The amount isnt valid"
        static let invalidTransaction = "ERROR: The transaction isnt valid"
        static let invalidTokenNumber = "ERROR: The number of token isnt valid"
        static let invalidAPIKey = "ERROR: The API key that you are using isnt valid"
        static let tokenAlredyPayed = "ERROR: The token that you tried to modify was alredy payed"
        static let canceledToken = "ERROR: The token that you tried to modify was canceled"
        static let tokenWithoutPayments = "ERROR: The token that you tried to close has no payments, it needs to have payments to close it or you can cancel it instead"
        static let tokenRetrieved = "The token information was retrieved successfully"
        static let rewardsObtained = "The rewards were successfully retrieved"
        static let noRewardsFound = "No rewards found"
        static let bagsObtained = "The bags for sale were successfully retrieved"
        static let noBagsFound = "No bags found"
        //static let coulnt
        
        static let saleSuccessfull = "The amount sale was completed successfully"
        static let saleNotSuccessfullBalance = "The sale wasnt completed: No balance available"
        static let saleNotSuccessfullDestiny = "The sale wasnt completed: incorrect destiny"
        
        // AMOUNT TRANSFER SUCCEDED 
        static let amountTransferSucceded = "The amount was transfered sucessfully"
        static let amountTransferUnsuccessfull = "The transfer was unsuccessfull"
        static let noUserIDFound = "Please add an user id first"
    }
    private struct errorValues {
        static let invalidAmount = "MONTO_INVALIDO"
        static let incorrectToken = "TOKEN_INCORRECTO"
        static let invalidAPIKey = "ERROR_SEGURIDAD"
        static let tokenAlredyPayed = "TOKEN_PAGADO"
        static let tokenCanceled = "TOKEN_CANCELADO"
        static let tokenWithoutPayments = "TOKEN_SIN_ABONOS"
        static let invalidDestiny = "DESTINO_INEXISTENTE"
    }
    
    public enum requestType: String {
        case createToken = "CREAR_TOKEN"
        case consultToken = "OBTENER_DETALLE_TOKEN"
        case changeToken = "CAMBIAR_TOKEN"
        case closeToken = "CERRAR_TOKEN"
        case cancelToken = "CANCELAR_TOKEN"
        case obtainRewards = "OBTENER_RECOMPENSAS_APLICABLES"
        
        //new options
        case sellCredit = "ABONO_ESTABLECIMIENTO"
        // first obtain giftcards
        case obtainGiftcards = "OBTENER_GIFTCARDS_VENTA"
        case payMe = "LIQUIDACION_A_BOLSA"
        // on this method you can only send two bags, VENTA or COBRO
        case checkEstablishmentBalance = "OBTENER_SALDO_ESTABLECIMIENTO"
        
    }
    
    public var method: requestType?
    public var dataDictionary = [String:String]()
    public func addData(_ key: String, _ value: String) {
        dataDictionary[key] = value
    }
    
    public func addAPIKey(_ APIKey: String) {
        addData(reservedWords.apiKey, APIKey)
    }
    public func addUserId(_ id: String) {
        addData(reservedWords.userID, id)
    }
    private struct errors {
        static let networkError = "Missing HTTP Response"
        static let noResponseFromTheServer = "The conection was sucessfully made, but the server anwser was nil:"
        static let resourceNotFound = "404, NOT FOUND: The resource that you are trying to reach cant be found, error code:"
        static let badRequest = "400 BAD REQUEST: Please review your request and try again"
        static let serverError = "500 INTERNAL SERVER ERROR: There was an error with the server, please report it on the github library"
        static let genericError = "I probably was too lazy to add all the other codes so i added this one, http error: "
        static let jsonSerializationError = "There was an error serializing Json, please check the response recieved by the backend"
    }
    
    public func createToken(token: Token, completion: @escaping (_ tokenCreated: Token?)->Void) {
        if token.amount <= 0 {
            checkMessage(message: errorsAndMessages.invalidAmount)
            completion(nil)
            return
        }
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(nil)
            return
        }
        if checkUserId() == false {
            checkMessage(message: errorsAndMessages.noUserIDFound)
            completion(nil)
            return
        }
        method = requestType.createToken
        let url = URL(string: host.mainHost + (method?.rawValue)!)!
        print(url)
        var request = URLRequest(url: url)
        if token.reference != nil {
            addData(Token.parameterKeys.reference, token.reference!)
        }
        if token.reward != nil {
            addData(Token.parameterKeys.reward, String(token.reward!))
        }
        addData(Token.parameterKeys.amount, String(token.amount))
        request.httpBody = createPostDataInformation()
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(nil)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                    case 200:
                        self.checkMessage(message: errors.noResponseFromTheServer)
                        completion(nil)
                    case 404:
                        self.checkMessage(message: errors.resourceNotFound)
                        completion(nil)
                    case 400:
                        self.checkMessage(message: errors.badRequest)
                        completion(nil)
                    case 500:
                        self.checkMessage(message: errors.serverError)
                        completion(nil)
                    default:
                        self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                        completion(nil)
                }
            }
            else {
                switch httpResponse.statusCode {
                    case 200:
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                            if let success = json?[reservedWords.succededKey] as? Bool {
                                if success {
                                    let completedToken = self.convertToToken(jsonRecieved: json, tokenRequested: token)
                                    self.checkMessage(message: errorsAndMessages.tokenCreated)
                                    completion(completedToken)
                                }
                                    
                                else {
                                    if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                        if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                            switch errorCode {
                                            case errorValues.invalidAmount:
                                                self.checkMessage(message: errorsAndMessages.createTokenInvalidAmount)
                                                completion(nil)
                                            case errorValues.invalidAPIKey:
                                                self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                                completion(nil)
                                            default:
                                                self.checkMessage(message: "This error isnt handled")
                                                completion(nil)
                                            }
                                        } else {
                                            self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                            completion(nil)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(nil)
                                    }
                                }
                            }
                            else {
                                self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                                completion(nil)
                            }
                        }
                        catch let error as NSError {
                            print(error)
                            self.checkMessage(message: errors.jsonSerializationError)
                            completion(nil)
                    }
                    case 404:
                        self.checkMessage(message: errors.resourceNotFound)
                        completion(nil)
                    case 400:
                        self.checkMessage(message: errors.badRequest)
                        completion(nil)
                    case 500:
                        self.checkMessage(message: errors.serverError)
                        completion(nil)
                    default:
                        self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                        completion(nil)
                }
            }
        }
        task.resume()
    }
    
    // Modify token Method
    public func changeTokenAmount(tokenTransaction: String, newAmount: Double, tokenNumber: String, completion: @escaping (_ changeSucceded: Bool)->Void) {
        method = requestType.changeToken
        if newAmount <= 0 {
            checkMessage(message: errorsAndMessages.invalidAmount)
            completion(false)
            return
        }
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(false)
            return
        }
        if checkUserId() == false {
            checkMessage(message: errorsAndMessages.noUserIDFound)
            completion(false)
            return
        }
        addData(Token.parameterKeys.amount, String(newAmount))
        addData(Token.parameterKeys.transaction, tokenTransaction)
        addData(Token.parameterKeys.tokenNumber, tokenNumber)
        let url = URL(string: host.mainHost + (method?.rawValue)!)!
        var request = URLRequest(url: url)
        request.httpBody = createPostDataInformation()
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(false)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(false)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                self.checkMessage(message: errorsAndMessages.tokenAmountChanged)
                                completion(true)
                            }
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.incorrectToken:
                                            self.checkMessage(message: errorsAndMessages.invalidTokenNumber)
                                            completion(false)
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.invalidAmount)
                                            completion(false)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(false)
                                        case errorValues.tokenAlredyPayed:
                                            self.checkMessage(message: errorsAndMessages.tokenAlredyPayed)
                                            completion(false)
                                        case errorValues.tokenCanceled:
                                            self.checkMessage(message: errorsAndMessages.canceledToken)
                                            completion(false)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(false)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(false)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(false)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(false)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(false)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    // close token method
    func closeToken(tokenTransaction: String, tokenNumber: String, completion: @escaping (_ changeSucceded: Bool)->Void) {
        method = requestType.closeToken
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(false)
            return
        }
        if checkUserId() == false {
            checkMessage(message: errorsAndMessages.noUserIDFound)
            completion(false)
            return
        }
        addData(Token.parameterKeys.transaction, tokenTransaction)
        addData(Token.parameterKeys.tokenNumber, tokenNumber)
        let url = URL(string: host.mainHost + (method?.rawValue)!)!
        var request = URLRequest(url: url)
        request.httpBody = createPostDataInformation()
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(false)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(false)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                self.checkMessage(message: errorsAndMessages.tokenClosed)
                                completion(true)
                            }
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.incorrectToken:
                                            self.checkMessage(message: errorsAndMessages.invalidTransaction)
                                            completion(false)
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.invalidAmount)
                                            completion(false)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(false)
                                        case errorValues.tokenAlredyPayed:
                                            self.checkMessage(message: errorsAndMessages.tokenAlredyPayed)
                                            completion(false)
                                        case errorValues.tokenCanceled:
                                            self.checkMessage(message: errorsAndMessages.canceledToken)
                                            completion(false)
                                        case errorValues.tokenWithoutPayments:
                                            self.checkMessage(message: errorsAndMessages.tokenWithoutPayments)
                                            completion(false)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(false)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(false)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(false)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(false)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(false)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    // cancel token method
    func cancelToken(tokenTransaction: String, tokenNumber: String, completion: @escaping (_ changeSucceded: Bool)->Void) {
        method = requestType.cancelToken
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(false)
            return
        }
        if checkUserId() == false {
            checkMessage(message: errorsAndMessages.noUserIDFound)
            completion(false)
            return
        }
        addData(Token.parameterKeys.transaction, tokenTransaction)
        addData(Token.parameterKeys.tokenNumber, tokenNumber)
        let url = URL(string: host.mainHost + (method?.rawValue)!)!
        var request = URLRequest(url: url)
        request.httpBody = createPostDataInformation()
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(false)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(false)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                self.checkMessage(message: errorsAndMessages.tokenCanceled)
                                completion(true)
                            }
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.incorrectToken:
                                            self.checkMessage(message: errorsAndMessages.invalidTransaction)
                                            completion(false)
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.invalidAmount)
                                            completion(false)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(false)
                                        case errorValues.tokenAlredyPayed:
                                            self.checkMessage(message: errorsAndMessages.tokenAlredyPayed)
                                            completion(false)
                                        case errorValues.tokenCanceled:
                                            self.checkMessage(message: errorsAndMessages.canceledToken)
                                            completion(false)
                                        case errorValues.tokenWithoutPayments:
                                            self.checkMessage(message: errorsAndMessages.tokenWithoutPayments)
                                            completion(false)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(false)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(false)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(false)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(false)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(false)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    //method to obtain details from the token
    func getTokenDetails(_ tokenTransaction: String, _ tokenNumber: String, completion: @escaping (_ tokenDetailed: TokenDetailed?)->Void) {
        method = requestType.consultToken
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(nil)
            return
        }
        if checkUserId() == false {
            checkMessage(message: errorsAndMessages.noUserIDFound)
            completion(nil)
            return
        }
        addData(Token.parameterKeys.transaction, tokenTransaction)
        addData(Token.parameterKeys.tokenNumberForChange, tokenNumber)
        
        let parameters = generateParametersForGetMethod()
        let url = URL(string: host.mainHost + (method?.rawValue)! + parameters)!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(nil)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(nil)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        print(httpResponse.allHeaderFields)
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                if let infoDict = json?[reservedWords.returned] as? [String:Any] {
                                    let tokenId = infoDict[TokenDetailed.parameterKeys.tokenId] as? String ?? "404 not found"
                                    let tokenNumber = infoDict[TokenDetailed.parameterKeys.tokenNumber] as? String ?? "404 not found"
                                    let vendorName = infoDict[TokenDetailed.parameterKeys.vendorName] as? String ?? "404 not found"
                                    let tokenDate = infoDict[TokenDetailed.parameterKeys.tokenDate] as? String ?? "404 not found"
                                    let tokenStatus = infoDict[TokenDetailed.parameterKeys.tokenStatus] as? String ?? "404 not found"
                                    let tokenAmount = infoDict[TokenDetailed.parameterKeys.tokenAmount] as? String ?? "404 not found"
                                    let tokenOriginalAmount = infoDict[TokenDetailed.parameterKeys.tokenOriginalAmount] as? String ?? "404 not found"
                                    let tokenPayedAmount = infoDict[TokenDetailed.parameterKeys.tokenPayedAmount] as? String ?? "404 not found"
                                    let tokenTipAmount = infoDict[TokenDetailed.parameterKeys.tokenTipAmount] as? String ?? "404 not found"
                                    let reference = infoDict[TokenDetailed.parameterKeys.reference] as? String ?? "404 not found"
                                    let rewardName = infoDict[TokenDetailed.parameterKeys.rewardName] as? String ?? "no reward"
                                    let rewardAmount = infoDict[TokenDetailed.parameterKeys.rewardAmount] as? String ?? "n/a"
                                    let newDetailedToken = TokenDetailed(tokenId: tokenId, tokenNumber: tokenNumber, vendorName: vendorName, tokenDate: tokenDate, tokenStatus: tokenStatus, tokenAmount: tokenAmount, tokenOriginalAmount: tokenOriginalAmount, tokenPayedAmount: tokenPayedAmount, tokenTipAmount: tokenTipAmount, reference: reference, rewardName: rewardName, rewardAmount: rewardAmount)
                                    if let paymentsList = infoDict[TokenDetailed.parameterKeys.payments] as? [[String:Any]] {
                                        newDetailedToken.paymentList?.removeAll()
                                        for payment in paymentsList {
                                            let paymentDate = payment[Payments.parametersKeys.paymentDate] as? String ?? "404 not found"
                                            let paymentUser = payment[Payments.parametersKeys.user] as? String ?? "404 not found"
                                            let paymentAmount = payment[Payments.parametersKeys.amount] as? String ?? "404 not found"
                                            let paymentTip = payment[Payments.parametersKeys.tip] as? String ?? "404 not found"
                                            let paymentRewardAmount = payment[Payments.parametersKeys.rewardAmount] as? String ?? "404 not found"
                                            let newPayment = Payments(paymentDate: paymentDate, user: paymentUser, amount: paymentAmount, tip: paymentTip, rewardAmount: paymentRewardAmount)
                                            newDetailedToken.paymentList?.append(newPayment)
                                        }
                                    }else {
                                        newDetailedToken.paymentList = nil
                                    }
                                    self.checkMessage(message: errorsAndMessages.tokenRetrieved)
                                    completion(newDetailedToken)
                                }
                                else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                                    completion(nil)
                                }
                            }
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.incorrectToken:
                                            self.checkMessage(message: errorsAndMessages.invalidTransaction)
                                            completion(nil)
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.invalidAmount)
                                            completion(nil)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(nil)
                                        case errorValues.tokenAlredyPayed:
                                            self.checkMessage(message: errorsAndMessages.tokenAlredyPayed)
                                            completion(nil)
                                        case errorValues.tokenCanceled:
                                            self.checkMessage(message: errorsAndMessages.canceledToken)
                                            completion(nil)
                                        case errorValues.tokenWithoutPayments:
                                            self.checkMessage(message: errorsAndMessages.tokenWithoutPayments)
                                            completion(nil)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(nil)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(nil)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(nil)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(nil)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(nil)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    
    // remaining methods 
    func obtainRewards(completion: @escaping (_ tokenDetailed: [Reward]?)->Void) {
        method = requestType.obtainRewards
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(nil)
            return
        }
        let parameters = generateParametersForGetMethod()
        let url = URL(string: host.mainHost + (method?.rawValue)! + parameters)!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(nil)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(nil)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        print(httpResponse.allHeaderFields)
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                if let rewardsArray = json?[reservedWords.returned] as? NSArray {
                                    var newRewardsArray =  [Reward]()
                                    for reward in rewardsArray {
                                        if let reward = reward as? [String: Any] {
                                            let id = reward[Reward.parameterKeys.id] as? String ?? "0"
                                            let amount = reward[Reward.parameterKeys.amount] as? String ?? "0"
                                            let name = reward[Reward.parameterKeys.name] as? String ?? "noName"
                                            let newReward = Reward(id: Int(id)!, amount: Double(amount)!, name: name)
                                            newRewardsArray.append(newReward)
                                        }
                                    }
                                    if newRewardsArray.count == 0 {
                                        self.checkMessage(message: errorsAndMessages.noRewardsFound)
                                        completion(nil)
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.rewardsObtained)
                                        completion(newRewardsArray)
                                    }
                                }
                                else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                                    completion(nil)
                                }
                            }
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.incorrectToken:
                                            self.checkMessage(message: errorsAndMessages.invalidTransaction)
                                            completion(nil)
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.invalidAmount)
                                            completion(nil)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(nil)
                                        case errorValues.tokenAlredyPayed:
                                            self.checkMessage(message: errorsAndMessages.tokenAlredyPayed)
                                            completion(nil)
                                        case errorValues.tokenCanceled:
                                            self.checkMessage(message: errorsAndMessages.canceledToken)
                                            completion(nil)
                                        case errorValues.tokenWithoutPayments:
                                            self.checkMessage(message: errorsAndMessages.tokenWithoutPayments)
                                            completion(nil)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(nil)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(nil)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(nil)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(nil)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(nil)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    
    func obtainAvailableGiftcards(completion: @escaping (_ tokenDetailed: [Bag]?)->Void) {
        method = requestType.obtainGiftcards
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(nil)
            return
        }
        let parameters = generateParametersForGetMethod()
        let url = URL(string: host.mainHost + (method?.rawValue)! + parameters)!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(nil)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(nil)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        print(httpResponse.allHeaderFields)
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                if let rewardsArray = json?[reservedWords.returned] as? NSArray {
                                    var newBagsArray =  [Bag]()
                                    for reward in rewardsArray {
                                        if let reward = reward as? [String: Any] {
                                            let id = reward[Bag.bagParameterKeys.id] as? String ?? ""
                                            let bag = reward[Bag.bagParameterKeys.bag] as? String ?? ""
                                            let name = reward[Bag.bagParameterKeys.name] as? String ?? ""
                                            let newBag = Bag(bag: bag, id: id, name: name)
                                            newBagsArray.append(newBag)
                                        }
                                    }
                                    if newBagsArray.count == 0 {
                                        self.checkMessage(message: errorsAndMessages.noBagsFound)
                                        completion(nil)
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.bagsObtained)
                                        completion(newBagsArray)
                                    }
                                }
                                else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                                    completion(nil)
                                }
                            }
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.incorrectToken:
                                            self.checkMessage(message: errorsAndMessages.invalidTransaction)
                                            completion(nil)
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.invalidAmount)
                                            completion(nil)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(nil)
                                        case errorValues.tokenAlredyPayed:
                                            self.checkMessage(message: errorsAndMessages.tokenAlredyPayed)
                                            completion(nil)
                                        case errorValues.tokenCanceled:
                                            self.checkMessage(message: errorsAndMessages.canceledToken)
                                            completion(nil)
                                        case errorValues.tokenWithoutPayments:
                                            self.checkMessage(message: errorsAndMessages.tokenWithoutPayments)
                                            completion(nil)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(nil)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(nil)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(nil)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(nil)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(nil)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    
    // sell credit 
    
    func sellCredit(amount: Double, bag: Bag, destiny: String, completion: @escaping (_ saleSucceded: Bool, _ errorMessage: String?)->Void) {
        if amount <= 0 {
            checkMessage(message: errorsAndMessages.invalidAmount)
            completion(false, nil)
            return
        }
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(false, nil)
            return
        }
        if checkUserId() == false {
            checkMessage(message: errorsAndMessages.noUserIDFound)
            completion(false, nil)
            return
        }
        method = requestType.sellCredit
        let url = URL(string: host.mainHost + (method?.rawValue)!)!
        print(url)
        var request = URLRequest(url: url)
        addData("DESTINO", destiny)
        addData(Token.parameterKeys.amount, String(amount))
        addData("BOLSA", bag.bag)
        request.httpBody = createPostDataInformation()
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(false, nil)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(false, nil)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false, nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false, nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false, nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false, nil)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                let status = json?[reservedWords.status] as? String ?? ""
                                switch status {
                                    case "VIGENTE":
                                        self.checkMessage(message: errorsAndMessages.saleSuccessfull)
                                        completion(true, errorsAndMessages.saleSuccessfull)
                                    case "CANCELADO":
                                        self.checkMessage(message: errorsAndMessages.saleNotSuccessfullBalance)
                                        completion(false, errorsAndMessages.saleNotSuccessfullBalance)
                                    default:
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(false, "Error desconocido")
                                }
                            }
                                
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.createTokenInvalidAmount)
                                            completion(false, errorsAndMessages.createTokenInvalidAmount)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(false, errorsAndMessages.invalidAPIKey)
                                        case errorValues.invalidDestiny:
                                            self.checkMessage(message: errorsAndMessages.saleNotSuccessfullDestiny)
                                            completion(false, errorsAndMessages.saleNotSuccessfullDestiny)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(false, "This error isnt handled")
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(false, errorsAndMessages.errorObtainingError)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(false, errorsAndMessages.errorObtainingError)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(false, nil)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(false, nil)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false, nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false, nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false, nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false, nil)
                }
            }
        }
        task.resume()
    }
    
    // CHECK ESTABLISHMENT BALANCE
    enum bagForCheckBalance : String {
        case VENTA = "VENTA"
        case COBRO = "COBRO"
    }
    
    
    func checkEstablishmentBalance(_ bagType: bagForCheckBalance, completion: @escaping (_ availableAmount: Double?)->Void) {
        method = requestType.checkEstablishmentBalance
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(nil)
            return
        }
        addData("BOLSA", bagType.rawValue)
        let parameters = generateParametersForGetMethod()
        let url = URL(string: host.mainHost + (method?.rawValue)! + parameters)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(nil)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(nil)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        print(httpResponse.allHeaderFields)
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                let amount = json?[reservedWords.returned] as? String
                                if amount != nil {
                                    completion(Double(amount!))
                                } else {
                                    completion(nil)
                                }
                            }
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.incorrectToken:
                                            self.checkMessage(message: errorsAndMessages.invalidTransaction)
                                            completion(nil)
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.invalidAmount)
                                            completion(nil)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(nil)
                                        case errorValues.tokenAlredyPayed:
                                            self.checkMessage(message: errorsAndMessages.tokenAlredyPayed)
                                            completion(nil)
                                        case errorValues.tokenCanceled:
                                            self.checkMessage(message: errorsAndMessages.canceledToken)
                                            completion(nil)
                                        case errorValues.tokenWithoutPayments:
                                            self.checkMessage(message: errorsAndMessages.tokenWithoutPayments)
                                            completion(nil)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(nil)
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(nil)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(nil)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(nil)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(nil)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    
    // cash your money method 
    
    
    enum bagToCashUserAmount: String {
        case sale = "VENTA"
        case notifications = "NOTIFICACIONES"
    }
    
    func cashUserAmount(amount: Double, bag: bagToCashUserAmount, completion: @escaping (_ saleSucceded: Bool, _ errorMessage: String?)->Void) {
        if amount <= 0 {
            checkMessage(message: errorsAndMessages.invalidAmount)
            completion(false, nil)
            return
        }
        if checkApiKey() == false {
            checkMessage(message: errorsAndMessages.noAPIKeyAdded)
            completion(false, nil)
            return
        }
        if checkUserId() == false {
            checkMessage(message: errorsAndMessages.noUserIDFound)
            completion(false, nil)
            return
        }
        method = requestType.payMe
        let url = URL(string: host.mainHost + (method?.rawValue)!)!
        var request = URLRequest(url: url)
        addData(Token.parameterKeys.amount, String(amount))
        addData("BOLSA", bag.rawValue)
        request.httpBody = createPostDataInformation()
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                self.checkMessage(message: errors.networkError)
                completion(false, nil)
                return
            }
            if data == nil {
                switch httpResponse.statusCode {
                case 200:
                    self.checkMessage(message: errors.noResponseFromTheServer)
                    completion(false, nil)
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false, nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false, nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false, nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false, nil)
                }
            }
            else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        if let success = json?[reservedWords.succededKey] as? Bool {
                            if success {
                                if let response = json?[reservedWords.returned] as? [String:Any] {
                                    let status = response[reservedWords.status] as? String ?? ""
                                    switch status {
                                    case "VIGENTE":
                                        self.checkMessage(message: errorsAndMessages.amountTransferSucceded)
                                        completion(true, errorsAndMessages.amountTransferSucceded)
                                    case "CANCELADO":
                                        self.checkMessage(message: errorsAndMessages.amountTransferUnsuccessfull)
                                        completion(false, errorsAndMessages.amountTransferUnsuccessfull)
                                    default:
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(false, "Unknow error")
                                    }
                                } else {
                                    self.checkMessage(message: "Error obtaining info")
                                    completion(false, "Error obtaining info")
                                }
                            }
                                
                            else {
                                if let errorDict = json?[reservedWords.returned] as? [String: Any] {
                                    if let errorCode = errorDict[reservedWords.errorKey] as? String {
                                        switch errorCode {
                                        case errorValues.invalidAmount:
                                            self.checkMessage(message: errorsAndMessages.createTokenInvalidAmount)
                                            completion(false, errorsAndMessages.createTokenInvalidAmount)
                                        case errorValues.invalidAPIKey:
                                            self.checkMessage(message: errorsAndMessages.invalidAPIKey)
                                            completion(false, errorsAndMessages.invalidAPIKey)
                                        case errorValues.invalidDestiny:
                                            self.checkMessage(message: errorsAndMessages.saleNotSuccessfullDestiny)
                                            completion(false, errorsAndMessages.saleNotSuccessfullDestiny)
                                        default:
                                            self.checkMessage(message: "This error isnt handled")
                                            completion(false, "This error isnt handled")
                                        }
                                    } else {
                                        self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                        completion(false, errorsAndMessages.errorObtainingError)
                                    }
                                } else {
                                    self.checkMessage(message: errorsAndMessages.errorObtainingError)
                                    completion(false, errorsAndMessages.errorObtainingError)
                                }
                            }
                        }
                        else {
                            self.checkMessage(message: errorsAndMessages.errorObtainingResponse)
                            completion(false, nil)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                        self.checkMessage(message: errors.jsonSerializationError)
                        completion(false, nil)
                    }
                case 404:
                    self.checkMessage(message: errors.resourceNotFound)
                    completion(false, nil)
                case 400:
                    self.checkMessage(message: errors.badRequest)
                    completion(false, nil)
                case 500:
                    self.checkMessage(message: errors.serverError)
                    completion(false, nil)
                default:
                    self.checkMessage(message: errors.genericError + "\(httpResponse.statusCode)")
                    completion(false, nil)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    


    private func createPostDataInformation()-> Data? {
        do {
            let postString = try JSONSerialization.data(withJSONObject: dataDictionary, options: .prettyPrinted)
            return postString
        } catch let error {
            print(error)
            return nil
        }
    }
    private func convertToToken(jsonRecieved: [String:Any]?, tokenRequested: Token)-> Token?{
        if jsonRecieved == nil {
            return nil
        }
        if let responseDict = jsonRecieved?[reservedWords.returned] as? [String: Any] {
            if let tokenNumber = responseDict[Token.parameterKeys.tokenNumber] as? String {
                tokenRequested.setTokenNumber(tokenNumber: tokenNumber)
            }
            if let tokenEstablishment = responseDict[Token.parameterKeys.establishment] as? String {
                tokenRequested.setTokenEstablishment(tokenEstablishment: tokenEstablishment)
            }
            if let tokenTransaction = responseDict[Token.parameterKeys.transaction] as? String {
                tokenRequested.setTokentransaction(tokenTransaction: tokenTransaction)
            }
            return tokenRequested
        } else {
            return nil
        }
    }
    private func checkMessage(message: String) {
        print(message)
    }
    private func checkApiKey() -> Bool{
        let apiKey = dataDictionary[reservedWords.apiKey]
        if apiKey == nil {
            return false
        }
        else {
            return true
        }
    }
    private func checkUserId() -> Bool {
        let userId = dataDictionary[reservedWords.userID]
        if userId == nil {
            return false
        }
        else {
            return true
        }
    }
    
    private func generateParametersForGetMethod()-> String{
        var urlString = "&"
        var counter = dataDictionary.count
        for (key, value) in dataDictionary {
            if counter > 1 {
                let dataString = key + "=" + value + "&"
                urlString = urlString + dataString
                counter = counter - 1
            } else {
                let dataString = key + "=" + value
                urlString = urlString + dataString
            }
        }
        return urlString
    }
}

