//
//  NFXGenericController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

class NFXGenericController: NFXViewController {

    var selectedModel: NFXHTTPModel = NFXHTTPModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        #if os(iOS)
        edgesForExtendedLayout = UIRectEdge.all
        view.backgroundColor = NFXColor.NFXGroupedBackgroundColor()
        #elseif os(OSX)
        view.wantsLayer = true
        view.layer?.backgroundColor = NFXColor.NFXGray95Color().cgColor
        #endif
    }

    func selectedModel(_ model: NFXHTTPModel) {
        selectedModel = model
    }

    func formatNFXString(_ string: String) -> NSAttributedString {
        let tempMutableString = NSMutableAttributedString(string: string)
        let stringCount = string.count

        // Bold + orange for section headers
        if let regexBodyHeaders = try? NSRegularExpression(
            pattern: "(\\-- Body \\--)|(\\-- Headers \\--)",
            options: .caseInsensitive
        ) {
            let matchesBodyHeaders = regexBodyHeaders.matches(
                in: string,
                options: .withoutAnchoringBounds,
                range: NSRange(location: 0, length: stringCount)
            )
            for match in matchesBodyHeaders {
                tempMutableString.addAttribute(.font, value: NFXFont.NFXFontBold(size: 14), range: match.range)
                tempMutableString.addAttribute(.foregroundColor, value: NFXColor.NFXOrangeColor(), range: match.range)
            }
        }

        // Tappable links for key labels
        if let regexKeys = try? NSRegularExpression(
            pattern: "\\[.+?\\]",
            options: .caseInsensitive
        ) {
            let matchesKeys = regexKeys.matches(
                in: string,
                options: .withoutAnchoringBounds,
                range: NSRange(location: 0, length: stringCount)
            )
            for match in matchesKeys {
                tempMutableString.addAttribute(.foregroundColor, value: NFXColor.NFXBlackColor(), range: match.range)
                tempMutableString.addAttribute(
                    .link,
                    value: (string as NSString).substring(with: match.range),
                    range: match.range
                )
            }
        }

        return tempMutableString
    }

    @objc func reloadData() { }
}
