//
//  ActiveLabel.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

public typealias EventHyperlink = (code:String, event_doc_id:String)

public protocol ActiveLabelDelegate: class {
    func didSelectText(text: String, type: ActiveType)
}

@IBDesignable public class ActiveLabel: UILabel {
    
    // MARK: - public properties
    var username: String = ""
    var usernameAsTitle: Bool = false
    var eventArray: [EventHyperlink] = []
    public weak var delegate: ActiveLabelDelegate?
    
    @IBInspectable public var mentionEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var hashtagEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var URLEnabled: Bool = true {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var usernameEnabled: Bool = false {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var eventCodeEnabled: Bool = false {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var mentionColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var mentionSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var hashtagColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var hashtagSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var URLColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var URLSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var lineSpacing: Float? {
        didSet {
            updateTextStorage()
        }
    }
    
    //new methods
    @IBInspectable public var usernameColor: UIColor = .blueColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var usernameSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var eventCodeColor: UIColor = .purpleColor() {
        didSet {
            updateTextStorage()
        }
    }
    @IBInspectable public var eventCodeSelectedColor: UIColor? {
        didSet {
            updateTextStorage()
        }
    }
    
    // MARK: - public methods
    public func handleMentionTap(handler: (String) -> ()) {
        mentionTapHandler = handler
    }
    
    public func handleHashtagTap(handler: (String) -> ()) {
        hashtagTapHandler = handler
    }
    
    public func handleURLTap(handler: (NSURL) -> ()) {
        urlTapHandler = handler
    }
    
    public func handleUsernameTap(handler: (String) -> ()) {
        usernameTapHandler = handler
    }
    
    public func handleEventCodeTap(handler: (EventHyperlink) -> ()) {
        eventCodeHandler = handler
    }
    
    // MARK: - override UILabel properties
    override public var text: String? {
        didSet {
            updateTextStorage()
        }
    }
    
    override public var attributedText: NSAttributedString? {
        didSet {
            updateTextStorage()
        }
    }
    
    override public var font: UIFont! {
        didSet {
            updateTextStorage()
        }
    }
    
    override public var textColor: UIColor! {
        didSet {
            updateTextStorage()
        }
    }
    
    override public var textAlignment: NSTextAlignment {
        didSet {
            updateTextStorage()
        }
    }
    
    // MARK: - init functions
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupLabel()
    }
    
    public override func drawTextInRect(rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        
        textContainer.size = rect.size
        let newOrigin = textOrigin(inRect: rect)
        
        layoutManager.drawBackgroundForGlyphRange(range, atPoint: newOrigin)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: newOrigin)
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let currentSize = textContainer.size
        defer {
            textContainer.size = currentSize
        }
        
        textContainer.size = size
        return layoutManager.usedRectForTextContainer(textContainer).size
    }
    
    // MARK: - touch events
    func onTouch(touch: UITouch) -> Bool {
        let location = touch.locationInView(self)
        var avoidSuperCall = false
        
        switch touch.phase {
        case .Began, .Moved:
            if let element = elementAtLocation(location) {
                if element.range.location != selectedElement?.range.location || element.range.length != selectedElement?.range.length {
                    updateAttributesWhenSelected(false)
                    selectedElement = element
                    updateAttributesWhenSelected(true)
                }
                avoidSuperCall = true
            } else {
                updateAttributesWhenSelected(false)
                selectedElement = nil
            }
        case .Cancelled, .Ended:
            guard let selectedElement = selectedElement else { return avoidSuperCall }
            
            switch selectedElement.element {
            case .Mention(let userHandle): didTapMention(userHandle)
            case .Hashtag(let hashtag): didTapHashtag(hashtag)
            case .URL(let url): didTapStringURL(url)
            case .Username(self.username): didTapUsername(self.username)
            case .Username(_): ()
            case .EventCode(let eventHyperlink): didTapEventCode(eventHyperlink)
            case .None: ()
            }
            
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()) {
                self.updateAttributesWhenSelected(false)
                self.selectedElement = nil
            }
            avoidSuperCall = true
        default: ()
        }
        
        return avoidSuperCall
    }
    
    // MARK: - private properties
    private var mentionTapHandler: ((String) -> ())?
    private var hashtagTapHandler: ((String) -> ())?
    private var urlTapHandler: ((NSURL) -> ())?
    private var usernameTapHandler: ((String) -> ())?
    private var eventCodeHandler: ((EventHyperlink) -> ())?
    
    private var selectedElement: (range: NSRange, element: ActiveElement)?
    private var heightCorrection: CGFloat = 0
    private lazy var textStorage = NSTextStorage()
    private lazy var layoutManager = NSLayoutManager()
    private lazy var textContainer = NSTextContainer()
    private lazy var activeElements: [ActiveType: [(range: NSRange, element: ActiveElement)]] = [
        .Mention: [],
        .Hashtag: [],
        .URL: [],
        .Username: [],
        .EventCode: [],
    ]
    
    // MARK: - helper functions
    private func setupLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        userInteractionEnabled = true
    }
    
    private func updateTextStorage() {
        
        //username
        guard let premodifiedText = attributedText?.string else {
            return
        }
        let modifiedAttributedText: NSAttributedString?
        if usernameEnabled {
            modifiedAttributedText = NSAttributedString(string:username + (usernameAsTitle ? "\n" : " ") + premodifiedText)
        } else {
            modifiedAttributedText = attributedText
        }
        
        guard let attributedText = modifiedAttributedText else {
            return
        }
        
        // clean up previous active elements
        for (type, _) in activeElements {
            activeElements[type]?.removeAll()
        }
        
        guard attributedText.length > 0 else {
            return
        }
        
        
        let mutAttrString = addLineBreak(attributedText)
        parseTextAndExtractActiveElements(mutAttrString)
        addLinkAttribute(mutAttrString)
        
        textStorage.setAttributedString(mutAttrString)
        
        setNeedsDisplay()
    }
    
    private func textOrigin(inRect rect: CGRect) -> CGPoint {
        let usedRect = layoutManager.usedRectForTextContainer(textContainer)
        heightCorrection = (rect.height - usedRect.height)/2
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
    }
    
    /// add link attribute
    private func addLinkAttribute(mutAttrString: NSMutableAttributedString) {
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributesAtIndex(0, effectiveRange: &range)
        
        attributes[NSFontAttributeName] = font!
        attributes[NSForegroundColorAttributeName] = textColor
        mutAttrString.addAttributes(attributes, range: range)
        
        attributes[NSForegroundColorAttributeName] = mentionColor
        
        for (type, elements) in activeElements {
            var removeMark: Bool = false
            switch type {
            case .Mention: attributes[NSForegroundColorAttributeName] = mentionColor
            case .Hashtag: attributes[NSForegroundColorAttributeName] = hashtagColor
            case .URL: attributes[NSForegroundColorAttributeName] = URLColor
            case .Username: attributes[NSForegroundColorAttributeName] = usernameColor
            case .EventCode:
                attributes[NSForegroundColorAttributeName] = eventCodeColor
                removeMark = true
            case .None: ()
            }
            
            for element in elements {
                if removeMark {
                    var markAttributes:[String: AnyObject] = [:]
                    markAttributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 0)
                    markAttributes[NSForegroundColorAttributeName] = UIColor.clearColor()
                    mutAttrString.setAttributes(attributes, range: NSMakeRange(element.range.location+1, element.range.length))
                    mutAttrString.setAttributes(markAttributes, range: NSMakeRange(element.range.location, 1))
                } else {
                    mutAttrString.setAttributes(attributes, range: element.range)
                }
            }
        }
    }
    
    /// use regex check all link ranges
    private func parseTextAndExtractActiveElements(attrString: NSAttributedString) {
        let textString = attrString.string as NSString
        let textLength = textString.length
        var searchRange = NSMakeRange(0, textLength)
        
        let words = textString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var eventIndex: Int = 0
        for (index,word) in words.enumerate() {
            let element:ActiveElement
            
            if(index == 0 && word == self.username) {
                //username tag
                element = ActiveElement.Username(self.username)
            } else {
                //other tag
                element = activeElement(word)
            }
    
            if case .None = element  {
                continue
            }
            
            let elementRange = textString.rangeOfString(word, options: .LiteralSearch, range: searchRange)
            defer {
                let startIndex = elementRange.location + elementRange.length
                searchRange = NSMakeRange(startIndex, textLength - startIndex)
            }
            
            switch element {
            case .Mention where mentionEnabled:
                activeElements[.Mention]?.append((elementRange, element))
            case .Hashtag where hashtagEnabled:
                activeElements[.Hashtag]?.append((elementRange, element))
            case .URL where URLEnabled:
                activeElements[.URL]?.append((elementRange, element))
            case .Username where usernameEnabled:
                activeElements[.Username]?.append((elementRange, element))
            case .EventCode(let eventHyperlink) where eventCodeEnabled && eventArray.count > eventIndex:
                let hyperlink = eventArray[eventIndex]
                if hyperlink.code == eventHyperlink.code {
                    activeElements[.EventCode]?.append((NSMakeRange(elementRange.location, elementRange.length-1), ActiveElement.EventCode(code: hyperlink.code,event_doc_id: hyperlink.event_doc_id)))
                    eventIndex++
                }
            default: ()
            }
        }
    }
    
    /// add line break mode
    private func addLineBreak(attrString: NSAttributedString) -> NSMutableAttributedString {
        let mutAttrString = NSMutableAttributedString(attributedString: attrString)
        
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributesAtIndex(0, effectiveRange: &range)
        
        let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = textAlignment
        if let lineSpacing = lineSpacing {
            paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        }
        
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        mutAttrString.setAttributes(attributes, range: range)
        
        return mutAttrString
    }
    
    private func updateAttributesWhenSelected(isSelected: Bool) {
        guard let selectedElement = selectedElement else {
            return
        }
        
        var attributes = textStorage.attributesAtIndex(0, effectiveRange: nil)
        var removeMark: Bool = false
        if isSelected {
            switch selectedElement.element {
            case .Mention(_): attributes[NSForegroundColorAttributeName] = mentionColor
            case .Hashtag(_): attributes[NSForegroundColorAttributeName] = hashtagColor
            case .URL(_): attributes[NSForegroundColorAttributeName] = URLColor
            case .Username(_): attributes[NSForegroundColorAttributeName] = usernameColor
            case .EventCode(_):
                attributes[NSForegroundColorAttributeName] = eventCodeColor
                removeMark = true
            case .None: ()
            }
        } else {
            switch selectedElement.element {
            case .Mention(_): attributes[NSForegroundColorAttributeName] = mentionSelectedColor ?? mentionColor
            case .Hashtag(_): attributes[NSForegroundColorAttributeName] = hashtagSelectedColor ?? hashtagColor
            case .URL(_): attributes[NSForegroundColorAttributeName] = URLSelectedColor ?? URLColor
            case .Username(_): attributes[NSForegroundColorAttributeName] = usernameSelectedColor ?? usernameColor
            case .EventCode(_):
                attributes[NSForegroundColorAttributeName] = eventCodeColor ?? eventCodeSelectedColor
                removeMark = true
            case .None: ()
            }
        }
        
        if removeMark {
            var markAttributes:[String: AnyObject] = [:]
            markAttributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 0)
            markAttributes[NSForegroundColorAttributeName] = UIColor.clearColor()
            textStorage.addAttributes(attributes, range: NSMakeRange(selectedElement.range.location+1, selectedElement.range.length))
            textStorage.addAttributes(markAttributes, range: NSMakeRange(selectedElement.range.location, 1))
        } else {
            textStorage.addAttributes(attributes, range: selectedElement.range)
            
        }
        setNeedsDisplay()
    }
    
    private func elementAtLocation(location: CGPoint) -> (range: NSRange, element: ActiveElement)? {
        guard textStorage.length > 0 else {
            return nil
        }

        var correctLocation = location
        correctLocation.y -= heightCorrection
        let boundingRect = layoutManager.boundingRectForGlyphRange(NSRange(location: 0, length: textStorage.length), inTextContainer: textContainer)
        guard boundingRect.contains(correctLocation) else {
            return nil
        }
        
        let index = layoutManager.glyphIndexForPoint(correctLocation, inTextContainer: textContainer)
        
        for element in activeElements.map({ $0.1 }).flatten() {
            if index >= element.range.location && index <= element.range.location + element.range.length {
                return element
            }
        }
        
        return nil
    }
    
    
    //MARK: - Handle UI Responder touches
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesBegan(touches, withEvent: event)
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touch = touches?.first else { return }
        onTouch(touch)
        super.touchesCancelled(touches, withEvent: event)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesEnded(touches, withEvent: event)
    }
    
    //MARK: - ActiveLabel handler
    private func didTapMention(username: String) {
        guard let mentionHandler = mentionTapHandler else {
            delegate?.didSelectText(username, type: .Mention)
            return
        }
        mentionHandler(username)
    }
    
    private func didTapHashtag(hashtag: String) {
        guard let hashtagHandler = hashtagTapHandler else {
            delegate?.didSelectText(hashtag, type: .Hashtag)
            return
        }
        hashtagHandler(hashtag)
    }
    
    private func didTapStringURL(stringURL: String) {
        guard let urlHandler = urlTapHandler, let url = NSURL(string: stringURL) else {
            delegate?.didSelectText(stringURL, type: .URL)
            return
        }
        urlHandler(url)
    }
    
    private func didTapUsername(username: String) {
        guard let usernameHandler = usernameTapHandler else {
            delegate?.didSelectText(username, type: .Username)
            return
        }
        usernameHandler(username)
    }
    
    private func didTapEventCode(eventHyperlink: EventHyperlink) {
        guard let eventCodeHandler = eventCodeHandler else {
            delegate?.didSelectText(eventHyperlink.event_doc_id, type: .EventCode)
            return
        }
        eventCodeHandler(eventHyperlink)
    }
}

extension ActiveLabel: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
