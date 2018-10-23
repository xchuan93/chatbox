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

import Cartography

@objc public enum EditButtonType: UInt {
    case undo, confirm, cancel
}

@objc public protocol InputBarEditViewDelegate: class {
    func inputBarEditView(_ editView: InputBarEditView, didTapButtonWithType buttonType: EditButtonType)
    func inputBarEditViewDidLongPressUndoButton(_ editView: InputBarEditView)
}

public final class InputBarEditView: UIView {

    let undoButton = IconButton()
    let confirmButton = IconButton()
    let cancelButton = IconButton()
    let iconSize: CGFloat = UIImage.size(for: .tiny)
    
    public weak var delegate: InputBarEditViewDelegate?
    
    public init() {
        super.init(frame: .zero)
        configureViews()
        createConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configureViews() {
        [undoButton, confirmButton, cancelButton].forEach {
            addSubview($0)
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        undoButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressUndoButton)))
        undoButton.setIcon(.undo, with: .tiny, for: UIControlState())
        undoButton.accessibilityIdentifier = "undoButton"
        confirmButton.setIcon(.checkmark, with: .medium, for: UIControlState())
        confirmButton.accessibilityIdentifier = "confirmButton"
        cancelButton.setIcon(.X, with: .tiny, for: UIControlState())
        cancelButton.accessibilityIdentifier = "cancelButton"
        undoButton.isEnabled = false
        confirmButton.isEnabled = false
    }
    
    fileprivate func createConstraints() {
        let margin: CGFloat = 16
        let buttonMargin: CGFloat = margin + iconSize / 2
        constrain(self, undoButton, confirmButton, cancelButton) { view, undoButton, confirmButton, cancelButton in
            align(top: view, undoButton, confirmButton, cancelButton)
            align(bottom: view, undoButton, confirmButton, cancelButton)
            
            undoButton.centerX == view.leading + buttonMargin
            undoButton.width == view.height
            
            confirmButton.centerX == view.centerX
            confirmButton.width == view.height
            cancelButton.centerX == view.trailing - buttonMargin
            cancelButton.width == view.height
        }
    }
    
    @objc func buttonTapped(_ sender: IconButton) {
        let typeBySender = [undoButton: EditButtonType.undo, confirmButton: .confirm, cancelButton: .cancel]
        guard let type = typeBySender[sender] else { return }
        delegate?.inputBarEditView(self, didTapButtonWithType: type)
    }
    
    @objc func didLongPressUndoButton(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        delegate?.inputBarEditViewDidLongPressUndoButton(self)
    }
    
}
