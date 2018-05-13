//
//  Message.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import Foundation
import NoChat

class Message: NSObject, NOCChatItem {
    
    var msgId: String = UUID().uuidString
    var msgType: String = "Text"
    
    var date: Date = Date()
    var text: String = ""
    
    var isOutgoing: Bool = true
    
    public func uniqueIdentifier() -> String {
        return self.msgId;
    }
    
    public func type() -> String {
        return self.msgType
    }
    
}

