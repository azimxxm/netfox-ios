//
//  NFXStatisticsController_iOS.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS)

import UIKit

class NFXStatisticsController_iOS: NFXStatisticsController {

    private let scrollView = UIScrollView()
    private let textLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Statistics"

        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.autoresizesSubviews = true
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        textLabel.frame = CGRect(x: 20, y: 20, width: scrollView.frame.width - 40, height: scrollView.frame.height - 20)
        textLabel.font = .NFXFont(size: 13)
        textLabel.textColor = .NFXSecondaryTextColor()
        textLabel.numberOfLines = 0
        textLabel.sizeToFit()
        scrollView.addSubview(textLabel)

        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: textLabel.frame.maxY)
    }

    override func reloadData() {
        super.reloadData()
        textLabel.attributedText = getReportString()
        textLabel.sizeToFit()
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: textLabel.frame.maxY + 20)
    }
}

#endif
