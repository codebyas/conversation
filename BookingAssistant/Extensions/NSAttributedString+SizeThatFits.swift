//
//  NSAttributedString+SizeThatFits.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import UIKit

extension NSAttributedString {
    
    func noc_sizeThatFits(size: CGSize) -> CGSize {
        let rect = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading ], context: nil)
        return rect.integral.size
    }
    
}
