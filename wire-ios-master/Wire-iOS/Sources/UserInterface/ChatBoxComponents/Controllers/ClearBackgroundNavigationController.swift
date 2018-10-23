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

class ClearBackgroundNavigationController: UINavigationController {
    fileprivate let pushTransition = PushTransition()
    fileprivate let popTransition = PopTransition()
    
    fileprivate var dismissGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.delegate = self
        self.transitioningDelegate = self
    }
    
    open var useDefaultPopGesture: Bool = false {
        didSet {
            self.interactivePopGestureRecognizer?.isEnabled = useDefaultPopGesture
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.useDefaultPopGesture = false
        
        self.navigationBar.tintColor = .white
        self.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                  NSFontAttributeName: FontSpec(.small, .semibold).font!]
        
        let navButtonAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        
        let attributes = [NSFontAttributeName: FontSpec(.small, .semibold).font!]
        navButtonAppearance.setTitleTextAttributes(attributes, for: UIControlState.normal)
        navButtonAppearance.setTitleTextAttributes(attributes, for: UIControlState.highlighted)
        
        self.dismissGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ClearBackgroundNavigationController.onEdgeSwipe(gestureRecognizer:)))
        self.dismissGestureRecognizer.edges = [.left]
        self.dismissGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.dismissGestureRecognizer)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewControllers.forEach { $0.hideDefaultButtonTitle() }
        
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hideDefaultButtonTitle()
        
        super.pushViewController(viewController, animated: animated)
    }
    
    func onEdgeSwipe(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            self.popViewController(animated: true)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let avoiding = viewController as? KeyboardAvoidingViewController {
            updateGesture(for: avoiding.viewController)
        } else {
            updateGesture(for: viewController)
        }
    }
    
    private func updateGesture(for viewController: UIViewController) {
        let translucentBackground = viewController.view.backgroundColor?.alpha < 1.0
        useDefaultPopGesture = !translucentBackground
    }
    
}


extension ClearBackgroundNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.useDefaultPopGesture {
            return nil
        }
        
        switch operation {
        case .push:
            return self.pushTransition
        case .pop:
            return self.popTransition
        default:
            fatalError()
        }
    }
}

extension ClearBackgroundNavigationController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = SwizzleTransition()
        transition.direction = .vertical
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = SwizzleTransition()
        transition.direction = .vertical
        return transition
    }
}

extension ClearBackgroundNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.useDefaultPopGesture && gestureRecognizer == self.dismissGestureRecognizer {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

