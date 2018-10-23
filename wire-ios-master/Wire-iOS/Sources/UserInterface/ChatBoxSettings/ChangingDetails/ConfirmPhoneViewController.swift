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
import WireUtilities

fileprivate enum Section: Int {
    static var count: Int {
        return 2
    }
    
    case verificationCode = 0
    case buttons = 1
}

protocol ConfirmPhoneDelegate: class {
    func resendVerificationCode(inController controller: ConfirmPhoneViewController)
    func didConfirmPhone(inController controller: ConfirmPhoneViewController)
}

final class ConfirmPhoneViewController: SettingsBaseTableViewController {
    fileprivate weak var userProfile = ZMUserSession.shared()?.userProfile
    fileprivate var observer: NSObjectProtocol?
    fileprivate var observerToken: Any?
    
    fileprivate var verificationCode: String?
    fileprivate var resendEnabled: Bool = false
    fileprivate var timer: ZMTimer?

    weak var delegate: ConfirmPhoneDelegate?
    let newNumber: String
    
    init(newNumber: String, delegate: ConfirmPhoneDelegate?) {
        self.newNumber = newNumber
        self.delegate = delegate
        super.init(style: .grouped)
        setupViews()
    }
    
    deinit {
        timer?.cancel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observerToken = userProfile?.add(observer: self)
        observer = UserChangeInfo.add(observer: self, for: ZMUser.selfUser(), userSession: ZMUserSession.shared()!)
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        observer = nil
    }
    
    fileprivate func setupViews() {
        RegistrationTextFieldCell.register(in: tableView)
        SettingsButtonCell.register(in: tableView)
        
        title = "self.settings.account_section.phone_number.change.verify.title".localized
        view.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.contentInset = UIEdgeInsets(top: -32, left: 0, bottom: 0, right: 0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "self.settings.account_section.phone_number.change.verify.save".localized,
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    fileprivate func startTimer() {
        resendEnabled = false
        timer?.cancel()
        timer = ZMTimer(target: self, operationQueue: .main)
        timer?.fire(afterTimeInterval: 30)
    }
    
    fileprivate func reloadResendCell() {
        let resend = IndexPath(item: 0, section: Section.buttons.rawValue)
        tableView.reloadRows(at: [resend], with: .none)
    }
    
    func saveButtonTapped() {
        if let verificationCode = verificationCode {
            let credentials = ZMPhoneCredentials(phoneNumber: newNumber, verificationCode: verificationCode)
            userProfile?.requestPhoneNumberChange(credentials: credentials)
            showLoadingView = true
        }
    }
    
    fileprivate func updateSaveButtonState(enabled: Bool? = nil) {
        if let enabled = enabled {
            navigationItem.rightBarButtonItem?.isEnabled = enabled
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = (verificationCode != nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch Section(rawValue: section)! {
        case .verificationCode:
            let description = DescriptionHeaderView()
            let format = "self.settings.account_section.phone_number.change.verify.description".localized
            let text = String(format: format, newNumber)
            if let font = UIFont(magicIdentifier: "style.text.normal.font_spec_bold") {
                let attributedString = NSAttributedString(string: text).addAttributes([NSFontAttributeName : font], toSubstring: newNumber)
                description.descriptionLabel.font = UIFont(magicIdentifier: "style.text.normal.font_spec_medium")
                description.descriptionLabel.attributedText = attributedString
            }
            return description
        case .buttons:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .verificationCode:
            return nil
        case .buttons:
            return "self.settings.account_section.phone_number.change.verify.resend_description".localized
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor(white: 1, alpha: 0.4)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .verificationCode:
            let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationTextFieldCell.zm_reuseIdentifier, for: indexPath) as! RegistrationTextFieldCell
            cell.textField.accessibilityIdentifier = "ConfirmationCodeField"
            cell.textField.placeholder = "self.settings.account_section.phone_number.change.verify.code_placeholder".localized
            cell.textField.keyboardType = .numberPad
            cell.textField.becomeFirstResponder()
            cell.delegate = self
            return cell
        case .buttons:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsButtonCell.zm_reuseIdentifier, for: indexPath) as! SettingsButtonCell
            cell.titleText = "self.settings.account_section.phone_number.change.verify.resend".localized
            if resendEnabled {
                cell.titleColor = .white
                cell.selectionStyle = .default
            } else {
                cell.titleColor = UIColor(white: 1, alpha: 0.4)
                cell.selectionStyle = .none
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .verificationCode:
            break
        case .buttons:
            delegate?.resendVerificationCode(inController: self)
            let message = String(format: "self.settings.account_section.phone_number.change.resend.message".localized, newNumber)
            let alert = UIAlertController(
                title: "self.settings.account_section.phone_number.change.resend.title".localized,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(.init(title: "general.ok".localized, style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            startTimer()
            reloadResendCell()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ConfirmPhoneViewController: ZMUserObserver {
    
    func userDidChange(_ note: WireDataModel.UserChangeInfo) {
        if note.user.isSelfUser {
            // we need to check if the notification really happened because
            // the phone got changed to what we expected
            if let currentPhoneNumber = ZMUser.selfUser().phoneNumber, currentPhoneNumber == newNumber {
                showLoadingView = false
                delegate?.didConfirmPhone(inController: self)
            }
        }
    }
}

extension ConfirmPhoneViewController: UserProfileUpdateObserver {
    func phoneNumberChangeDidFail(_ error: Error!) {
        showLoadingView = false
        showAlert(forError: error)
    }
}

extension ConfirmPhoneViewController: RegistrationTextFieldCellDelegate {
    func tableViewCellDidChangeText(cell: RegistrationTextFieldCell, text: String) {
        verificationCode = text
        updateSaveButtonState()
    }
}

extension ConfirmPhoneViewController: ZMTimerClient {
    func timerDidFire(_ timer: ZMTimer!) {
        resendEnabled = true
        reloadResendCell()
    }
}

