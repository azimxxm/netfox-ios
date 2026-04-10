//
//  NFXSettingsController_iOS.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS)

import UIKit
import MessageUI

class NFXSettingsController_iOS: NFXSettingsController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, DataCleaner {

    var tableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        nfxURL = "https://github.com/azimxxm/netfox-ios"
        title = "Settings"

        tableData = HTTPModelShortType.allCases

        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = false

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage.NFXStatistics(),
                style: .plain,
                target: self,
                action: #selector(statisticsButtonPressed)
            ),
            UIBarButtonItem(
                image: UIImage.NFXInfo(),
                style: .plain,
                target: self,
                action: #selector(infoButtonPressed)
            )
        ]

        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 60)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = .NFXGroupedBackgroundColor()

        view.addSubview(tableView)

        let nfxVersionLabel = UILabel(frame: CGRect(x: 10, y: view.frame.height - 60, width: view.frame.width - 20, height: 30))
        nfxVersionLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        nfxVersionLabel.font = .NFXFont(size: 14)
        nfxVersionLabel.textColor = .NFXOrangeColor()
        nfxVersionLabel.textAlignment = .center
        nfxVersionLabel.text = nfxVersionString
        view.addSubview(nfxVersionLabel)

        let nfxURLButton = UIButton(frame: CGRect(x: 10, y: view.frame.height - 40, width: view.frame.width - 20, height: 30))
        nfxURLButton.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        nfxURLButton.titleLabel?.font = .NFXFont(size: 12)
        nfxURLButton.setTitleColor(.NFXSecondaryTextColor(), for: .normal)
        nfxURLButton.titleLabel?.textAlignment = .center
        nfxURLButton.setTitle(nfxURL, for: .normal)
        nfxURLButton.addTarget(self, action: #selector(nfxURLButtonPressed), for: .touchUpInside)
        view.addSubview(nfxURLButton)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NFXHTTPModelManager.shared.filters = filters
    }

    @objc func nfxURLButtonPressed() {
        guard let url = URL(string: nfxURL) else { return }
        UIApplication.shared.open(url)
    }

    @objc func infoButtonPressed() {
        let infoController = NFXInfoController_iOS()
        navigationController?.pushViewController(infoController, animated: true)
    }

    @objc func statisticsButtonPressed() {
        let statisticsController = NFXStatisticsController_iOS()
        navigationController?.pushViewController(statisticsController, animated: true)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return tableData.count
        case 2: return 1
        case 3: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = .NFXFont(size: 14)
        cell.textLabel?.textColor = .NFXPrimaryTextColor()
        cell.tintColor = .NFXOrangeColor()
        cell.backgroundColor = .NFXSecondaryBackgroundColor()

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Logging"
            let nfxEnabledSwitch = UISwitch()
            nfxEnabledSwitch.onTintColor = .NFXOrangeColor()
            nfxEnabledSwitch.setOn(NFX.sharedInstance().isEnabled(), animated: false)
            nfxEnabledSwitch.addTarget(self, action: #selector(nfxEnabledSwitchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = nfxEnabledSwitch
            return cell

        case 1:
            let shortType = tableData[indexPath.row]
            cell.textLabel?.text = shortType.rawValue
            configureCell(cell, indexPath: indexPath)
            return cell

        case 2:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Share Session Logs"
            cell.textLabel?.textColor = .NFXGreenColor()
            cell.textLabel?.font = .NFXFontBold(size: 15)
            return cell

        case 3:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Clear Data"
            cell.textLabel?.textColor = .NFXRedColor()
            cell.textLabel?.font = .NFXFontBold(size: 15)
            return cell

        default:
            return UITableViewCell()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Response Type Filters"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1: return "Select the types of responses that you want to see"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let cell = tableView.cellForRow(at: indexPath)
            filters[indexPath.row] = !filters[indexPath.row]
            configureCell(cell, indexPath: indexPath)
        case 2:
            shareSessionLogsPressed()
        case 3:
            clearDataButtonPressedOnTableIndex(indexPath)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 44
        case 1: return 40
        case 2, 3: return 44
        default: return 0
        }
    }

    func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
        cell?.accessoryType = filters[indexPath.row] ? .checkmark : .none
    }

    @objc func nfxEnabledSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            NFX.sharedInstance().enable()
        } else {
            NFX.sharedInstance().disable()
        }
    }

    func clearDataButtonPressedOnTableIndex(_ index: IndexPath) {
        clearData(sourceView: tableView, originingIn: tableView.rectForRow(at: index)) { }
    }

    func shareSessionLogsPressed() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short

            mailComposer.setSubject("netfox log - Session Log \(dateFormatter.string(from: Date()))")
            if let sessionLogData = try? Data(contentsOf: NFXPath.sessionLogURL) {
                mailComposer.addAttachmentData(sessionLogData, mimeType: "text/plain", fileName: NFXPath.sessionLogName)
            }

            present(mailComposer, animated: true)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}

#endif
