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

class SettingsInfoCellDescriptor: SettingsCellDescriptorType {
    static let cellType: SettingsTableCell.Type = SettingsTableCell.self
    var visible: Bool {
        get {
            return true
        }
    }
    var title: String
    var identifier: String?
    weak var group: SettingsGroupCellDescriptorType?
    var previewGenerator: PreviewGeneratorType?
    
    init(title: String, previewGenerator: PreviewGeneratorType? = .none) {
        self.title = title
        self.identifier = .none
        self.previewGenerator = previewGenerator
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
        if let previewGenerator = self.previewGenerator {
            cell.preview = previewGenerator(self)
        }
    }
    
    func select(_ value: SettingsPropertyValue?) {
        guard let previewGenerator = self.previewGenerator else {
            return
        }
        
        let preview = previewGenerator(self)
        
        switch preview {
        case .text(let previewString):
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = previewString
        default: break
        }
    }
}

/**
 * @abstract Generates the cell that displays one button
 */
class SettingsButtonCellDescriptor: SettingsCellDescriptorType {
    static let cellType: SettingsTableCell.Type = SettingsButtonCell.self
    let title: String
    let identifier: String?
    var visible: Bool {
        get {
            if let visibilityAction = self.visibilityAction {
                return visibilityAction(self)
            }
            else {
                return true
            }
        }
    }
    
    weak var group: SettingsGroupCellDescriptorType?
    let selectAction: (SettingsCellDescriptorType) -> ()
    let visibilityAction: ((SettingsCellDescriptorType) -> (Bool))?
    let isDestructive: Bool
    
    init(title: String, isDestructive: Bool, selectAction: @escaping (SettingsCellDescriptorType) -> ()) {
        self.title = title
        self.isDestructive = isDestructive
        self.selectAction = selectAction
        self.visibilityAction = .none
        self.identifier = .none
    }
    
    init(title: String, isDestructive: Bool, selectAction: @escaping (SettingsCellDescriptorType) -> (), visibilityAction: ((SettingsCellDescriptorType) -> (Bool))? = .none) {
        self.title = title
        self.isDestructive = isDestructive
        self.selectAction = selectAction
        self.visibilityAction = visibilityAction
        self.identifier = .none
    }
    
    init(title: String, isDestructive: Bool, identifier: String, selectAction: @escaping (SettingsCellDescriptorType) -> (), visibilityAction: ((SettingsCellDescriptorType) -> (Bool))? = .none) {
        self.title = title
        self.isDestructive = isDestructive
        self.selectAction = selectAction
        self.visibilityAction = visibilityAction
        self.identifier = identifier
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
        cell.titleColor = UIColor.white
    }
    
    func select(_ value: SettingsPropertyValue?) {
        self.selectAction(self)
    }
}
