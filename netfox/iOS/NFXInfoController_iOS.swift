//
//  NFXInfoController_iOS.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS)

import UIKit

class NFXInfoController_iOS: NFXInfoController {

    private let scrollView = UIScrollView()
    private let textLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Info"

        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.autoresizesSubviews = true
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        textLabel.frame = CGRect(x: 20, y: 20, width: scrollView.frame.width - 40, height: scrollView.frame.height - 20)
        textLabel.font = .NFXFont(size: 13)
        textLabel.textColor = .NFXSecondaryTextColor()
        textLabel.attributedText = generateInfoString("Retrieving IP address..")
        textLabel.numberOfLines = 0
        textLabel.sizeToFit()
        scrollView.addSubview(textLabel)

        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: textLabel.frame.maxY)

        generateInfo()
    }

    private func generateInfo() {
        NFXDebugInfo.getNFXIP { [weak self] result in
            DispatchQueue.main.async {
                self?.textLabel.attributedText = self?.generateInfoString(result)
                self?.textLabel.sizeToFit()
                if let label = self?.textLabel {
                    self?.scrollView.contentSize = CGSize(width: label.frame.width, height: label.frame.maxY + 20)
                }
            }
        }
    }
}

#endif
