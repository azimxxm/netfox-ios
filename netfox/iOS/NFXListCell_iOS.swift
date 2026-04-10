//
//  NFXListCell.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation

#if os(iOS)

import UIKit

class NFXListCell: UITableViewCell {

    // MARK: - Subviews

    private let statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let methodLabel: UILabel = {
        let label = UILabel()
        label.font = .NFXFontBold(size: 11)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = .NFXFont(size: 13)
        label.textColor = .NFXPrimaryTextColor()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .NFXFont(size: 11)
        label.textColor = .NFXTertiaryTextColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .NFXMonoFont(size: 11)
        label.textColor = .NFXSecondaryTextColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .NFXFont(size: 11)
        label.textColor = .NFXTertiaryTextColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let newBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .NFXOrangeColor()
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .NFXSeparatorColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .NFXBackgroundColor()
        selectionStyle = .none

        contentView.addSubview(statusIndicator)
        contentView.addSubview(methodLabel)
        contentView.addSubview(urlLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(newBadge)
        contentView.addSubview(separatorLine)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Status indicator (left edge dot)
            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 8),
            statusIndicator.heightAnchor.constraint(equalToConstant: 8),

            // Method badge
            methodLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 10),
            methodLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            methodLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            methodLabel.heightAnchor.constraint(equalToConstant: 20),

            // Time (top right)
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.centerYAnchor.constraint(equalTo: methodLabel.centerYAnchor),

            // URL label
            urlLabel.leadingAnchor.constraint(equalTo: methodLabel.leadingAnchor),
            urlLabel.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 4),
            urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36),

            // Duration (bottom left)
            durationLabel.leadingAnchor.constraint(equalTo: methodLabel.leadingAnchor),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            // Type (next to duration)
            typeLabel.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 8),
            typeLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),

            // New badge
            newBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newBadge.centerYAnchor.constraint(equalTo: urlLabel.centerYAnchor),
            newBadge.widthAnchor.constraint(equalToConstant: 6),
            newBadge.heightAnchor.constraint(equalToConstant: 6),

            // Separator
            separatorLine.leadingAnchor.constraint(equalTo: methodLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
        ])
    }

    // MARK: - Configuration

    func configForObject(_ obj: NFXHTTPModel) {
        setURL(obj.requestURL ?? "-")
        setStatus(obj.responseStatus ?? 999)
        setTimeInterval(obj.timeInterval ?? 999)
        setRequestTime(obj.requestTime ?? "-")
        setType(obj.responseType ?? "-")
        setMethod(obj.requestMethod ?? "-")
        isNewBasedOnDate(obj.responseDate ?? Date())
    }

    private func setURL(_ url: String) {
        urlLabel.text = url
    }

    private func setStatus(_ status: Int) {
        if status == 999 {
            // Pending / no response
            statusIndicator.backgroundColor = .NFXGray44Color()
            methodLabel.backgroundColor = UIColor.systemGray5
            methodLabel.textColor = .NFXSecondaryTextColor()
        } else if status < 400 {
            // Success
            statusIndicator.backgroundColor = .NFXGreenColor()
            methodLabel.backgroundColor = UIColor.NFXGreenColor().withAlphaComponent(0.15)
            methodLabel.textColor = .NFXDarkGreenColor()
        } else {
            // Error
            statusIndicator.backgroundColor = .NFXRedColor()
            methodLabel.backgroundColor = UIColor.NFXRedColor().withAlphaComponent(0.15)
            methodLabel.textColor = .NFXDarkRedColor()
        }
    }

    private func setRequestTime(_ requestTime: String) {
        timeLabel.text = requestTime
    }

    private func setTimeInterval(_ timeInterval: Float) {
        if timeInterval == 999 {
            durationLabel.text = "..."
        } else if timeInterval < 1.0 {
            durationLabel.text = String(format: "%.0fms", timeInterval * 1000)
        } else {
            durationLabel.text = String(format: "%.2fs", timeInterval)
        }
    }

    private func setType(_ type: String) {
        typeLabel.text = type
    }

    private func setMethod(_ method: String) {
        methodLabel.text = " \(method) "
    }

    private func isNewBasedOnDate(_ responseDate: Date) {
        newBadge.isHidden = !(responseDate > NFX.sharedInstance().getLastVisitDate())
    }
}

#endif
