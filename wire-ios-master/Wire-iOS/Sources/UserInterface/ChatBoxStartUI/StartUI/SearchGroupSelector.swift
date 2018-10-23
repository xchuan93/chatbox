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

final class SearchGroupButton: UIButton {
    let colorSchemeVariant : ColorSchemeVariant

    init(variant: ColorSchemeVariant) {
        colorSchemeVariant = variant
        super.init(frame: .zero)
        
        addSubview(selectionLineView)
        constrain(self, selectionLineView) { selfView, selectionLineView in
            selectionLineView.leading == selfView.leading + 16
            selectionLineView.trailing == selfView.trailing - 16
            selectionLineView.height == 1
            selectionLineView.bottom == selfView.bottom
        }
        
        titleLabel?.font = FontSpec(.small, .semibold).font
        
        isSelected = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var group: SearchGroup = .people {
        didSet {
            self.setTitle(group.name.uppercased(), for: .normal)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 48)
    }
    
    private let selectionLineView = UIView()
    
    override var isSelected: Bool {
        didSet {
            let selectionColor: UIColor
            switch self.colorSchemeVariant {
            case .dark:
                selectionColor = .white
            case .light:
                selectionColor = .black
            }
            
            selectionLineView.backgroundColor = isSelected ? selectionColor : .clear
            setTitleColor(isSelected ? selectionColor : selectionColor.withAlphaComponent(0.5), for: .normal)
        }
    }
}

final class SearchGroupSelector: UIView {
    private let radioButtonsView: RadioButtonsView<SearchGroupButton>
    let colorSchemeVariant : ColorSchemeVariant

    
    @objc public var group: SearchGroup = .people {
        didSet {
            onGroupSelected?(group)
        }
    }
    @objc public var onGroupSelected: ((SearchGroup)->())? = nil
    
    private static var shouldShowBotResults: Bool {
        return DeveloperMenuState.developerMenuEnabled() && ZMUser.selfUser().team != nil
    }
    
    init(variant: ColorSchemeVariant) {
        let radioButtons: [SearchGroupButton] = SearchGroup.all.map {
            let button = SearchGroupButton(variant: variant)
            button.group = $0
            return button
        }
        radioButtonsView = RadioButtonsView(buttons: radioButtons)
        colorSchemeVariant = variant
        super.init(frame: .zero)
        
        radioButtons.forEach {
            $0.addCallback(for: .touchUpInside) { [weak self] button in
                self?.group = button.group
            }
        }
        
        guard SearchGroupSelector.shouldShowBotResults else {
            return
        }
        
        backgroundColor = UIColor.wr_color(fromColorScheme: ColorSchemeColorBarBackground, variant: colorSchemeVariant)

        addSubview(radioButtonsView)

        constrain(self, radioButtonsView) { selfView, radioButtonsView in
            radioButtonsView.edges == selfView.edges
        }
        
        radioButtonsView.selectedIndex = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
