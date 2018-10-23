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
import Social
import WireShareEngine
import Cartography
import MobileCoreServices
import WireDataModel
import WireExtensionComponents
import CocoaLumberjackSwift
import Classy

/// The delay after which a progess view controller will be displayed if all messages are not yet sent.
private let progressDisplayDelay: TimeInterval = 0.5

private enum LocalAuthenticationStatus {
    case disabled
    case denied
    case granted
}

class ShareExtensionViewController: SLComposeServiceViewController {
    
    lazy var accountItem : SLComposeSheetConfigurationItem = { [weak self] in
        let item = SLComposeSheetConfigurationItem()!
        let accountName = self?.currentAccount?.shareExtensionDisplayName
        
        item.title = "share_extension.conversation_selection.account".localized
        item.value = accountName ?? "share_extension.conversation_selection.empty.value".localized
        item.tapHandler = { [weak self] in
            self?.presentChooseAccount()
        }
        return item
    }()
    
    lazy var conversationItem : SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        
        item.title = "share_extension.conversation_selection.title".localized
        item.value = "share_extension.conversation_selection.empty.value".localized
        item.tapHandler = { [weak self] in
            self?.presentChooseConversation()
        }
        return item
    }()

    fileprivate var postContent: PostContent?
    fileprivate var sharingSession: SharingSession? = nil
    fileprivate var extensionActivity: ExtensionActivity? = nil
    fileprivate var currentAccount: Account? = nil
    fileprivate var localAuthenticationStatus: LocalAuthenticationStatus = .disabled
    private var observer: SendableBatchObserver? = nil
    private weak var progressViewController: SendingProgressViewController? = nil
    
    var netObserver = ShareExtensionNetworkObserver()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupObserver()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentAccount = accountManager?.selectedAccount
        ExtensionBackupExcluder.exclude()
        CrashReporter.setupHockeyIfNeeded()
        navigationController?.view.backgroundColor = .white
        try? recreateSharingSession(account: currentAccount)
        let activity = ExtensionActivity(attachments: allAttachments)
        sharingSession?.analyticsEventPersistence.add(activity.openedEvent())
        extensionActivity = activity
        
        NetworkStatus.add(netObserver)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.postContent = PostContent(attachments: self.allAttachments)
        self.setupNavigationBar()
        self.appendTextToEditor()
        self.placeholder = "share_extension.input.placeholder".localized
    }

    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(extensionHostDidEnterBackground), name: .NSExtensionHostDidEnterBackground, object: nil)
    }

    private func setupNavigationBar() {
        guard let item = navigationController?.navigationBar.items?.first else { return }
        item.rightBarButtonItem?.action = #selector(appendPostTapped)
        item.rightBarButtonItem?.title = "share_extension.send_button.title".localized
        item.titleView = UIImageView(image: UIImage(forLogoWith: .black, iconSize: .small))
    }

    @objc private func extensionHostDidEnterBackground() {
        postContent?.cancel { [weak self] in
            self?.cancel()
        }
    }

    override func presentationAnimationDidFinish() {
        guard let sharingSession = sharingSession, sharingSession.canShare else {
            return presentNotSignedInMessage()
        }
    }

    private var applicationGroupIdentifier: String? {
        return Bundle.main.infoDictionary?["ApplicationGroupIdentifier"] as? String
    }
    
    private var hostBundleIdentifier: String? {
        return Bundle.main.infoDictionary?["HostBundleIdentifier"] as? String
    }
    
    private func recreateSharingSession(account: Account?) throws {
        guard let applicationGroupIdentifier = applicationGroupIdentifier,
            let hostBundleIdentifier = hostBundleIdentifier,
            let accountIdentifier = account?.userIdentifier
        else { return }
        
        sharingSession = try SharingSession(
                applicationGroupIdentifier: applicationGroupIdentifier,
                accountIdentifier: accountIdentifier,
                hostBundleIdentifier: hostBundleIdentifier
            )
    }
    
    private var accountManager: AccountManager? {
        guard let applicationGroupIdentifier = applicationGroupIdentifier else { return nil }
        let sharedContainerURL = FileManager.sharedContainerDirectory(for: applicationGroupIdentifier)
        return AccountManager(sharedDirectory: sharedContainerURL)
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        let textLength = self.contentText.trimmingCharacters(in: .whitespaces).count
        let remaining = SharedConstants.maximumMessageLength - textLength
        let remainingCharactersThreshold = 30
        
        if remaining <= remainingCharactersThreshold {
            self.charactersRemaining = remaining as NSNumber
        } else {
            self.charactersRemaining = nil
        }
        
        let conditions = sharingSession != nil && self.postContent?.target != nil
        return self.charactersRemaining == nil ? conditions : conditions && self.charactersRemaining.intValue >= 0
    }

    /// invoked when the user wants to post
    func appendPostTapped() {
        navigationController?.navigationBar.items?.first?.rightBarButtonItem?.isEnabled = false

        postContent?.send(text: contentText, sharingSession: sharingSession!) { [weak self] progress in
            guard let `self` = self, let postContent = self.postContent else { return }

            switch progress {
            case .preparing:
                DispatchQueue.main.asyncAfter(deadline: .now() + progressDisplayDelay) {
                    guard !postContent.sentAllSendables && nil == self.progressViewController else { return }
                    self.presentSendingProgress(mode: .preparing)
                }

            case .startingSending:
                DispatchQueue.main.asyncAfter(deadline: .now() + progressDisplayDelay) {
                    guard postContent.sentAllSendables && nil == self.progressViewController else { return }
                    self.presentSendingProgress(mode: .sending)
                }

            case .sending(let progress):
                self.progressViewController?.progress = progress

            case .done:
                self.storeTrackingData {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                        self.view.alpha = 0
                        self.navigationController?.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }, completion: { _ in
                        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    })
                }

            case .conversationDidDegrade((let users, let strategyChoice)):
                self.extensionActivity?.markConversationDidDegrade()
                self.conversationDidDegrade(
                    change: ConversationDegradationInfo(conversation: postContent.target!, users: users),
                    callback: strategyChoice
                )
            case .timedOut:
                self.popConfigurationViewController()
                
                let title = "share_extension.timeout.title".localized
                let message = "share_extension.timeout.message".localized
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func cancel() {
        if let event = extensionActivity?.cancelledEvent() {
            sharingSession?.analyticsEventPersistence.add(event)
        }
        super.cancel()
    }

    private func storeTrackingData(completion: @escaping () -> Void) {
        extensionActivity?.hasText = !contentText.isEmpty
        extensionActivity?.sentEvent { [weak self] event in
            self?.sharingSession?.analyticsEventPersistence.add(event)
            completion()
        }
    }
    
    /// Display a preview image
    override func loadPreviewView() -> UIView! {
        if let parentView = super.loadPreviewView() {
            return parentView
        }
        let hasURL = self.allAttachments.contains { $0.hasURL }
        let hasEmptyText = self.textView.text.isEmpty
        let isWalletPass = self.allAttachments.contains { $0.hasWalletPass }
        // I can not ask if it's a http:// or file://, because it's an async operation, so I rely on the fact that 
        // if it has no image, it has a URL and it has text, it must be a file
        if (hasURL && hasEmptyText) || isWalletPass {
            return UIImageView(image: UIImage(for: .document, iconSize: .large, color: UIColor.black))
        }
        return nil
    }

    /// If there is a URL attachment, copy the text of the URL attachment into the text field
    private func appendTextToEditor() {
        fetchURLAttachments { [weak self] (urls) in
            guard let url = urls.first, let `self` = self else { return }
            if !url.isFileURL { // remote URL (not local file)
                let separator = self.textView.text.isEmpty ? "" : "\n"
                self.textView.text = self.textView.text + separator + url.absoluteString
                self.textView.delegate?.textViewDidChange?(self.textView)
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        if accountManager?.accounts.count > 1 {
            return [accountItem, conversationItem]
        } else {
            return [conversationItem]
        }
    }
    
    private func presentSendingProgress(mode: SendingProgressViewController.ProgressMode) {
        let progressSendingViewController = SendingProgressViewController()
        progressViewController?.mode = mode

        progressSendingViewController.cancelHandler = { [weak self] in
            self?.postContent?.cancel {
                self?.cancel()
            }
        }

        progressViewController = progressSendingViewController
        pushConfigurationViewController(progressSendingViewController)
    }
    
    private func presentNotSignedInMessage() {
        let notSignedInViewController = NotSignedInViewController()
        
        notSignedInViewController.closeHandler = { [weak self] in
            self?.cancel()
        }
        
        pushConfigurationViewController(notSignedInViewController)
    }
    
    func updateState(conversation: Conversation?) {
        conversationItem.value = conversation?.name ?? "share_extension.conversation_selection.empty.value".localized
        postContent?.target = conversation
        extensionActivity?.conversation = conversation
    }
    
    func updateAccount(_ account: Account?) {
        guard let account = account, account != currentAccount else { return }

        do {
            try recreateSharingSession(account: account)
        } catch let error as SharingSession.InitializationError {
            guard error == .loggedOut else { return }
            let alert = UIAlertController(title: "share_extension.logged_out.title".localized,
                                          message: "share_extension.logged_out.message".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "share_extension.general.ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        } catch { //any other error
            return
        }
        
        currentAccount = account
        accountItem.value = account.shareExtensionDisplayName
        conversationItem.value = "share_extension.conversation_selection.empty.value".localized
        postContent?.target = nil
        extensionActivity?.conversation = nil
    }
    
    private func presentChooseAccount() {
        requireLocalAuthenticationIfNeeded(with: { [weak self] (status) in
            if let status = status, status != .denied {
                self?.showChooseAccount()
            }
        })
    }
    
    private func presentChooseConversation() {
        requireLocalAuthenticationIfNeeded(with: { [weak self] (status) in
            if let status = status, status != .denied {
                self?.showChooseConversation()
            }
        })
    }
    
    func showChooseConversation() {
        
        guard let sharingSession = sharingSession else { return }
        
        let allConversations = sharingSession.writeableNonArchivedConversations + sharingSession.writebleArchivedConversations
        let conversationSelectionViewController = ConversationSelectionViewController(conversations: allConversations)
        
        conversationSelectionViewController.selectionHandler = { [weak self] conversation in
            self?.updateState(conversation: conversation)
            self?.popConfigurationViewController()
            self?.validateContent()
        }
        
        pushConfigurationViewController(conversationSelectionViewController)
    }
    
    func showChooseAccount() {
        
        guard let accountManager = accountManager else { return }
        let accountSelectionViewController = AccountSelectionViewController(accounts: accountManager.accounts,
                                                                            current: currentAccount)
        
        accountSelectionViewController.selectionHandler = { [weak self] account in
            self?.updateAccount(account)
            self?.popConfigurationViewController()
            self?.validateContent()
        }
        
        pushConfigurationViewController(accountSelectionViewController)
    }

    /// @param callback confirmation; called when authentication evaluation is completed.
    fileprivate func requireLocalAuthenticationIfNeeded(with callback: @escaping (LocalAuthenticationStatus?)->()) {
        
        // I need to store the current authentication in order to avoid future authentication requests in the same Share Extension session
        
        guard AppLock.isActive else {
            localAuthenticationStatus = .disabled
            callback(localAuthenticationStatus)
            return
        }
        
        guard localAuthenticationStatus != .granted else {
            callback(localAuthenticationStatus)
            return
        }
        
        AppLock.evaluateAuthentication(description: "share_extension.privacy_security.lock_app.description".localized) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if let success = success, success {
                    self?.localAuthenticationStatus = .granted
                } else {
                    self?.localAuthenticationStatus = .denied
                    DDLogError("Local authentication error: \(String(describing: error?.localizedDescription))")
                }
                callback(self?.localAuthenticationStatus)
            }
        }
    }
    
    
    private func conversationDidDegrade(change: ConversationDegradationInfo, callback: @escaping DegradationStrategyChoice) {
        let title = titleForMissingClients(users: change.users)
        let alert = UIAlertController(title: title, message: "meta.degraded.dialog_message".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "meta.degraded.send_anyway_button".localized, style: .destructive, handler: { _ in
            callback(.sendAnyway)
        }))
        alert.addAction(UIAlertAction(title: "meta.degraded.cancel_sending_button".localized, style: .cancel, handler: { _ in
            callback(.cancelSending)
        }))
        self.present(alert, animated: true)
    }
}


private func titleForMissingClients(users: Set<ZMUser>) -> String {
    let template = users.count > 1 ? "meta.degraded.degradation_reason_message.plural" : "meta.degraded.degradation_reason_message.singular"
    let allUsers = (users.map { $0.displayName ?? "" } as NSArray).componentsJoined(by: ", ") as NSString
    return NSString(format: template.localized as NSString, allUsers) as String
}
