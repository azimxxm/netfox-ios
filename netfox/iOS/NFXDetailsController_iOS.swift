//
//  NFXDetailsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit
import MessageUI

class NFXDetailsController_iOS: NFXDetailsController, MFMailComposeViewControllerDelegate {

    // MARK: - UI

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Info", "Request", "Response"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private var infoView: UIScrollView = UIScrollView()
    private var requestView: UIScrollView = UIScrollView()
    private var responseView: UIScrollView = UIScrollView()

    private var copyAlert: UIAlertController?
    internal var sharedContent: String?

    private lazy var infoViews: [UIScrollView] = {
        return [infoView, requestView, responseView]
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Details"
        view.layer.masksToBounds = true
        view.backgroundColor = .NFXBackgroundColor()

        // Navigation bar action button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.NFXShare(),
            style: .plain,
            target: self,
            action: #selector(actionButtonPressed(_:))
        )

        // Segmented control
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),
        ])

        // Create detail views
        infoView = createDetailsView(getInfoStringFromObject(selectedModel), forView: .info)
        requestView = createDetailsView(getRequestStringFromObject(selectedModel), forView: .request)
        responseView = createDetailsView(getResponseStringFromObject(selectedModel), forView: .response)

        for scrollView in [infoView, requestView, responseView] {
            view.addSubview(scrollView)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }

        // Swipe gestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)

        // Show info by default
        showView(at: 0)
    }

    // MARK: - View Switching

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        showView(at: sender.selectedSegmentIndex)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let current = segmentedControl.selectedSegmentIndex
        let count = segmentedControl.numberOfSegments

        switch gesture.direction {
        case .left:
            let next = min(current + 1, count - 1)
            segmentedControl.selectedSegmentIndex = next
            showView(at: next)
        case .right:
            let prev = max(current - 1, 0)
            segmentedControl.selectedSegmentIndex = prev
            showView(at: prev)
        default:
            break
        }
    }

    private func showView(at index: Int) {
        let views = [infoView, requestView, responseView]
        for (i, view) in views.enumerated() {
            view.isHidden = (i != index)
        }
    }

    // MARK: - Details View Factory

    func createDetailsView(_ content: NSAttributedString, forView: EDetailsView) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.font = .NFXFont(size: 13)
        textView.textColor = .NFXSecondaryTextColor()
        textView.isEditable = false
        textView.attributedText = content
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = []
        textView.delegate = self
        scrollView.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(copyLabel))
        textView.addGestureRecognizer(lpgr)

        // "Show body" button for large payloads
        let bodyLength: Int
        let bodyType: EDetailsView
        switch forView {
        case .request:
            bodyLength = selectedModel.requestBodyLength ?? 0
            bodyType = .request
        case .response:
            bodyLength = selectedModel.responseBodyLength ?? 0
            bodyType = .response
        default:
            bodyLength = 0
            bodyType = .info
        }

        if bodyLength > 1024 && bodyType != .info {
            let moreButton = UIButton(type: .system)
            moreButton.translatesAutoresizingMaskIntoConstraints = false
            moreButton.setTitle(bodyType == .request ? "Show request body" : "Show response body", for: .normal)
            moreButton.titleLabel?.font = .NFXFontBold(size: 14)
            moreButton.setTitleColor(.white, for: .normal)
            moreButton.backgroundColor = .NFXOrangeColor()
            moreButton.layer.cornerRadius = 8
            if bodyType == .request {
                moreButton.addTarget(self, action: #selector(requestBodyButtonPressed), for: .touchUpInside)
            } else {
                moreButton.addTarget(self, action: #selector(responseBodyButtonPressed), for: .touchUpInside)
            }
            scrollView.addSubview(moreButton)

            NSLayoutConstraint.activate([
                moreButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 12),
                moreButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                moreButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                moreButton.heightAnchor.constraint(equalToConstant: 44),
                moreButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            ])
        } else {
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20).isActive = true
        }

        return scrollView
    }

    // MARK: - Actions

    @objc func actionButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        actionSheet.addAction(UIAlertAction(title: "Simple log", style: .default) { [weak self] _ in
            self?.shareLog(full: false, sender: sender)
        })

        actionSheet.addAction(UIAlertAction(title: "Full log", style: .default) { [weak self] _ in
            self?.shareLog(full: true, sender: sender)
        })

        if let reqCurl = selectedModel.requestCurl {
            actionSheet.addAction(UIAlertAction(title: "Copy as cURL", style: .default) { [weak self] _ in
                UIPasteboard.general.string = reqCurl
                self?.showCopiedFeedback()
            })
        }

        actionSheet.view.tintColor = .NFXOrangeColor()
        actionSheet.popoverPresentationController?.barButtonItem = sender
        present(actionSheet, animated: true)
    }

    private func showCopiedFeedback() {
        let alert = UIAlertController(title: "Copied!", message: nil, preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true)
            }
        }
    }

    @objc fileprivate func copyLabel(lpgr: UILongPressGestureRecognizer) {
        guard lpgr.state == .began,
              let text = (lpgr.view as? UILabel)?.text ?? (lpgr.view as? UITextView)?.text,
              copyAlert == nil else { return }

        UIPasteboard.general.string = text
        showCopiedFeedback()
    }

    // MARK: - Body View

    @objc func responseBodyButtonPressed() {
        bodyButtonPressed().bodyType = .response
    }

    @objc func requestBodyButtonPressed() {
        bodyButtonPressed().bodyType = .request
    }

    @discardableResult
    func bodyButtonPressed() -> NFXGenericBodyDetailsController {
        let bodyDetailsController: NFXGenericBodyDetailsController

        if selectedModel.shortType == .IMAGE {
            bodyDetailsController = NFXImageBodyDetailsController()
        } else {
            bodyDetailsController = NFXRawBodyDetailsController()
        }
        bodyDetailsController.selectedModel(selectedModel)
        navigationController?.pushViewController(bodyDetailsController, animated: true)
        return bodyDetailsController
    }

    // MARK: - Sharing

    func shareLog(full: Bool, sender: UIBarButtonItem) {
        var tempString = ""

        tempString += "** INFO **\n"
        tempString += "\(getInfoStringFromObject(selectedModel).string)\n\n"

        tempString += "** REQUEST **\n"
        tempString += "\(getRequestStringFromObject(selectedModel).string)\n\n"

        tempString += "** RESPONSE **\n"
        tempString += "\(getResponseStringFromObject(selectedModel).string)\n\n"

        tempString += "logged via netfox - [https://github.com/azimxxm/netfox-ios]\n"

        if full {
            if let requestFileData = try? String(contentsOf: selectedModel.getRequestBodyFileURL(), encoding: .utf8) {
                tempString += requestFileData
            }
            if let responseFileData = try? String(contentsOf: selectedModel.getResponseBodyFileURL(), encoding: .utf8) {
                tempString += responseFileData
            }
        }

        displayShareSheet(shareContent: tempString, sender: sender)
    }

    func displayShareSheet(shareContent: String, sender: UIBarButtonItem) {
        sharedContent = shareContent
        let activityViewController = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        present(activityViewController, animated: true)
    }
}

// MARK: - UIActivityItemSource

extension NFXDetailsController_iOS: UIActivityItemSource {
    public typealias UIActivityType = UIActivity.ActivityType

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "placeholder"
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return sharedContent
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "netfox log - \(selectedModel.requestURL ?? "unknown")"
    }
}

// MARK: - UITextViewDelegate

extension NFXDetailsController_iOS: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let decodedURL = URL.absoluteString.removingPercentEncoding
        switch decodedURL {
        case "[URL]":
            guard let queryItems = selectedModel.requestURLQueryItems, !queryItems.isEmpty else {
                return false
            }
            let urlDetailsController = NFXURLDetailsController()
            urlDetailsController.selectedModel = selectedModel
            navigationController?.pushViewController(urlDetailsController, animated: true)
            return true
        default:
            return false
        }
    }
}

#endif
