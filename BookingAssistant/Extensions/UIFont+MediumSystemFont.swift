//
//  UIFont+MediumSystemFont.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import UIKit

extension UIFont {
    
    static func noc_mediumSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        var font: UIFont
        if #available(iOS 8.2, *) {
            font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium)
        } else {
            font = UIFont(name: "HelveticaNeue-Medium", size: fontSize)!
        }
        return font
    }
    
}

