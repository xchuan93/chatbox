//
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
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

import Foundation

class RenameGroupSectionController: NSObject, _CollectionViewSectionController {
    
    fileprivate var validName : String? = nil
    fileprivate var conversation: ZMConversation
    fileprivate var renameCell : GroupDetailsRenameCell?
    fileprivate var token : AnyObject?
    
    init(conversation: ZMConversation) {
        self.conversation = conversation
        
        super.init()
        
        self.token = ConversationChangeInfo.add(observer: self, for: conversation)
    }
    
    func focus() {
        guard conversation.isSelfAnActiveMember else { return }
        renameCell?.titleTextField.becomeFirstResponder()
    }
    
    func prepareForUse(in collectionView: UICollectionView?) {
        collectionView?.register(GroupDetailsRenameCell.self, forCellWithReuseIdentifier: GroupDetailsRenameCell.zm_reuseIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupDetailsRenameCell.zm_reuseIdentifier, for: indexPath) as! GroupDetailsRenameCell
        cell.configure(for: conversation)
        cell.titleTextField.textFieldDelegate = self
        renameCell?.titleTextField.isUserInteractionEnabled = conversation.isSelfAnActiveMember
        renameCell?.accessoryIconView.isHidden = !conversation.isSelfAnActiveMember
        renameCell = cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        focus()
    }
    
}

extension RenameGroupSectionController : ZMConversationObserver {
    
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        guard changeInfo.securityLevelChanged || changeInfo.nameChanged else { return }
        
        renameCell?.configure(for: conversation)
    }
    
}

extension RenameGroupSectionController: SimpleTextFieldDelegate {
    
    func textFieldReturnPressed(_ textField: SimpleTextField) {
        guard let value = textField.value else { return }
        
        switch  value {
        case .valid(let name):
            validName = name
            textField.endEditing(true)
        case .error:
            // TODO show error
            textField.endEditing(true)
        }
    }
    
    func textField(_ textField: SimpleTextField, valueChanged value: SimpleTextField.Value) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: SimpleTextField) {
        renameCell?.accessoryIconView.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: SimpleTextField) {
        if let newName = validName {
            ZMUserSession.shared()?.enqueueChanges {
                self.conversation.userDefinedName = newName
            }
        } else {
            textField.text = conversation.displayName
        }
        
        renameCell?.accessoryIconView.isHidden = false
    }
    
}
