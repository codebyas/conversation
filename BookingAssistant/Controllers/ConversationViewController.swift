//
//  ConversationViewController.swift
//  BookingAssistant
//
//  Created by Ashish on 12/05/18.
//

import UIKit
import NoChat

class ConversationViewController: NOCChatViewController,ChatInputTextPanelDelegate {

    let messageManager = MessageManager()
    
    var layoutQueue = DispatchQueue(label: "com.assistant.conversation.layout", qos: DispatchQoS(qosClass: .default, relativePriority: 0))
    
    // MARK: Overrides
    
    override class func cellLayoutClass(forItemType type: String) -> Swift.AnyClass? {
        if type == "Text" {
            return TextMessageCellLayout.self
        }  else {
            return nil
        }
    }
    
    override class func inputPanelClass() -> Swift.AnyClass? {
        return ChatInputTextPanel.self
    }
    
    override func registerChatItemCells() {
        collectionView?.register(TextMessageCell.self, forCellWithReuseIdentifier: TextMessageCell.reuseIdentifier())
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        registerContentSizeCategoryDidChangeNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        unregisterContentSizeCategoryDidChangeNotification()
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.startConversationWithWelcomeMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func refresh() {
        
        self.layouts.removeAllObjects()
        collectionView!.reloadData()
        
        self.startConversationWithWelcomeMessage()
    }
    
    // MARK: Methods
    
    func startConversationWithWelcomeMessage() {
        
        messageManager.getWelcomeMessage { (msg, error) in
            
            if msg.count > 0 {
                let message = Message()
                message.text = msg
                message.isOutgoing = false
                self.addMessages([message], scrollToBottom: true, animated: true)
            }
        }
    }

    // MARK: TGChatInputTextPanelDelegate
    
    func inputTextPanel(_ inputTextPanel: ChatInputTextPanel, requestSendText text: String) {
        let msg = Message()
        msg.text = text
        sendMessage(msg)
    }
    
    private func sendMessage(_ message: Message) {
        message.isOutgoing = true
        
        addMessages([message], scrollToBottom: true, animated: true)
        
        messageManager.getResponseForUserInput(Message: message.text) { (msg, err) in
            
            if msg.count > 0 {
                let message = Message()
                message.text = msg
                message.isOutgoing = false
                self.addMessages([message], scrollToBottom: true, animated: true)
            }
        }
    }
    
    private func addMessages(_ messages: [Message], scrollToBottom: Bool, animated: Bool) {
        layoutQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            let indexes = IndexSet(integersIn: 0..<messages.count)
            
            var layouts = [NOCChatItemCellLayout]()
            
            for message in messages {
                let layout = strongSelf.createLayout(with: message)!
                layouts.insert(layout, at: 0)
            }
            
            DispatchQueue.main.async {
                strongSelf.insertLayouts(layouts, at: indexes, animated: animated)
                if scrollToBottom {
                    strongSelf.scrollToBottom(animated: animated)
                }
            }
        }
    }
    
    // MARK: Dynamic font support
    
    private func registerContentSizeCategoryDidChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged(notification:)), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    private func unregisterContentSizeCategoryDidChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    @objc private func handleContentSizeCategoryDidChanged(notification: Notification) {
        if isViewLoaded == false {
            return
        }
        
        if layouts.count == 0 {
            return
        }
        
        // ajust collection display
        
        let collectionViewSize = containerView!.bounds.size
        
        let anchorItem = calculateAnchorItem()
        
        for layout in layouts {
            (layout as! NOCChatItemCellLayout).calculate()
        }
        
        collectionLayout!.invalidateLayout()
        
        let cellLayouts = layouts.map { $0 as! NOCChatItemCellLayout }
        
        var newContentHeight = CGFloat(0)
        let newLayoutAttributes = collectionLayout!.layoutAttributes(for: cellLayouts, containerWidth: collectionViewSize.width, maxHeight: CGFloat.greatestFiniteMagnitude, contentHeight: &newContentHeight)
        
        var newContentOffset = CGPoint.zero
        newContentOffset.y = -collectionView!.contentInset.top
        if anchorItem.index >= 0 && anchorItem.index < newLayoutAttributes.count {
            let attributes = newLayoutAttributes[anchorItem.index]
            newContentOffset.y += attributes.frame.origin.y - floor(anchorItem.offset * attributes.frame.height)
        }
        newContentOffset.y = min(newContentOffset.y, newContentHeight + collectionView!.contentInset.bottom - collectionView!.frame.height)
        newContentOffset.y = max(newContentOffset.y, -collectionView!.contentInset.top)
        
        collectionView!.reloadData()
        
        collectionView!.contentOffset = newContentOffset
    }
    
    typealias AnchorItem = (index: Int, originY: CGFloat, offset: CGFloat, height: CGFloat)
    private func calculateAnchorItem() -> AnchorItem {
        let maxOriginY = collectionView!.contentOffset.y + collectionView!.contentInset.top
        let previousCollectionFrame = collectionView!.frame
        
        var itemIndex = Int(-1)
        var itemOriginY = CGFloat(0)
        var itemOffset = CGFloat(0)
        var itemHeight = CGFloat(0)
        
        let cellLayouts = layouts.map { $0 as! NOCChatItemCellLayout }
        
        let previousLayoutAttributes = collectionLayout!.layoutAttributes(for: cellLayouts, containerWidth: previousCollectionFrame.width, maxHeight: CGFloat.greatestFiniteMagnitude, contentHeight: nil)
        
        for i in 0..<layouts.count {
            let attributes = previousLayoutAttributes[i]
            let itemFrame = attributes.frame
            
            if itemFrame.origin.y < maxOriginY {
                itemHeight = itemFrame.height
                itemIndex = i
                itemOriginY = itemFrame.origin.y
            }
        }
        
        if itemIndex != -1 {
            if itemHeight > 1 {
                itemOffset = (itemOriginY - maxOriginY) / itemHeight
            }
        }
        
        return (itemIndex, itemOriginY, itemOffset, itemHeight)
    }
}

