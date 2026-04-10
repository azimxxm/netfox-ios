//
//  NFXListController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

class NFXListController_iOS: NFXListController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, DataCleaner {

    // MARK: Properties

    var tableView = UITableView(frame: .zero, style: .plain)
    var searchController: UISearchController!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Requests"

        edgesForExtendedLayout = UIRectEdge.all
        extendedLayoutIncludesOpaqueBars = true

        tableView.frame = view.frame
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .NFXBackgroundColor()
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        tableView.register(NFXListCell.self, forCellReuseIdentifier: NSStringFromClass(NFXListCell.self))

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.NFXClose(),
            style: .plain,
            target: self,
            action: #selector(closeButtonPressed)
        )

        let rightButtons = [
            UIBarButtonItem(
                image: UIImage.NFXTrash(),
                style: .plain,
                target: self,
                action: #selector(trashButtonPressed)
            ),
            UIBarButtonItem(
                image: UIImage.NFXSettings(),
                style: .plain,
                target: self,
                action: #selector(settingsButtonPressed)
            )
        ]
        navigationItem.rightBarButtonItems = rightButtons

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.NFXOrangeColor()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func reloadData() {
        tableView.reloadData()
    }

    @objc func settingsButtonPressed() {
        let settingsController = NFXSettingsController_iOS()
        navigationController?.pushViewController(settingsController, animated: true)
    }

    @objc func trashButtonPressed() {
        clearData(sourceView: tableView, originingIn: nil) { [weak self] in
            self?.reloadData()
        }
    }

    @objc func closeButtonPressed() {
        NFX.sharedInstance().hide()
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        filter = searchController.searchBar.text
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(NFXListCell.self), for: indexPath) as? NFXListCell else {
            return UITableViewCell()
        }
        if indexPath.row < tableData.count {
            cell.configForObject(tableData[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < tableData.count else { return }
        let detailsController = NFXDetailsController_iOS()
        let model = tableData[indexPath.row]
        detailsController.selectedModel(model)
        navigationController?.pushViewController(detailsController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}

#endif
