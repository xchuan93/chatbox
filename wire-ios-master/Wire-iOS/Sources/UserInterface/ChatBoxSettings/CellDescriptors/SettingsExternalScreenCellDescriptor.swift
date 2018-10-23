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


import Foundation

enum PresentationStyle: Int {
    case modal
    case navigation
}

class InviteCellDescriptor: SettingsExternalScreenCellDescriptor {
    override func featureCell(_ cell: SettingsCellType) {
        super.featureCell(cell)
        
        cell.cellColor = .accent()
    }
}

enum AccessoryViewMode: Int {
    case `default`
    case alwaysShow
    case alwaysHide
}

class SettingsExternalScreenCellDescriptor: SettingsExternalScreenCellDescriptorType, SettingsControllerGeneratorType {
    static let cellType: SettingsTableCell.Type = SettingsGroupCell.self
    var visible: Bool = true
    let title: String
    let destructive: Bool
    let presentationStyle: PresentationStyle
    let identifier: String?
    let icon: ZetaIconType

    private let accessoryViewMode: AccessoryViewMode

    weak var group: SettingsGroupCellDescriptorType?
    weak var viewController: UIViewController?
    
    let previewGenerator: PreviewGeneratorType?

    let presentationAction: () -> (UIViewController?)
    
    convenience init(title: String, presentationAction: @escaping () -> (UIViewController?)) {
        self.init(
            title: title,
            isDestructive: false,
            presentationStyle: .navigation,
            identifier: nil,
            presentationAction: presentationAction,
            previewGenerator: nil,
            icon: .none
        )
    }
    
    convenience init(title: String, isDestructive: Bool, presentationStyle: PresentationStyle, presentationAction: @escaping () -> (UIViewController?), previewGenerator: PreviewGeneratorType? = .none, icon: ZetaIconType = .none, accessoryViewMode: AccessoryViewMode = .default) {
        self.init(
            title: title,
            isDestructive: isDestructive,
            presentationStyle: presentationStyle,
            identifier: nil,
            presentationAction: presentationAction,
            previewGenerator: previewGenerator,
            icon: icon,
            accessoryViewMode: accessoryViewMode
        )
    }
    
    init(title: String, isDestructive: Bool, presentationStyle: PresentationStyle, identifier: String?, presentationAction: @escaping () -> (UIViewController?), previewGenerator: PreviewGeneratorType? = .none, icon: ZetaIconType = .none, accessoryViewMode: AccessoryViewMode = .default) {
        self.title = title
        self.destructive = isDestructive
        self.presentationStyle = presentationStyle
        self.presentationAction = presentationAction
        self.identifier = identifier
        self.previewGenerator = previewGenerator
        self.icon = icon
        self.accessoryViewMode = accessoryViewMode
    }
    
    func select(_ value: SettingsPropertyValue?) {
        guard let controllerToShow = self.generateViewController() else {
            return
        }
        
        switch self.presentationStyle {
        case .modal:
            if controllerToShow.modalPresentationStyle == .popover,
                let sourceView = self.viewController?.view,
                let popoverPresentation = controllerToShow.popoverPresentationController {
                popoverPresentation.sourceView = sourceView
                popoverPresentation.sourceRect = sourceView.bounds
            }
            
            self.viewController?.present(controllerToShow, animated: true, completion: .none)
            
        case .navigation:
            if let navigationController = self.viewController?.navigationController {
                navigationController.pushViewController(controllerToShow, animated: true)
            }
        }
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
        cell.titleColor = UIColor.white
        
        if let previewGenerator = self.previewGenerator {
            let preview = previewGenerator(self)
            cell.preview = preview
        }
        cell.icon = self.icon
        if let groupCell = cell as? SettingsGroupCell {
            switch accessoryViewMode {
            case .default:
                if self.presentationStyle == .modal {
                    groupCell.accessoryType = .none
                } else {
                    groupCell.accessoryType = .disclosureIndicator
                }
            case .alwaysHide:
                groupCell.accessoryType = .none
            case .alwaysShow:
                groupCell.accessoryType = .disclosureIndicator
            }
            
        }
    }
    
    func generateViewController() -> UIViewController? {
        return self.presentationAction()
    }
}
