//
//  TextMessageCellLayout.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import NoChat
import YYText

class TextMessageCellLayout: BaseMessageCellLayout {
    
    var attributedTime: NSAttributedString?
    var hasTail = false
    var bubbleImage: UIImage?
    var highlightBubbleImage: UIImage?
    
    var bubbleImageViewFrame = CGRect.zero
    var textLableFrame = CGRect.zero
    var textLayout: YYTextLayout?
    var timeLabelFrame = CGRect.zero
    
    private var attributedText: NSMutableAttributedString?
    
    required init(chatItem: NOCChatItem, cellWidth width: CGFloat) {
        super.init(chatItem: chatItem, cellWidth: width)
        reuseIdentifier = "TextMessageCell"
        setupAttributedText()
        setupAttributedTime()
        setupHasTail()
        setupBubbleImage()
        calculate()
    }
    
    private func setupAttributedText() {
        let text = message.text
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font: Style.textFont, NSAttributedStringKey.foregroundColor: Style.textColor])
        
        if text == "/start" {
            attributedText.yy_setColor(Style.linkColor, range: attributedText.yy_rangeOfAll())
            
            let highlightBorder = YYTextBorder()
            highlightBorder.insets = UIEdgeInsets(top: -2, left: 0, bottom: -2, right: 0)
            highlightBorder.cornerRadius = 2
            highlightBorder.fillColor = Style.linkBackgroundColor
            
            let highlight = YYTextHighlight()
            highlight.setBackgroundBorder(highlightBorder)
            highlight.userInfo = ["command": text]
            
            attributedText.yy_setTextHighlight(highlight, range: attributedText.yy_rangeOfAll())
        }
        
        self.attributedText = attributedText
    }
    
    private func setupAttributedTime() {
        let timeString = Style.timeFormatter.string(from: message.date)
        let timeColor = isOutgoing ? Style.outgoingTimeColor : Style.incomingTimeColor
        attributedTime = NSAttributedString(string: timeString, attributes: [NSAttributedStringKey.font: Style.timeFont, NSAttributedStringKey.foregroundColor: timeColor])
    }
    
    private func setupHasTail() {
        hasTail = true
    }
    
    private func setupBubbleImage() {
        bubbleImage = isOutgoing ? (hasTail ? Style.fullOutgoingBubbleImage : Style.partialOutgoingBubbleImage) : (hasTail ? Style.fullIncomingBubbleImage : Style.partialIncomingBubbleImage)
        
        highlightBubbleImage = isOutgoing ? (hasTail ? Style.highlightFullOutgoingBubbleImage : Style.highlightPartialOutgoingBubbleImage) : (hasTail ? Style.highlightFullIncomingBubbleImage : Style.highlightPartialIncomingBubbleImage)
    }
    
    override func calculate() {
        height = 0
        bubbleViewFrame = CGRect.zero
        bubbleImageViewFrame = CGRect.zero
        textLableFrame = CGRect.zero
        textLayout = nil
        timeLabelFrame = CGRect.zero
        
        guard let text = attributedText, text.length > 0, let time = attributedTime else {
            return
        }
        
        // dynamic font support
        let dynamicFont = Style.textFont
        text.yy_setAttribute(NSAttributedStringKey.font.rawValue, value: dynamicFont)
        
        let preferredMaxBubbleWidth = ceil(width * 0.75)
        var bubbleViewWidth = preferredMaxBubbleWidth
        
        // prelayout
        let unlimitSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let timeLabelSize = time.noc_sizeThatFits(size: unlimitSize)
        let timeLabelWidth = timeLabelSize.width
        let timeLabelHeight = CGFloat(15)
        
        
        let hPadding = CGFloat(8)
        let vPadding = CGFloat(4)
        
        let textMargin = isOutgoing ? UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 15) : UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 10)
        var textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right - hPadding - timeLabelWidth - hPadding/2
        
        let modifier = TextLinePositionModifier()
        modifier.font = dynamicFont
        modifier.paddingTop = 2
        modifier.paddingBottom = 2
        
        let container = YYTextContainer()
        container.size = CGSize(width: textLabelWidth, height: CGFloat.greatestFiniteMagnitude)
        container.linePositionModifier = modifier
        
        guard let textLayout = YYTextLayout(container: container, text: text) else {
            return
        }
        self.textLayout = textLayout
        
        var bubbleViewHeight = CGFloat(0)
        if textLayout.rowCount > 1 { // relayout
            textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right
            container.size = CGSize(width: textLabelWidth, height: CGFloat.greatestFiniteMagnitude)
            
            guard let newTextLayout = YYTextLayout(container: container, text: text) else {
                return
            }
            self.textLayout = newTextLayout
            
            // layout content in bubble
            textLabelWidth = ceil(newTextLayout.textBoundingSize.width)
            let textLabelHeight = ceil(modifier.height(forLineCount: newTextLayout.rowCount))
            textLableFrame = CGRect(x: textMargin.left, y: textMargin.top, width: textLabelWidth, height: textLabelHeight)
            
            let tryPoint = CGPoint(x: textLabelWidth - hPadding/2 - timeLabelWidth - hPadding, y: textLabelHeight - timeLabelHeight/2)
            
            let needNewLine = newTextLayout.textRange(at: tryPoint) != nil
            if needNewLine {
                var x = bubbleViewWidth - textMargin.left - hPadding/2 - timeLabelWidth
                var y = textMargin.top + textLabelHeight
                
                y += vPadding
                timeLabelFrame = CGRect(x: x, y: y, width: timeLabelWidth, height: timeLabelHeight)
                
                x += timeLabelWidth + hPadding/2
                
                bubbleViewHeight = textMargin.top + textLabelHeight + vPadding + timeLabelHeight + textMargin.bottom
                bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
                
                bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
                
            } else {
                bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom
                bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
                
                bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
                
                var x = bubbleViewWidth - textMargin.right - hPadding/2 - timeLabelWidth
                let y = bubbleViewHeight - textMargin.bottom - timeLabelHeight
                timeLabelFrame = CGRect(x: x, y: y, width: timeLabelWidth, height: timeLabelHeight)
                
                x += timeLabelWidth + hPadding/2
            }
            
        } else {
            textLabelWidth = ceil(textLayout.textBoundingSize.width)
            let textLabelHeight = ceil(modifier.height(forLineCount: textLayout.rowCount))
            
            bubbleViewWidth = textMargin.left + textLabelWidth + hPadding + timeLabelWidth + hPadding/2  + textMargin.right
            bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom
            bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
            
            bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
            
            var x = textMargin.left
            var y = textMargin.top
            textLableFrame = CGRect(x: x, y: y, width: textLabelWidth, height: textLabelHeight)
            
            x += textLabelWidth + hPadding
            y = bubbleViewHeight - textMargin.bottom - timeLabelHeight
            timeLabelFrame = CGRect(x: x, y: y, width: timeLabelWidth, height: timeLabelHeight)
            
            x += timeLabelWidth + hPadding/2
        }
        
        height = bubbleViewHeight + bubbleViewMargin.top + bubbleViewMargin.bottom
    }
    
    
    struct Style {
        static let fullOutgoingBubbleImage = UIImage(named: "BubbleOutgoingFull")!
        static let highlightFullOutgoingBubbleImage = UIImage(named: "BubbleOutgoingFullHL")!
        static let partialOutgoingBubbleImage = UIImage(named: "BubbleOutgoingPartial")!
        static let highlightPartialOutgoingBubbleImage = UIImage(named: "BubbleOutgoingPartialHL")!
        static let fullIncomingBubbleImage = UIImage(named: "BubbleIncomingFull")!
        static let highlightFullIncomingBubbleImage = UIImage(named: "BubbleIncomingFullHL")!
        static let partialIncomingBubbleImage = UIImage(named: "BubbleIncomingPartial")!
        static let highlightPartialIncomingBubbleImage = UIImage(named: "BubbleIncomingPartialHL")!
        
        static var textFont: UIFont {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        static let textColor = UIColor.black
        
        static let linkColor =  UIColor(red: 0/255.0, green: 75/255.0, blue: 173/255.0, alpha: 1)
        static let linkBackgroundColor = UIColor(red: 191/255.0, green: 223/255.0, blue: 254/255.0, alpha: 1)
        
        static let timeFont = UIFont.systemFont(ofSize: 12)
        static let outgoingTimeColor = UIColor(red: 59/255.0, green: 171/255.0, blue: 61/255.0, alpha: 1)
        static let incomingTimeColor = UIColor.gray
        static let timeFormatter: DateFormatter = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US")
            df.dateFormat = "h:mm a"
            return df
        }()
    }
    
}

fileprivate
class TextLinePositionModifier: NSObject, YYTextLinePositionModifier {
    
    var font = UIFont.systemFont(ofSize: 16)
    var paddingTop = CGFloat(0)
    var paddingBottom = CGFloat(0)
    var lineHeightMultiple = CGFloat(0)
    
    override init() {
        super.init()
        
        if #available(iOS 9.0, *) {
            lineHeightMultiple = 1.34 // for PingFang SC
        } else {
            lineHeightMultiple = 1.3125 // for Heiti SC
        }
    }
    
    fileprivate func modifyLines(_ lines: [YYTextLine], fromText text: NSAttributedString, in container: YYTextContainer) {
        let ascent = font.pointSize * 0.86
        
        let lineHeight = font.pointSize * lineHeightMultiple
        for line in lines {
            var position = line.position
            position.y = paddingTop + ascent + CGFloat(line.row) * lineHeight
            line.position = position
        }
    }
    
    fileprivate func copy(with zone: NSZone? = nil) -> Any {
        let one = TextLinePositionModifier()
        one.font = font
        one.paddingTop = paddingTop
        one.paddingBottom = paddingBottom
        one.lineHeightMultiple = lineHeightMultiple
        return one
    }
    
    fileprivate func height(forLineCount lineCount: UInt) -> CGFloat {
        if lineCount == 0 {
            return 0
        }
        let ascent = font.pointSize * 0.86
        let descent = font.pointSize * 0.14
        let lineHeight = font.pointSize * lineHeightMultiple
        return paddingTop + paddingBottom + ascent + descent + CGFloat(lineCount - 1) * lineHeight
    }
}

