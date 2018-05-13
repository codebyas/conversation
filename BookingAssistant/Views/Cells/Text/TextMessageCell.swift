//
//  TextMessageCell.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import NoChat
import YYText

class TextMessageCell: BaseMessageCell {
    
    var bubbleImageView = UIImageView()
    var textLabel = YYLabel()
    var timeLabel = UILabel()
    
    override class func reuseIdentifier() -> String {
        return "TextMessageCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bubbleView.addSubview(bubbleImageView)
        
        textLabel.textVerticalAlignment = .top
        textLabel.displaysAsynchronously = true
        textLabel.ignoreCommonProperties = true
        textLabel.fadeOnAsynchronouslyDisplay = false
        textLabel.fadeOnHighlight = false
        textLabel.highlightTapAction = { [weak self] (containerView, text, range, rect) -> Void in
            if range.location >= text.length { return }
            let highlight = text.yy_attribute(YYTextHighlightAttributeName, at: UInt(range.location)) as! YYTextHighlight
        }
        bubbleView.addSubview(textLabel)
        
        bubbleImageView.addSubview(timeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var layout: NOCChatItemCellLayout? {
        didSet {
            guard let cellLayout = layout as? TextMessageCellLayout else {
                fatalError("invalid layout type")
            }
            
            bubbleImageView.frame = cellLayout.bubbleImageViewFrame
            bubbleImageView.image = isHighlight ? cellLayout.highlightBubbleImage : cellLayout.bubbleImage
            
            textLabel.frame = cellLayout.textLableFrame
            textLabel.textLayout = cellLayout.textLayout
            
            timeLabel.frame = cellLayout.timeLabelFrame
            timeLabel.attributedText = cellLayout.attributedTime
        }
    }
    
}

