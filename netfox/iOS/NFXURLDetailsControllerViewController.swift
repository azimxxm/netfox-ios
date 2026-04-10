//
//  NFXURLDetailsController.swift
//  netfox_ios
//
//  Created by Tzatzo, Marsel on 05/06/2019.
//  Copyright © 2019 kasketis. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

class NFXURLDetailsController: NFXDetailsController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "URL Query Strings"
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = true

        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .NFXGroupedBackgroundColor()
        view.addSubview(tableView)
    }
}

extension NFXURLDetailsController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")

        if let queryItem = selectedModel.requestURLQueryItems?[indexPath.row] {
            cell.textLabel?.text = queryItem.name
            cell.textLabel?.textColor = .NFXPrimaryTextColor()
            cell.textLabel?.font = .NFXFontBold(size: 13)
            cell.detailTextLabel?.text = queryItem.value
            cell.detailTextLabel?.textColor = .NFXSecondaryTextColor()
            cell.detailTextLabel?.font = .NFXFont(size: 13)
        }
        cell.backgroundColor = .NFXSecondaryBackgroundColor()
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedModel.requestURLQueryItems?.count ?? 0
    }
}

#endif
