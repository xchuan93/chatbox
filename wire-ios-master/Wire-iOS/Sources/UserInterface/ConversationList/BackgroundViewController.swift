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
import Cartography
import WireSyncEngine
import WireExtensionComponents

final public class BackgroundViewController: UIViewController {
    fileprivate let imageView = UIImageView()
    private let cropView = UIView()
    private let darkenOverlay = UIView()
    private var statusBarBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var userObserverToken: NSObjectProtocol! = .none
    private var statusBarBlurViewHeightConstraint: NSLayoutConstraint!
    private let user: ZMBareUser
    private let userSession: ZMUserSession?
    
    public var darkMode: Bool = false {
        didSet {
            darkenOverlay.isHidden = !self.darkMode
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init(user: ZMBareUser, userSession: ZMUserSession?) {
        self.user = user
        self.userSession = userSession
        super.init(nibName: .none, bundle: .none)
        
        if let userSession = userSession {
            self.userObserverToken = UserChangeInfo.add(observer: self, forBareUser: self.user, userSession: userSession)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(statusBarStyleChanged(_:)),
                                               name: UIApplication.wr_statusBarStyleChangeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(colorSchemeChanged(_:)),
                                               name: NSNotification.Name.SettingsColorSchemeChanged,
                                               object: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        self.createConstraints()
        
        self.updateForUser()
        self.updateForColorScheme()
    }
    
    override open var prefersStatusBarHidden: Bool {
        return false
    }

    open override var preferredStatusBarStyle : UIStatusBarStyle {
        if let child = childViewControllers.first {
            return child.preferredStatusBarStyle
        }
        else {
            return .lightContent
        }
    }
    
    public override func shouldDisplayNotification(from account: Account) -> Bool {
        return !account.isActive
    }
    
    private func configureViews() {
        imageView.contentMode = .scaleAspectFill
        cropView.clipsToBounds = true
        darkenOverlay.backgroundColor = UIColor(white: 0, alpha: 0.16)
        
        [imageView, blurView, statusBarBlurView, darkenOverlay].forEach(self.cropView.addSubview)
        
        self.view.addSubview(self.cropView)
    }
    
    private func createConstraints() {
        constrain(self.view, self.imageView, self.blurView, self.statusBarBlurView, self.cropView) { selfView, imageView, blurView, statusBarBlurView, cropView in
            cropView.top == selfView.top
            cropView.bottom == selfView.bottom
            cropView.leading == selfView.leading - 100
            cropView.trailing == selfView.trailing + 100

            self.statusBarBlurViewHeightConstraint = statusBarBlurView.height == 0
            statusBarBlurView.top == cropView.top
            statusBarBlurView.leading == cropView.leading
            statusBarBlurView.trailing == cropView.trailing
            
            blurView.top == statusBarBlurView.bottom
            
            blurView.leading == cropView.leading
            blurView.trailing == cropView.trailing
            blurView.bottom == cropView.bottom
            imageView.edges == cropView.edges
        }
        
        constrain(self.cropView, self.darkenOverlay) { cropView, darkenOverlay in
            darkenOverlay.edges == cropView.edges
        }
        
        self.updateStatusBarBlurStyle()
        
        let factor = BackgroundViewController.backgroundScaleFactor
        self.imageView.transform = CGAffineTransform(scaleX: factor, y: factor)
    }
    
    private func updateStatusBarBlurStyle() {
        guard let splitViewController = self.wr_splitViewController else {
            return
        }
        
        UIView.performWithoutAnimation {
            let shouldShowStatusWhite = splitViewController.layoutSize != .compact &&
                                        !UIApplication.shared.isStatusBarHidden &&
                                        UIApplication.shared.statusBarStyle == .default
            self.statusBarBlurViewHeightConstraint.constant = shouldShowStatusWhite ? 20 : 0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateForUser() {
        guard self.isViewLoaded else {
            return
        }
        
        if let imageData = user.imageMediumData {
            self.setBackground(imageData: imageData)
        } else {
            if let searchUser = user as? ZMSearchUser, let userSession = self.userSession {
                searchUser.requestMediumProfileImage(in: userSession)
            }
            
            self.setBackground(color: user.accentColorValue.color)
        }
    }
    
    private func updateForColorScheme() {
        self.darkMode = (ColorScheme.default().variant == .dark)
    }
    
    internal func updateFor(imageMediumDataChanged: Bool, accentColorValueChanged: Bool) {
        guard imageMediumDataChanged || accentColorValueChanged else {
            return
        }
        
        if let data = user.imageMediumData {
            if imageMediumDataChanged {
                self.setBackground(imageData: data)
            }
        } else if accentColorValueChanged {
            self.setBackground(color: user.accentColorValue.color)
        }
    }
    
    static let ciContext: CIContext = {
        return CIContext()
    }()
    
    static let backgroundScaleFactor: CGFloat = 1.4
    
    static func blurredAppBackground(with imageData: Data) -> UIImage? {
        return UIImage(from: imageData, withMaxSize: 40)?.desaturatedImage(with: BackgroundViewController.ciContext, saturation: 2)
    }
    
    fileprivate func setBackground(imageData: Data) {
        self.imageView.image = BackgroundViewController.blurredAppBackground(with: imageData)
    }
    
    fileprivate func setBackground(color: UIColor) {
        self.imageView.image = .none
        self.imageView.backgroundColor = color
    }
    
    @objc public func statusBarStyleChanged(_ object: AnyObject!) {
        self.updateStatusBarBlurStyle()
    }
    
    @objc public func colorSchemeChanged(_ object: AnyObject!) {
        self.updateForColorScheme()
    }
}

extension BackgroundViewController: ZMUserObserver {
    public func userDidChange(_ changeInfo: UserChangeInfo) {
        self.updateFor(imageMediumDataChanged: changeInfo.imageMediumDataChanged,
                       accentColorValueChanged: changeInfo.accentColorValueChanged)
    }
}

