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

protocol GuestOptionsSectionControllerDelegate: class {
    
    func presentGuestOptions()
    
}

class GuestOptionsSectionController: GroupDetailsSectionController {
    
    private weak var delegate: GuestOptionsSectionControllerDelegate?
    private let conversation: ZMConversation
    private let syncCompleted: Bool
    
    init(conversation: ZMConversation, delegate: GuestOptionsSectionControllerDelegate, syncCompleted: Bool) {
        self.delegate = delegate
        self.conversation = conversation
        self.syncCompleted = syncCompleted
    }
    
    override func prepareForUse(in collectionView: UICollectionView?) {
        super.prepareForUse(in: collectionView)
        collectionView?.register(GroupDetailsGuestOptionsCell.self, forCellWithReuseIdentifier: GroupDetailsGuestOptionsCell.zm_reuseIdentifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 32)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupDetailsGuestOptionsCell.zm_reuseIdentifier, for: indexPath) as! GroupDetailsGuestOptionsCell
        cell.isOn = conversation.allowGuests
        cell.isUserInteractionEnabled = syncCompleted
        cell.alpha = syncCompleted ? 1 : 0.48
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.presentGuestOptions()
    }
    
}
