//
//  NFXRawBodyDetailsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

class NFXRawBodyDetailsController: NFXGenericBodyDetailsController {

    private let bodyView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Body Details"

        bodyView.frame = view.bounds
        bodyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bodyView.backgroundColor = .clear
        bodyView.textColor = .NFXSecondaryTextColor()
        bodyView.textAlignment = .left
        bodyView.isEditable = false
        bodyView.isSelectable = true
        bodyView.font = .NFXMonoFont(size: 12)

        switch bodyType {
        case .request:
            bodyView.text = selectedModel.getRequestBody()
        default:
            bodyView.text = selectedModel.getResponseBody()
        }

        view.addSubview(bodyView)

        // Copy button in nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.NFXCopy(),
            style: .plain,
            target: self,
            action: #selector(copyBodyText)
        )
    }

    @objc private func copyBodyText() {
        UIPasteboard.general.string = bodyView.text
        let alert = UIAlertController(title: "Copied!", message: nil, preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true)
            }
        }
    }
}

#endif
