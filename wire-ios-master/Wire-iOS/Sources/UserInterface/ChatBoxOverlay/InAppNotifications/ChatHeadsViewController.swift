//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
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
import WireSyncEngine
import Cartography

public extension UIViewController {
    
    /// Determines if this view controller allows local in app notifications
    /// (chat heads) to appear. The default is true.
    ///
    @objc (shouldDisplayNotificationFrom:)
    public func shouldDisplayNotification(from account: Account) -> Bool {
        return true
    }
}

class ChatHeadsViewController: UIViewController {
    
    enum ChatHeadPresentationState {
        case `default`, hidden, showing, visible, dragging, hiding, last
    }
    
    fileprivate let dismissDelayDuration = 5.0
    fileprivate let animationContainerInset : CGFloat = 48.0
    fileprivate let dragGestureDistanceThreshold : CGFloat = 75.0
    fileprivate let containerInsets : UIEdgeInsets = UIEdgeInsets(top: UIScreen.safeArea.top - 4.0, left: 16, bottom: 0, right: 16)
    
    fileprivate var chatHeadView: ChatHeadView?
    fileprivate var chatHeadViewLeftMarginConstraint: NSLayoutConstraint?
    fileprivate var chatHeadViewRightMarginConstraint: NSLayoutConstraint?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var chatHeadState: ChatHeadPresentationState = .hidden
    
    override func loadView() {
        view = PassthroughTouchesView()
        view.backgroundColor = .clear
    }
    
    // MARK: - Public Interface
    
    public func tryToDisplayNotification(_ note: ZMLocalNotification) {

        // hide visible chat head and try again
        if chatHeadState != .hidden {
            hideChatHeadFromCurrentStateWithTiming(RBBEasingFunctionEaseInExpo, duration: 0.3)
            perform(#selector(tryToDisplayNotification(_:)), with: note, afterDelay: 0.3)
            return
        }
        
        guard
            let selfID = note.selfUserID,
            let account = SessionManager.shared?.accountManager.account(with: selfID),
            let session = SessionManager.shared?.backgroundUserSessions[account.userIdentifier],
            let conversationID = note.conversationID,
            shouldDisplay(note: note, conversationID: conversationID, account: account)
            else { return }
        
        // if notification is for active account, we only want to show the conversation name
        let title = account.isActive ? note.userInfo?[ConversationNameStringKey] as? String : note.title
        
        chatHeadView = ChatHeadView(
            title: title,
            body: note.body,
            userID: selfID,
            sender: note.sender(in: session.managedObjectContext),
            userInfo: note.userInfo,
            isEphemeral: note.isEphemeral
        )
        
        chatHeadView!.onSelect = {
            SessionManager.shared?.withSession(for: account) { userSession in
                if let conversation = note.conversation(in: session.managedObjectContext) {
                    SessionManager.shared?.userSession(userSession, show: conversation)
                }
            }
            
            self.chatHeadView?.removeFromSuperview()
        }
        
        chatHeadState = .showing
        view.addSubview(chatHeadView!)
        
        // position offscreen left
        constrain(view, chatHeadView!) { view, chatHeadView in
            chatHeadView.top == view.top + 64 + containerInsets.top
            chatHeadViewLeftMarginConstraint = (chatHeadView.leading == view.leading - animationContainerInset)
            chatHeadViewRightMarginConstraint = (chatHeadView.trailing <= view.trailing - animationContainerInset)
        }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPanChatHead(_:)))
        chatHeadView!.addGestureRecognizer(panGestureRecognizer)
        
        // timed hiding
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideChatHeadView), object: nil)
        perform(#selector(hideChatHeadView), with: nil, afterDelay: dismissDelayDuration)
        
        chatHeadView!.alpha = 0
        revealChatHeadFromCurrentState()
    }
    
    // MARK: - Private Helpers
    
    private func shouldDisplay(note: ZMLocalNotification, conversationID: UUID, account: Account) -> Bool {
        
        guard !Settings.shared().chatHeadsDisabled else { return false }
        guard let clientVC = ZClientViewController.shared() else { return false }
        
        // if call notification & in active account
        if account.isActive && note.isCallingNotification {
            return false
        }
        
        // if current conversation contains message & is visible
        if clientVC.currentConversation.remoteIdentifier == conversationID && clientVC.isConversationViewVisible {
            return false
        }
        
        if AppDelegate.shared().notificationWindowController?.voiceChannelController?.voiceChannelIsActive ?? false {
            return false;
        }

        return clientVC.splitViewController.shouldDisplayNotification(from: account)
    }
    
    fileprivate func revealChatHeadFromCurrentState() {
        
        view.layoutIfNeeded()
        
        // slide in chat head from screen left
        UIView.wr_animate(
            easing: RBBEasingFunctionEaseOutExpo,
            duration: 0.35,
            animations: {
                self.chatHeadView?.alpha = 1
                self.chatHeadViewLeftMarginConstraint?.constant = self.containerInsets.left
                self.chatHeadViewRightMarginConstraint?.constant = -self.containerInsets.right
                self.view.layoutIfNeeded()
        },
            completion: { _ in self.chatHeadState = .visible }
        )
    }
    
    private func hideChatHeadFromCurrentState() {
        hideChatHeadFromCurrentStateWithTiming(RBBEasingFunctionEaseInExpo, duration: 0.35)
    }
    
    private func hideChatHeadFromCurrentStateWithTiming(_ timing: RBBEasingFunction, duration: TimeInterval) {
        chatHeadViewLeftMarginConstraint?.constant = -animationContainerInset
        chatHeadViewRightMarginConstraint?.constant = -animationContainerInset
        chatHeadState = .hiding
        
        UIView.wr_animate(
            easing: RBBEasingFunctionEaseOutExpo,
            duration: duration,
            animations: {
                self.chatHeadView?.alpha = 0
                self.view.layoutIfNeeded()
        },
            completion: { _ in
                self.chatHeadView?.removeFromSuperview()
                self.chatHeadState = .hidden
        })
    }
    
    @objc private func hideChatHeadView() {
        
        if chatHeadState == .dragging {
            perform(#selector(hideChatHeadView), with: nil, afterDelay: dismissDelayDuration)
            return
        }
        
        hideChatHeadFromCurrentState()
    }
}


// MARK: - Interaction

extension ChatHeadsViewController {
    
    @objc fileprivate func onPanChatHead(_ pan: UIPanGestureRecognizer) {
        
        let offset = pan.translation(in: view)
        
        switch pan.state {
        case .began:
            chatHeadState = .dragging
        
        case .changed:
            // if pan left, move chathead with finger, else apply pan resistance
            let viewOffsetX = offset.x < 0 ? offset.x : (1.0 - (1.0/((offset.x * 0.15 / view.bounds.width) + 1.0))) * view.bounds.width
            chatHeadViewLeftMarginConstraint?.constant = viewOffsetX + containerInsets.left
            chatHeadViewRightMarginConstraint?.constant = viewOffsetX - containerInsets.right
            
        case .ended, .failed, .cancelled:
            guard offset.x < 0 && fabs(offset.x) > dragGestureDistanceThreshold else {
                revealChatHeadFromCurrentState()
                break
            }

            chatHeadViewLeftMarginConstraint?.constant = -view.bounds.width
            chatHeadViewRightMarginConstraint?.constant = -view.bounds.width
            
            chatHeadState = .hiding
            
            // calculate time from formula dx = t * v + d0
            let velocityVector = pan.velocity(in: view)
            var time = Double((view.bounds.width - fabs(offset.x)) / fabs(velocityVector.x))
            
            // min/max animation duration
            if time < 0.05 { time = 0.05 }
            else if time > 0.2 { time = 0.2 }
            
            UIView.wr_animate(easing: RBBEasingFunctionEaseInQuad, duration: time, animations: view.layoutIfNeeded) { _ in
                self.chatHeadView?.removeFromSuperview()
                self.chatHeadState = .hidden
            }
            
        default:
            break
        }
    }
}


extension Account {
    
    var isActive: Bool {
        return SessionManager.shared?.accountManager.selectedAccount == self 
    }
}
