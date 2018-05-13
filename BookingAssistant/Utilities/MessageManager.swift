//
//  MessageManager.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import Foundation

class MessageManager {
    
    let networkService = NetworkService()
    
    func getWelcomeMessage(OnCompletion callback: @escaping (String,Error?) -> ()) {
        
        self.getResponseForUserInput(Message: "") { (message, error) in
            callback(message,error)
        }
    }
    
    func getResponseForUserInput(Message message:String, OnCompletion callback: @escaping (String,Error?) -> ()) {
        
        networkService.getResponseFor(Message: message) { (responseData, error) in
            
            if let _ = error {
                callback("",nil)
                return
            }
            
            if let data = responseData {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                    
                    if let message = parsedData["text"] as? String {
                        callback(message,nil)
                    }else {
                        callback("",nil)
                    }
                }catch {
                    callback("",nil)
                }
            }
        }
    }
}
