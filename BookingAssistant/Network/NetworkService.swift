//
//  NetworkService.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import Foundation

class NetworkService {
    
    func getResponseFor(Message message:String, OnCompletion callback:@escaping (_ responseData:Data?,_ error:Error?)->())  {
        
        let endpoint = "https://calm-badlands-26123.herokuapp.com/message"
        
        guard let endpointUrl = URL(string: endpoint) else {
            return
        }
        
        var json = [String:Any]()
        json["text"] = message
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (responseData, urlResponse, err) in
              
                if let data = responseData {
                    callback(data,nil)
                }
                
                print(urlResponse)
                print(err)
            })
            
            task.resume()
        }catch{
        }
    }
}
