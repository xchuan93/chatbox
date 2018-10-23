//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import UIKit
import Cartography
import Classy
import WireExtensionComponents
import Marklight

extension Settings {
    var returnKeyType: UIReturnKeyType {
        return disableSendButton ? .send : .default
    }
}

public enum InputBarState: Equatable {
    case writing(ephemeral: Bool)
    case editing(originalText: String)
    case markingDown

    var isWriting: Bool {
        switch self {
        case .writing(ephemeral: _): return true
        default: return false
        }
    }

    var isEditing: Bool {
        switch self {
        case .editing(originalText: _): return true
        default: return false
        }
    }
    
    var isMarkingDown: Bool {
        switch self {
        case .markingDown: return true
        default: return false
        }
    }
    
    var isEphemeral: Bool {
        if case .writing(let ephemeral) = self {
            return ephemeral
        } else {
            return false
        }
    }
}

public func ==(lhs: InputBarState, rhs: InputBarState) -> Bool {
    switch (lhs, rhs) {
    case (.writing, .writing): return true
    case (.editing(let lhsText), .editing(let rhsText)): return lhsText == rhsText
    default: return false
    }
}

private struct InputBarConstants {
    let buttonsBarHeight: CGFloat = 56
    let contentLeftMargin = WAZUIMagic.cgFloat(forIdentifier: "content.left_margin")
    let contentRightMargin = WAZUIMagic.cgFloat(forIdentifier: "content.right_margin")
}

@objc public final class InputBar: UIView {

    private let inputBarVerticalInset : CGFloat = 34


    public let textView = MarklightTextView()
    public let leftAccessoryView  = UIView()
    public let rightAccessoryView = UIView()
    
    // Contains and clips the buttonInnerContainer
    public let buttonContainer = UIView()
    
    // Contains editingView and mardownView
    public let secondaryButtonsView: InputBarSecondaryButtonsView
    
    public let buttonsView: InputBarButtonsView
    public let editingView = InputBarEditView()
    public let markdownView = MarkdownBarView()
    
    
    public var editingBackgroundColor: UIColor?
    public var barBackgroundColor: UIColor?
    public var writingSeparatorColor: UIColor?
    public var ephemeralColor: UIColor?
    public var placeholderColor: UIColor?

    fileprivate var rowTopInsetConstraint: NSLayoutConstraint? = nil
    
    // Contains the secondaryButtonsView and buttonsView
    fileprivate let buttonInnerContainer = UIView()
    fileprivate let fakeCursor = UIView()
    fileprivate let buttonRowSeparator = UIView()
    fileprivate let constants = InputBarConstants()
    fileprivate let notificationCenter = NotificationCenter.default
    
    var isEditing: Bool {
        return inputBarState.isEditing
    }
    
    var isMarkingDown: Bool {
        return inputBarState.isMarkingDown
    }
    
    private var inputBarState: InputBarState = .writing(ephemeral: false)
    
    public var invisibleInputAccessoryView : InvisibleInputAccessoryView? = nil  {
        didSet {
            textView.inputAccessoryView = invisibleInputAccessoryView
        }
    }
    
    public var availabilityPlaceholder : NSAttributedString? {
        didSet {
            updatePlaceholder()
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            invisibleInputAccessoryView?.intrinsicContentSize = CGSize(width: UIViewNoIntrinsicMetric, height: bounds.height)
        }
    }
        
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        // This is a workaround for UITextView truncating long contents.
        // However, this breaks the text view on iOS 8 ¯\_(ツ)_/¯.
        if #available(iOS 9, *) {
            textView.isScrollEnabled = false
            textView.isScrollEnabled = true
        }
        startCursorBlinkAnimation()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    required public init(buttons: [UIButton]) {
        buttonsView = InputBarButtonsView(buttons: buttons)
        secondaryButtonsView = InputBarSecondaryButtonsView(editBarView: editingView, markdownBarView: markdownView)
        
        super.init(frame: CGRect.zero)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        addGestureRecognizer(tapGestureRecognizer)
        buttonsView.clipsToBounds = true
        buttonContainer.clipsToBounds = true
        
        [leftAccessoryView, textView, rightAccessoryView, buttonContainer, buttonRowSeparator].forEach(addSubview)
        buttonContainer.addSubview(buttonInnerContainer)
        [buttonsView, secondaryButtonsView].forEach(buttonInnerContainer.addSubview)
        textView.addSubview(fakeCursor)
        CASStyler.default().styleItem(self)

        setupViews()
        createConstraints()
        
        notificationCenter.addObserver(self, selector: #selector(textViewDidChangeSelection), name: Notification.Name(rawValue: MarklightTextViewDidChangeSelectionNotification), object: textView)
        notificationCenter.addObserver(self, selector: #selector(textViewTextDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: textView)
        notificationCenter.addObserver(self, selector: #selector(textViewDidBeginEditing), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        notificationCenter.addObserver(self, selector: #selector(textViewDidEndEditing), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        textView.accessibilityIdentifier = "inputField"
        updatePlaceholder()
        textView.lineFragmentPadding = 0
        textView.textAlignment = .natural
        textView.textContainerInset = UIEdgeInsetsMake(inputBarVerticalInset / 2, 0, inputBarVerticalInset / 2, 4)
        textView.placeholderTextContainerInset = UIEdgeInsetsMake(21, 10, 21, 0)
        textView.keyboardType = .default
        textView.keyboardAppearance = ColorScheme.default().keyboardAppearance
        textView.placeholderTextTransform = .upper
        textView.tintAdjustmentMode = .automatic
        
        // we don't want large fonts in message text view
        let headerFont = FontSpec(.normal, .medium).font!
        textView.style.h1HeadingAttributes[NSFontAttributeName] = headerFont
        textView.style.h2HeadingAttributes[NSFontAttributeName] = headerFont
        textView.style.h3HeadingAttributes[NSFontAttributeName] = headerFont
        
        markdownView.delegate = textView

        updateReturnKey()

        updateInputBar(withState: inputBarState, animated: false)
        updateColors()
    }
    
    fileprivate func createConstraints() {
        
        constrain(buttonContainer, textView, buttonRowSeparator, leftAccessoryView, rightAccessoryView) { buttonContainer, textView, buttonRowSeparator, leftAccessoryView, rightAccessoryView in
            leftAccessoryView.leading == leftAccessoryView.superview!.leading
            leftAccessoryView.top == leftAccessoryView.superview!.top
            leftAccessoryView.bottom == buttonContainer.top
            leftAccessoryView.width == constants.contentLeftMargin

            rightAccessoryView.trailing == rightAccessoryView.superview!.trailing
            rightAccessoryView.top == rightAccessoryView.superview!.top
            rightAccessoryView.width == 0 ~ 750.0
            rightAccessoryView.bottom == buttonContainer.top
            
            buttonContainer.top == textView.bottom
            textView.top == textView.superview!.top
            textView.leading == leftAccessoryView.trailing
            textView.trailing <= textView.superview!.trailing - 16
            textView.trailing == rightAccessoryView.leading ~ 750.0
            textView.height >= 56
            textView.height <= 120 ~ 1000.0

            buttonRowSeparator.top == buttonContainer.top
            buttonRowSeparator.leading == buttonRowSeparator.superview!.leading + 16
            buttonRowSeparator.trailing == buttonRowSeparator.superview!.trailing - 16
            buttonRowSeparator.height == .hairline
        }
        
        constrain(secondaryButtonsView, buttonsView, buttonInnerContainer) { secondaryButtonsView, buttonsView, buttonInnerContainer in
            secondaryButtonsView.top == buttonInnerContainer.top
            secondaryButtonsView.leading == buttonInnerContainer.leading
            secondaryButtonsView.trailing == buttonInnerContainer.trailing
            secondaryButtonsView.bottom == buttonsView.top
            secondaryButtonsView.height == constants.buttonsBarHeight
            
            buttonsView.leading == buttonInnerContainer.leading
            buttonsView.trailing <= buttonInnerContainer.trailing
            buttonsView.bottom == buttonInnerContainer.bottom
        }
        
        constrain(buttonContainer, buttonInnerContainer)  { container, innerContainer in
            container.bottom == container.superview!.bottom
            container.leading == container.superview!.leading
            container.trailing == container.superview!.trailing
            container.height == constants.buttonsBarHeight

            innerContainer.leading == container.leading
            innerContainer.trailing == container.trailing
            self.rowTopInsetConstraint = innerContainer.top == container.top - constants.buttonsBarHeight
        }
        
        constrain(fakeCursor) { fakeCursor in
            fakeCursor.width == 2
            fakeCursor.height == 23
            fakeCursor.centerY == fakeCursor.superview!.centerY
            fakeCursor.leading == fakeCursor.superview!.leading
        }
    }
    
    @objc fileprivate func didTapBackground(_ gestureRecognizer: UITapGestureRecognizer!) {
        guard gestureRecognizer.state == .recognized else { return }
        buttonsView.showRow(0, animated: true)
    }
    
    fileprivate func startCursorBlinkAnimation() {
        if fakeCursor.layer.animation(forKey: "blinkAnimation") == nil {
            fakeCursor.layer.add(.cursorBlinkAnimation(), forKey: "blinkAnimation")
        }
    }

    public func updateReturnKey() {
        textView.returnKeyType = isMarkingDown ? .default : Settings.shared().returnKeyType
        textView.reloadInputViews()
    }

    func updatePlaceholder() {
        textView.attributedPlaceholder = placeholderText(for: inputBarState)
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
    }

    func placeholderText(for state: InputBarState) -> NSAttributedString? {
        
        var placeholder = NSAttributedString(string: "conversation.input_bar.placeholder".localized)
        
        if let availabilityPlaceholder = availabilityPlaceholder {
            placeholder = availabilityPlaceholder
        } else if inputBarState.isEphemeral {
            placeholder  = NSAttributedString(string: "conversation.input_bar.placeholder_ephemeral".localized)
        }
        
        if case .editing = state {
            return nil
        } else {
            return placeholder
        }
    }
    
    func updateFakeCursorVisibility(_ firstResponder: UIResponder? = nil) {
        fakeCursor.isHidden = textView.isFirstResponder || textView.text.count != 0 || firstResponder != nil
    }

    // MARK: - Disable interactions on the lower part to not to interfere with the keyboard
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.textView.isFirstResponder {
            if super.point(inside: point, with: event) {
                let locationInButtonRow = buttonInnerContainer.convert(point, from: self)
                return locationInButtonRow.y < buttonInnerContainer.bounds.height / 1.3
            }
            else {
                return false
            }
        }
        else {
            return super.point(inside: point, with: event)
        }
    }

    // MARK: - InputBarState

    public func setInputBarState(_ state: InputBarState, animated: Bool) {
        let oldState = inputBarState
        inputBarState = state
        updateInputBar(withState: state, oldState: oldState, animated: animated)
    }

    private func updateInputBar(withState state: InputBarState, oldState: InputBarState? = nil, animated: Bool = true) {
        updateEditViewState()
        updatePlaceholder()
        updateReturnKey()
        rowTopInsetConstraint?.constant = state.isWriting ? -constants.buttonsBarHeight : 0

        let textViewChanges = {
            switch state {
            case .writing:
                if let oldState = oldState, oldState.isEditing {
                    self.textView.text = nil
                }
            case .editing(let text):
                self.setInputBarText(text)
                self.secondaryButtonsView.setEditBarView()
            
            case .markingDown:
                self.secondaryButtonsView.setMarkdownBarView()
            }
        }
        
        let completion: (Bool) -> Void = { _ in
            self.updateColors()
            if case .editing(_) = state {
                self.textView.becomeFirstResponder()
            }
        }

        if animated && self.superview != nil {
            UIView.wr_animate(easing: RBBEasingFunctionEaseInOutExpo, duration: 0.3, animations: layoutIfNeeded)
            UIView.transition(with: self.textView, duration: 0.1, options: [], animations: textViewChanges) { _ in
                self.updateColors()
            }
        } else {
            layoutIfNeeded()
            textViewChanges()
            completion(true)
        }
    }

    public func updateEphemeralState() {
        guard inputBarState.isWriting else { return }
        updateColors()
        updatePlaceholder()
    }

    fileprivate func backgroundColor(forInputBarState state: InputBarState) -> UIColor? {
        guard let writingColor = barBackgroundColor, let editingColor = editingBackgroundColor else { return nil }
        return state.isWriting || state.isMarkingDown ? writingColor : writingColor.mix(editingColor, amount: 0.16)
    }
    
    fileprivate func updateColors() {
        backgroundColor = backgroundColor(forInputBarState: inputBarState)
        buttonRowSeparator.backgroundColor = writingSeparatorColor
        textView.placeholderTextColor = self.inputBarState.isEphemeral && self.availabilityPlaceholder == nil ? ephemeralColor : placeholderColor
        fakeCursor.backgroundColor = .accent()
        textView.tintColor = .accent()
        
        var buttons = self.buttonsView.buttons
        
        buttons.append(self.buttonsView.expandRowButton)
        
        buttons.forEach { button in
            guard let button = button as? IconButton else {
                return
            }
            
            if self.inputBarState.isEphemeral {
                button.setIconColor(UIColor.accent(), for: .normal)
                button.setIconColor(ColorScheme.default().color(withName: ColorSchemeColorIconNormal), for: .highlighted)
            }
            else {
                button.setIconColor(ColorScheme.default().color(withName: ColorSchemeColorIconNormal), for: .normal)
                button.setIconColor(ColorScheme.default().color(withName: ColorSchemeColorIconHighlighted), for: .highlighted)
            }
        }
    }

    // MARK: – Editing View State

    open func setInputBarText(_ text: String) {
        textView.text = text
        textView.setContentOffset(.zero, animated: false)
        textView.undoManager?.removeAllActions()
        updateEditViewState()
    }

    open func undo() {
        guard inputBarState.isEditing else { return }
        guard let undoManager = textView.undoManager , undoManager.canUndo else { return }
        undoManager.undo()
        updateEditViewState()
    }

    fileprivate func updateEditViewState() {
        if case .editing(let text) = inputBarState {
            let canUndo = textView.undoManager?.canUndo ?? false
            editingView.undoButton.isEnabled = canUndo

            // We do not want to enable the confirm button when
            // the text is the same as the original message
            let trimmedText = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let hasChanges = text != trimmedText && canUndo
            editingView.confirmButton.isEnabled = hasChanges
        }
    }
}

extension InputBar {

    func textViewTextDidChange(_ notification: Notification) {
        updateFakeCursorVisibility()
        updateEditViewState()
        markdownView.updateIconsForModes(textView.markdownElementsForRange(nil))
    }
    
    func textViewDidBeginEditing(_ notification: Notification) {
        updateFakeCursorVisibility(notification.object as? UIResponder)
        updateEditViewState()
    }
    
    func textViewDidEndEditing(_ notification: Notification) {
        updateFakeCursorVisibility()
        updateEditViewState()
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
        markdownView.updateIconsForModes(textView.markdownElementsForRange(nil))
    }
}

extension InputBar {
    func applicationDidBecomeActive(_ notification: Notification) {
        startCursorBlinkAnimation()
    }
}
