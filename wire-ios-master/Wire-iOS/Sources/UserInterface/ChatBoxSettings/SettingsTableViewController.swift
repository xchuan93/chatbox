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
import Cartography

class SettingsBaseTableViewController: UIViewController {

    var tableView: UITableView
    let topSeparator = OverflowSeparatorView()
    let footerSeparator = OverflowSeparatorView()
    private let footerContainer = UIView()

    public var footer: UIView? {
        didSet {
            updateFooter(footer)
        }
    }

    final fileprivate class IntrinsicSizeTableView: UITableView {
        override var intrinsicContentSize: CGSize {
            get {
                return CGSize(width: UIViewNoIntrinsicMetric, height: self.contentSize.height)
            }
        }
    }
    
    init(style: UITableViewStyle) {
        tableView = IntrinsicSizeTableView(frame: .zero, style: style)
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = UIRectEdge()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }

    override func viewDidLoad() {
        self.createTableView()
        self.view.addSubview(self.topSeparator)
        self.createConstraints()
        self.view.backgroundColor = UIColor.clear
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    private func createTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        view.addSubview(footerContainer)
        footerContainer.addSubview(footerSeparator)
        footerSeparator.inverse = true
    }

    private func createConstraints() {
        constrain(view, tableView, topSeparator, footerContainer, footerSeparator) { view, tableView, topSeparator, footerContainer, footerSeparator in
            tableView.left == view.left
            tableView.right == view.right
            tableView.top == view.top

            topSeparator.left == tableView.left
            topSeparator.right == tableView.right
            topSeparator.top == tableView.top

            footerContainer.top == tableView.bottom
            footerContainer.left == tableView.left
            footerContainer.right == tableView.right
            footerContainer.bottom == view.bottom
            footerContainer.height == 0 ~ 750.0
            
            footerSeparator.left == footerContainer.left
            footerSeparator.right == footerContainer.right
            footerSeparator.top == footerContainer.top
        }
    }

    private func updateFooter(_ newFooter: UIView?) {
        footer?.removeFromSuperview()
        footerSeparator.isHidden = newFooter == nil
        guard let newFooter = newFooter else { return }
        footerContainer.addSubview(newFooter)
        constrain(footerContainer, newFooter) { container, footer in
            footer.edges == container.edges
        }
    }
}

extension SettingsBaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topSeparator.scrollViewDidScroll(scrollView: scrollView)
        self.footerSeparator.scrollViewDidScroll(scrollView: scrollView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        fatalError("Subclasses need to implement this method")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Subclasses need to implement this method")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclasses need to implement this method")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }

}


class SettingsTableViewController: SettingsBaseTableViewController {

    let group: SettingsInternalGroupCellDescriptorType
    fileprivate var selfUserObserver: NSObjectProtocol!
    @objc var dismissAction: ((SettingsTableViewController) -> ())? = .none


    required init(group: SettingsInternalGroupCellDescriptorType) {
        self.group = group
        super.init(style: group.style == .plain ? .plain : .grouped)
        self.title = group.title.localizedUppercase

        self.group.items.flatMap { return $0.cellDescriptors }.forEach {
            if let groupDescriptor = $0 as? SettingsGroupCellDescriptorType {
                groupDescriptor.viewController = self
            }
        }

        self.selfUserObserver = UserChangeInfo.add(observer: self, for: ZMUser.selfUser(), userSession: ZMUserSession.shared()!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        
        let closeButton = IconButton.closeButton()
        closeButton.addTarget(self, action: #selector(SettingsTableViewController.dismissRootNavigation(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    func setupTableView() {
        let allCellTypes: [SettingsTableCell.Type] = [SettingsTableCell.self, SettingsGroupCell.self, SettingsButtonCell.self, SettingsToggleCell.self, SettingsValueCell.self, SettingsTextCell.self]

        for aClass in allCellTypes {
            tableView.register(aClass, forCellReuseIdentifier: aClass.reuseIdentifier)
        }
    }

    func dismissRootNavigation(_ sender: AnyObject) {
        self.dismissAction?(self)
    }

    // MARK: - UITableViewDelegate & UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.group.visibleItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.visibleCellDescriptors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionDescriptor = self.group.visibleItems[(indexPath as NSIndexPath).section]
        let cellDescriptor = sectionDescriptor.visibleCellDescriptors[(indexPath as NSIndexPath).row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: cellDescriptor).cellType.reuseIdentifier, for: indexPath) as? SettingsTableCell {
            cell.descriptor = cellDescriptor
            cellDescriptor.featureCell(cell)
            cell.isFirst = indexPath.row == 0
            return cell
        }

        fatalError("Cannot dequeue cell for index path \(indexPath) and cellDescriptor \(cellDescriptor)")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionDescriptor = self.group.visibleItems[(indexPath as NSIndexPath).section]
        let property = sectionDescriptor.visibleCellDescriptors[(indexPath as NSIndexPath).row]

        property.select(.none)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.footer
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor(white: 1, alpha: 0.4)
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor(white: 1, alpha: 0.4)
        }
    }

}

extension SettingsTableViewController: ZMUserObserver {
    func userDidChange(_ note: UserChangeInfo) {
        if note.accentColorValueChanged {
            self.tableView.reloadData()
        }
    }
}
