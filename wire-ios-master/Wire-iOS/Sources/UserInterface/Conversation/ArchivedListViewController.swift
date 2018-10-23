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

// MARK: ArchivedListViewControllerDelegate

@objc protocol ArchivedListViewControllerDelegate: class {
    func archivedListViewControllerWantsToDismiss(_ controller: ArchivedListViewController)
    func archivedListViewController(_ controller: ArchivedListViewController, didSelectConversation conversation: ZMConversation)
}

// MARK: - ArchivedListViewController

@objc final class ArchivedListViewController: UIViewController {
    
    var collectionView: UICollectionView!
    let archivedNavigationBar = ArchivedNavigationBar(title: "archived_list.title".localized.uppercased())
    let cellReuseIdentifier = "ConversationListCellArchivedIdentifier"
    let swipeIdentifier = "ArchivedList"
    let viewModel = ArchivedListViewModel()
    let layoutCell = ConversationListCell()
    
    weak var delegate: ArchivedListViewControllerDelegate?
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
        createViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ConversationListCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16 + UIScreen.safeArea.bottom, right: 0)
        collectionView.accessibilityIdentifier = "archived conversation list"

        [archivedNavigationBar, collectionView].forEach(view.addSubview)
        archivedNavigationBar.dismissButtonHandler = {
            self.delegate?.archivedListViewControllerWantsToDismiss(self)
        }
    }
    
    func createConstraints() {
        constrain(view, archivedNavigationBar, collectionView) { view, navigationBar, collectionView in
            navigationBar.top == view.top + UIScreen.safeArea.top
            navigationBar.left == view.left
            navigationBar.right == view.right
            navigationBar.bottom == collectionView.top
            collectionView.left == view.left
            collectionView.bottom == view.bottom
            collectionView.right == view.right
        }
    }
    
}

// MARK: - CollectionViewDelegate

extension ArchivedListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let conversation = viewModel[indexPath.row] else { return }
        delegate?.archivedListViewController(self, didSelectConversation: conversation)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showSeparator = scrollView.contentOffset.y >= 16
        guard showSeparator != archivedNavigationBar.showSeparator else { return }
        archivedNavigationBar.showSeparator = showSeparator
    }
}

// MARK: - CollectionViewDataSource

extension ArchivedListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ConversationListCell
        cell.conversation = viewModel[indexPath.row]
        cell.delegate = self
        cell.mutuallyExclusiveSwipeIdentifier = swipeIdentifier
        cell.autoresizingMask = .flexibleWidth
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layoutCell.size(inCollectionViewSize: collectionView.bounds.size)
    }
    
}

// MARK: - ArchivedListViewModelDelegate

extension ArchivedListViewController: ArchivedListViewModelDelegate {
    internal func archivedListViewModel(_ model: ArchivedListViewModel, didUpdateArchivedConversationsWithChange change: ConversationListChangeInfo, applyChangesClosure: @escaping () -> ()) {
  
        applyChangesClosure()
        collectionView.reloadData()
    }
    
    func archivedListViewModel(_ model: ArchivedListViewModel, didUpdateConversationWithChange change: ConversationChangeInfo) {
        guard change.isArchivedChanged || change.conversationListIndicatorChanged || change.nameChanged ||
            change.unreadCountChanged || change.connectionStateChanged || change.isSilencedChanged else { return }
        for case let cell as ConversationListCell in collectionView.visibleCells where cell.conversation == change.conversation {
            cell.updateAppearance()
        }
    }
    
}

// MARK: - ConversationListCellDelegate

extension ArchivedListViewController: ConversationListCellDelegate {
    func conversationListCellOverscrolled(_ cell: ConversationListCell!) {
        guard let sheet = ActionSheetController.dialog(forConversationDetails: cell.conversation, style: .dark) else { return }
        present(sheet, animated: true, completion: nil)
    }
}
