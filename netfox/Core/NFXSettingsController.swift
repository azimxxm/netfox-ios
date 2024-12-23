//
//  NFXSettingsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//
    
import Foundation

class NFXSettingsController: NFXGenericController {
    // MARK: Properties

    let nfxVersionString = "netfox - \(nfxVersion)"
    var nfxURL = "https://github.com/azimxxm/netfox-ios"
    
    var tableData = [HTTPModelShortType]()
    var filters = NFXHTTPModelManager.shared.filters
}
