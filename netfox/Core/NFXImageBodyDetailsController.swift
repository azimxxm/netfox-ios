//
//  NFXImageBodyDetailsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

class NFXImageBodyDetailsController: NFXGenericBodyDetailsController {

    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Image Preview"

        imageView.frame = CGRect(
            x: 10,
            y: 10,
            width: view.frame.width - 20,
            height: view.frame.height - 20
        )
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit

        let bodyString = selectedModel.getResponseBody()
        if let data = Data(base64Encoded: bodyString, options: .ignoreUnknownCharacters) {
            imageView.image = UIImage(data: data)
        }

        view.addSubview(imageView)
    }
}

#endif
