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

import Foundation
import MessageUI

/// Presents debug alerts
@objc public class DebugAlert: NSObject {
    
    private static var isShown = false
    
    /// Presents an alert, if in developer mode, otherwise do nothing
    static func showGeneric(message: String) {
        self.show(message: message)
    }
    
    /// Presents an alert to send logs, if in developer mode, otherwise do nothing
    static func showSendLogsMessage(message: String) {
        self.show(
            message: message,
            okText: "Send",
            okAction: { DebugLogSender.sendLogsByEmail(message: message) },
            okType: .destructive,
            title: "Send debug logs"
        )
    }
    
    /// Presents a debug alert with configurable messages and events.
    /// If not in developer mode, does nothing.
    private static func show(
        message: String,
        okText: String = "OK",
        okAction: (() -> Void)? = nil,
        okType: UIAlertActionStyle = .default,
        title: String = "DEBUG MESSAGE",
        cancelText: String? = "Cancel"
        ) {

        guard DeveloperMenuState.developerMenuEnabled() else { return }
        guard let controller = UIApplication.shared.wr_topmostController(onlyFullScreen: false), !isShown else { return }
        isShown = true
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: okText, style: okType) { _ in
            isShown = false
            okAction?()
        }
        alert.addAction(okAlertAction)

        if let cancelText = cancelText {
            let cancelAction = UIAlertAction(title: cancelText, style: .cancel) { _ in
                isShown = false
            }
            alert.addAction(cancelAction)
        }

        controller.present(alert, animated: true, completion: nil)
    }
    
    static func displayFallbackActivityController(logData: Data, logFileName: String, email: String, from controller: UIViewController) {
        let alert = UIAlertController(title: "self.settings.technical_report_section.title".localized,
                                      message: "self.settings.technical_report.no_mail_alert".localized + email,
                                      cancelButtonTitle: "general.cancel".localized)
        alert.addAction(UIAlertAction(title: "general.ok".localized, style: .default, handler: { (action) in
            let url = URL(fileURLWithPath: NSTemporaryDirectory().appendingPathComponent(logFileName))
            try! logData.write(to: url)
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activity.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                try! FileManager.default.removeItem(at: url)
            }
            controller.present(activity, animated: true, completion: nil)
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
}

/// Sends debug logs by email
@objc public class DebugLogSender: NSObject, MFMailComposeViewControllerDelegate {

    private var mailViewController : MFMailComposeViewController? = nil
    static private var senderInstance: DebugLogSender? = nil

    /// Sends recorded logs by email
    static func sendLogsByEmail(message: String) {
        guard let controller = UIApplication.shared.wr_topmostController(onlyFullScreen: false) else { return }
        guard self.senderInstance == nil else { return }
        
        let logs = ZMSLog.recordedContent
        guard !logs.isEmpty else {
            DebugAlert.showGeneric(message: "There are no logs to send, have you enabled them from the debug menu > log settings BEFORE the issue happened?\nWARNING: restarting the app will discard all collected logs")
            return
        }
        
        // Prepare subject & body
        let user = ZMUser.selfUser()
        let userID = user?.remoteIdentifier?.transportString() ?? ""
        let device = UIDevice.current.name
        let now = Date()
        let userDescription = "\(user?.name ?? "") [user: \(userID)] [device: \(device)]"
        let message = "Logs for: \(message)\n\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timeStr = formatter.string(from: now)
        let fileName = "logs_\(user?.name ?? userID)_T\(timeStr).txt"
        let completeLog = logs.joined(separator: "\n")
        let mail = "ios@chatbox.tech"
        
        guard MFMailComposeViewController.canSendMail() else {
            // Adds user description and message (usually attached to the mail)
            // on top of the complete log
            let completeLogWithMessage = [userDescription, message, completeLog].joined(separator: "\n")
            let logData = completeLogWithMessage.data(using: .utf8)!
            DebugAlert.displayFallbackActivityController(logData: logData, logFileName: fileName, email: mail, from: controller)
            return
        }
        
        // compose
        
        let alert = DebugLogSender()
        let logData = completeLog.data(using: .utf8)!
        
        let mailVC = MFMailComposeViewController()
        mailVC.setToRecipients([mail])
        mailVC.setSubject("iOS logs from \(userDescription)")
        mailVC.setMessageBody(message, isHTML: false)
        mailVC.addAttachmentData(logData, mimeType: "text/plain", fileName: fileName)
        mailVC.mailComposeDelegate = alert
        alert.mailViewController = mailVC
        
        self.senderInstance = alert
        controller.present(mailVC, animated: true, completion: nil)
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
        self.mailViewController = nil
        controller.dismiss(animated: true)
        type(of: self).senderInstance = nil
    }
}
