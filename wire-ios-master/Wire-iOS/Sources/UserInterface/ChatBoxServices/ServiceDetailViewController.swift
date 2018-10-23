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
import Cartography

extension ZMConversation {
    var botCanBeAdded: Bool {
        return self.conversationType != .oneOnOne && canAddGuest
    }
}

public enum ServiceConversation {
    case existing(ZMConversation)
    case new
}

public struct Service {
    let serviceUser: ServiceUser
    var serviceUserDetails: ServiceDetails?
    var provider: ServiceProvider?
}

extension Service {
    init(serviceUser: ServiceUser) {
        self.serviceUser = serviceUser
        self.serviceUserDetails = nil
        self.provider = nil
    }
}

extension ServiceConversation: Hashable {

    public static func ==(lhs: ServiceConversation, rhs: ServiceConversation) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public var hashValue: Int {
        switch self {
        case .new:
            return 0
        case .existing(let conversation):
            return conversation.hashValue
        }
    }
}

private func add(service: Service, to conversation: Any, completion: ((AddBotResult) -> Void)? = nil) {
    guard let userSession = ZMUserSession.shared(),
        let serviceConversation = conversation as? ServiceConversation else {
            return
    }

    func tagAdded(user: ServiceUser, to conversation: ZMConversation) {
        Analytics.shared().tag(ServiceAddedEvent(service: user, conversation: conversation, context: .startUI))
    }

    switch serviceConversation {
    case .new:
        userSession.startConversation(with: service.serviceUser) { result in
            switch result {
            case .success(let conversation): tagAdded(user: service.serviceUser, to: conversation)
            default: break
            }

            completion?(result)
        }
    case .existing(let conversation):
        conversation.add(serviceUser: service.serviceUser, in: userSession) { error in
            if let error = error {
                completion?(AddBotResult.failure(error: error))
            } else {
                tagAdded(user: service.serviceUser, to: conversation)
                completion?(AddBotResult.success(conversation: conversation))
            }
        }
    }
}

extension Service: Shareable {
    public typealias I = ServiceConversation

    public func share<ServiceConversation>(to: [ServiceConversation]) {
        guard let serviceConversation = to.first else { return }
        add(service: self, to: serviceConversation)
    }

    public func share<ServiceConversation>(to: [ServiceConversation], completion: @escaping (AddBotResult) -> Void) {
        guard let serviceConversation = to.first else { return }
        add(service: self, to: serviceConversation, completion: completion)
    }

    public func previewView() -> UIView? {
        return ServiceView(service: self, variant: .dark)
    }
}

extension ServiceConversation: ShareDestination {
    public var displayName: String {
        switch self {
        case .new:
            return "peoplepicker.services.create_conversation.item".localized
        case .existing(let conversation):
            return conversation.displayName
        }
    }

    public var securityLevel: ZMConversationSecurityLevel {
        switch self {
        case .new:
            return ZMConversationSecurityLevel.notSecure
        case .existing(let conversation):
            return conversation.securityLevel
        }
    }

    public var avatarView: UIView? {
        switch self {
        case .new:
            let imageView = UIImageView()
            imageView.contentMode = .center
            imageView.image = UIImage(for: .plus, iconSize: .tiny, color: .white)
            return imageView
        case .existing(let conversation):
            return conversation.avatarView
        }
    }
}

struct ServiceDetailVariant {
    let colorScheme: ColorSchemeVariant
    let opaque: Bool
}

final class ServiceDetailViewController: UIViewController {

    enum ActionType {
        case addService, removeService
    }

    public var service: Service {
        didSet {
            self.detailView.service = service
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }

    public var completion: ((AddBotResult?)->Void)?
    let destinationConversation: ZMConversation?

    public let variant: ServiceDetailVariant
    public weak var viewControllerDismissable: ViewControllerDismissable?

    private let detailView: ServiceDetailView
    private let actionButton: Button
    private let actionType: ActionType

    /// init method with ServiceUser, destination conversation and customized UI.
    ///
    /// - Parameters:
    ///   - serviceUser: a ServiceUser to show
    ///   - destinationConversation: the destination conversation of the serviceUser
    ///   - actionType: Enum ActionType to choose the actiion add or remove the service user
    ///   - variant: color variant
    init(serviceUser: ServiceUser,
         destinationConversation: ZMConversation?,
         actionType: ActionType,
         variant: ServiceDetailVariant) {
        self.service = Service(serviceUser: serviceUser)
        self.destinationConversation = destinationConversation
        self.detailView = ServiceDetailView(service: service, variant: variant.colorScheme)

        switch actionType {
        case .addService:
            self.actionButton = Button.createAddServiceButton()
        case .removeService:
            self.actionButton = Button.createDestructiveServiceButton()
        }

        self.variant = variant
        self.actionType = actionType
        actionButton.isHidden = destinationConversation.map(ZMUser.selfUser().isGuest) ?? false

        super.init(nibName: nil, bundle: nil)

        self.title = self.service.serviceUser.name.localizedUppercase
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var callback: Callback<Button>?
        switch actionType {
        case .addService:
            callback = createOnAddServicePressed()
        case .removeService:
            callback = createRemoveServiceCallBack()
        }

        if let callback = callback {
            self.actionButton.addCallback(for: .touchUpInside, callback: callback)
        }

        if self.variant.opaque {
            view.backgroundColor = ColorScheme.default().color(withName: ColorSchemeColorBackground,
                                                               variant: self.variant.colorScheme)
        }
        else {
            view.backgroundColor = .clear
        }

        view.addSubview(detailView)
        view.addSubview(actionButton)

        var topMargin: CGFloat = 16
        if #available(iOS 11.0, *) {
            topMargin = 16
        } else {
            if let naviBarHeight = self.navigationController?.navigationBar.frame.height {
                topMargin = 16 + naviBarHeight
            }
        }

        constrain(self.view, detailView, actionButton) { selfView, detailView, confirmButton in
            detailView.leading == selfView.leading + 16
            detailView.top == selfView.topMargin + topMargin

            detailView.trailing == selfView.trailing - 16

            confirmButton.top == detailView.bottom + 16
            confirmButton.height == 48
            confirmButton.leading == selfView.leading + 16
            confirmButton.trailing == selfView.trailing - 16
            confirmButton.bottom == selfView.bottom - 16 - UIScreen.safeArea.bottom
        }

        guard let userSession = ZMUserSession.shared() else {
            return
        }

        self.service.serviceUser.fetchProvider(in: userSession) { [weak self] provider in
            self?.detailView.service.provider = provider
        }

        self.service.serviceUser.fetchDetails(in: userSession) { [weak self] details in
            self?.detailView.service.serviceUserDetails = details
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(icon: .X,
                                                                 target: self,
                                                                 action: #selector(ServiceDetailViewController.dismissButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "close"
    }

    @objc(backButtonTapped:)
    public func backButtonTapped(_ sender: AnyObject!) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc(dismissButtonTapped:)
    public func dismissButtonTapped(_ sender: AnyObject!) {
        self.navigationController?.dismiss(animated: true, completion: { [weak self] in
            self?.completion?(nil)
        })
    }

    // MARK: - action button callback - remove service

    func createRemoveServiceCallBack() -> Callback<Button> {
        let buttonCallback: Callback<Button> = { [weak self] _ in
            guard let weakSelf = self else { return }
            guard weakSelf.service.serviceUser.isKind(of: ZMUser.self)  else { return }

            weakSelf.presentRemoveFromConversationDialogue(user: weakSelf.service.serviceUser as! ZMUser,
                                                           conversation: weakSelf.destinationConversation,
                                                           viewControllerDismissable: weakSelf.viewControllerDismissable)
        }

        return buttonCallback
    }

    // MARK: - action button callback - add service

    func createOnAddServicePressed() -> Callback<Button> {
        return { [weak self] _ in
            self?.onAddServicePressed()
        }
    }

    private func onAddServicePressed() {
        if let conversation = self.destinationConversation {
            Wire.add(service: self.service, to: ServiceConversation.existing(conversation), completion: { [weak self] result in
                self?.completion?(result)
            })
        } else {
            showConversationPicker()
        }
    }

    private func showConversationPicker() {
        guard let userSession = ZMUserSession.shared() else {
            return
        }

        var allConversations: [ServiceConversation] = [.new]

        let zmConversations = ZMConversationList.conversationsIncludingArchived(inUserSession: userSession).convesationsWhereBotCanBeAdded()

        allConversations.append(contentsOf: zmConversations.map(ServiceConversation.existing))

        let conversationPicker = ShareServiceViewController(shareable: self.service, destinations: allConversations, showPreview: true, allowsMultipleSelection: false)
        conversationPicker.onServiceDismiss = { [weak self] _, completed, result in
            self?.completion?(result)
        }
        self.navigationController?.pushViewController(conversationPicker, animated: true)
    }
}

