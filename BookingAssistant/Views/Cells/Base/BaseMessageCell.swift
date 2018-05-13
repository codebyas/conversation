//
//  BaseMessageCell.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import NoChat

class BaseMessageCell: NOCChatItemCell {
    
    var bubbleView = UIView()
    
    var isHighlight = false
    
    override class func reuseIdentifier() -> String {
        return "BaseMessageCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        itemView?.addSubview(bubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var layout: NOCChatItemCellLayout? {
        didSet {
            guard let cellLayout = layout as? BaseMessageCellLayout else {
                fatalError("invalid layout type")
            }
            
            bubbleView.frame = cellLayout.bubbleViewFrame
        }
    }
    
}

