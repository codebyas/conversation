//
//  ChatInputTextPanel.swift
//  BookingAssistant
//
//  Created by Techjini on 13/05/18.
//

import NoChat
import HPGrowingTextView

protocol ChatInputTextPanelDelegate: NOCChatInputPanelDelegate {
    func inputTextPanel(_ inputTextPanel: ChatInputTextPanel, requestSendText text: String)
}

private let RetinaPixel = CGFloat(0.5)
private let EPSILON = CGFloat(0.0001)

class ChatInputTextPanel: NOCChatInputPanel, HPGrowingTextViewDelegate {
    
    var stripeLayer: CALayer!
    var backgroundView: UIView!
    
    var inputField: HPGrowingTextView!
    var inputFiledClippingContainer: UIView!
    var fieldBackground: UIImageView!
    
    var sendButton: UIButton!
    
    private var sendButtonWidth = CGFloat(0)
    private let inputFiledInsets = UIEdgeInsets(top: 9, left: 9, bottom: 8, right: 0)
    private let inputFiledInternalEdgeInsets = UIEdgeInsets(top: -3 - RetinaPixel, left: 0, bottom: 0, right: 0)
    private let baseHeight = CGFloat(45)
    
    private var parentSize = CGSize.zero
    
    private var messageAreaSize = CGSize.zero
    private var keyboardHeight = CGFloat(0)
    
    override init(frame: CGRect) {
        sendButtonWidth = min(150, (NSLocalizedString("Send", comment: "") as NSString).size(withAttributes: [NSAttributedStringKey.font: UIFont.noc_mediumSystemFont(ofSize: 17)]).width + 8)
        
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        
        stripeLayer = CALayer()
        stripeLayer.backgroundColor = UIColor(red: 179/255.0, green: 170/255.0, blue: 178/255.0, alpha: 1).cgColor
        
        let filedBackgroundImage = UIImage(named: "InputFieldBackground")!
        fieldBackground = UIImageView(image: filedBackgroundImage)
        fieldBackground.frame = CGRect(x: 9, y: 9, width: frame.width - 9 - sendButtonWidth - 1, height: 28)
        
        let inputFiledClippingFrame = fieldBackground.frame
        inputFiledClippingContainer = UIView(frame: inputFiledClippingFrame)
        inputFiledClippingContainer.clipsToBounds = true
        
        inputField = HPGrowingTextView(frame: CGRect(x: inputFiledInternalEdgeInsets.left, y: inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - inputFiledInternalEdgeInsets.left, height: inputFiledClippingFrame.height))
        inputField.placeholder = NSLocalizedString("Message", comment: "")
        inputField.animateHeightChange = false
        inputField.animationDuration = 0
        inputField.font = UIFont.systemFont(ofSize: 16)
        inputField.backgroundColor = UIColor.clear
        inputField.isOpaque = false
        inputField.clipsToBounds = true
        inputField.internalTextView.backgroundColor = UIColor.clear
        inputField.internalTextView.isOpaque = false
        inputField.internalTextView.contentMode = .left
        inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsets(top: -inputFiledInternalEdgeInsets.top, left: 0, bottom: 5 - RetinaPixel, right: 0)
        
        sendButton = UIButton(type: .system)
        sendButton.isExclusiveTouch = true
        sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        sendButton.setTitleColor(UIColor(red: 0/255.0, green: 126/255.0, blue: 229/255.0, alpha: 1), for: .normal)
        sendButton.setTitleColor(UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1), for: .disabled)
        sendButton.titleLabel?.font = UIFont.noc_mediumSystemFont(ofSize: 17)
        sendButton.isEnabled = false
        
        super.init(frame: frame)
        
        addSubview(backgroundView)
        layer.addSublayer(stripeLayer)
        addSubview(fieldBackground)
        addSubview(inputFiledClippingContainer)
        
        inputField.maxNumberOfLines = maxNumberOfLines(forSize: parentSize)
        inputField.delegate = self
        inputFiledClippingContainer.addSubview(inputField)
        
        sendButton.addTarget(self, action: #selector(didTapSendButton(_:)), for: .touchUpInside)
        
        addSubview(sendButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        
        stripeLayer.frame = CGRect(x: 0, y: -RetinaPixel, width: bounds.width, height: RetinaPixel)
        
        fieldBackground.frame = CGRect(x: inputFiledInsets.left, y: inputFiledInsets.top, width: bounds.width - inputFiledInsets.left - inputFiledInsets.right - sendButtonWidth - 1, height: bounds.height - inputFiledInsets.top - inputFiledInsets.bottom)
        
        inputFiledClippingContainer.frame = fieldBackground.frame
        
        sendButton.frame = CGRect(x: bounds.width - sendButtonWidth, y: bounds.height - baseHeight, width: sendButtonWidth, height: baseHeight)
        
    }
    
    override func endInputting(_ animated: Bool) {
        if inputField.internalTextView.isFirstResponder {
            inputField.internalTextView.resignFirstResponder()
        }
    }
    
    override func adjust(for size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval, animationCurve: Int32) {
        let previousSize = parentSize
        parentSize = size
        
        if abs(size.width - previousSize.width) > EPSILON {
            change(to: size, keyboardHeight: keyboardHeight, duration: 0)
        }
        
        adjust(for: size, keyboardHeight: keyboardHeight, inputFiledHeight: inputField.frame.height, duration: duration, animationCurve: animationCurve)
    }
    
    override func change(to size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval) {
        parentSize = size
        
        let messageAreaSize = size
        
        self.messageAreaSize = messageAreaSize
        self.keyboardHeight = keyboardHeight
        
        var inputFieldSnapshotView: UIView?
        if duration > .ulpOfOne {
            inputFieldSnapshotView = inputField.internalTextView.snapshotView(afterScreenUpdates: false)
            if let v = inputFieldSnapshotView {
                v.frame = inputField.frame.offsetBy(dx: inputFiledClippingContainer.frame.origin.x, dy: inputFiledClippingContainer.frame.origin.y)
                addSubview(v)
            }
        }
        
        UIView.performWithoutAnimation {
            self.updateInputFiledLayout()
        }
        
        let inputContainerHeight = heightForInputFiledHeight(inputField.frame.size.height)
        let newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        
        if duration > .ulpOfOne {
            if inputFieldSnapshotView != nil {
                inputField.alpha = 0
            }
            
            UIView.animate(withDuration: duration, animations: {
                self.frame = newInputContainerFrame
                self.layoutSubviews()
                
                if let v = inputFieldSnapshotView {
                    self.inputField.alpha = 1
                    v.frame = self.inputField.frame.offsetBy(dx: self.inputFiledClippingContainer.frame.origin.x, dy: self.inputFiledClippingContainer.frame.origin.y)
                    v.alpha = 0
                }
            }, completion: { (_) in
                inputFieldSnapshotView?.removeFromSuperview()
            })
        } else {
            frame = newInputContainerFrame
        }
    }
    
    func toggleSendButtonEnabled() {
        let hasText = inputField.internalTextView.hasText
        sendButton.isEnabled = hasText
        sendButton.alpha = hasText ? 1.0 : 0.5
    }
    
    func clearInputField() {
        inputField.internalTextView.text = nil
        inputField.refreshHeight()
        
        toggleSendButtonEnabled()
    }
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        let inputContainerHeight = heightForInputFiledHeight(CGFloat(height))
        let newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.frame = newInputContainerFrame
            self.layoutSubviews()
        }
        
        delegate?.inputPanel(self, willChangeHeight: inputContainerHeight, duration: 0.3, animationCurve: 0)
    }
    
    func growingTextViewDidChange(_ growingTextView: HPGrowingTextView!) {
        toggleSendButtonEnabled()
    }
    
    @objc func didTapSendButton(_ sender: UIButton) {
        guard let text = inputField.internalTextView.text else {
            return
        }
        
        let str = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if str.characters.count > 0 {
            if let d = delegate as? ChatInputTextPanelDelegate {
                d.inputTextPanel(self, requestSendText: str)
            }
            clearInputField()
        }
    }
    
    private func adjust(for size: CGSize, keyboardHeight: CGFloat, inputFiledHeight: CGFloat, duration: TimeInterval, animationCurve: Int32) {
        let block = {
            let messageAreaSize = size
            
            self.messageAreaSize = messageAreaSize
            self.keyboardHeight = keyboardHeight
            
            let inputContainerHeight = self.heightForInputFiledHeight(inputFiledHeight)
            self.frame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: self.messageAreaSize.width, height: inputContainerHeight)
            self.layoutSubviews()
        }
        
        if duration > .ulpOfOne {
            UIView .animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)), animations: block, completion: nil)
        } else {
            block()
        }
    }
    
    private func heightForInputFiledHeight(_ inputFiledHeight: CGFloat) -> CGFloat {
        return max(baseHeight, inputFiledHeight - 8 + inputFiledInsets.top + inputFiledInsets.bottom)
    }
    
    private func updateInputFiledLayout() {
        let range = inputField.internalTextView.selectedRange
        
        inputField.delegate = nil
        
        let inputFiledInsets = self.inputFiledInsets
        let inputFiledInternalEdgeInsets = self.inputFiledInternalEdgeInsets
        
        let inputFiledClippingFrame = CGRect(x: inputFiledInsets.left, y: inputFiledInsets.top, width: parentSize.width - inputFiledInsets.left - inputFiledInsets.right - sendButtonWidth - 1, height: 0)
        
        let inputFieldFrame = CGRect(x: inputFiledInternalEdgeInsets.left, y: inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - inputFiledInternalEdgeInsets.left, height: 0)
        
        inputField.frame = inputFieldFrame
        inputField.internalTextView.frame = CGRect(x: 0, y: 0, width: inputFieldFrame.width, height: inputFieldFrame.height)
        
        inputField.maxNumberOfLines = maxNumberOfLines(forSize: parentSize)
        inputField.refreshHeight()
        
        inputField.internalTextView.selectedRange = range
        
        inputField.delegate = self
    }
    
    private func maxNumberOfLines(forSize size: CGSize) -> Int32 {
        if size.height <= 320 {
            return 3
        } else if (size.height <= 480) {
            return 5;
        } else {
            return 7
        }
    }
    
}

