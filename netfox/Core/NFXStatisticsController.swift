//
//  NFXStatisticsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation

class NFXStatisticsController: NFXGenericController {
    var totalModels: Int = 0

    var successfulRequests: Int = 0
    var failedRequests: Int = 0

    var totalRequestSize: Int = 0
    var totalResponseSize: Int = 0

    var totalResponseTime: Float = 0

    var fastestResponseTime: Float = 999
    var slowestResponseTime: Float = 0

    private lazy var dataSubscription = Subscription<[NFXHTTPModel]> { [weak self] in self?.reloadData(with: $0) }

    deinit {
        dataSubscription.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NFXHTTPModelManager.shared.publisher.subscribe(dataSubscription)
        reloadData(with: NFXHTTPModelManager.shared.filteredModels)
    }

    func getReportString() -> NSAttributedString {
        var tempString = ""

        tempString += "[Total requests] \n\(totalModels)\n\n"
        tempString += "[Successful requests] \n\(successfulRequests)\n\n"
        tempString += "[Failed requests] \n\(failedRequests)\n\n"

        let totalReqKB = Float(totalRequestSize) / 1024.0
        tempString += "[Total request size] \n\(String(format: "%.1f", totalReqKB)) KB\n\n"

        if totalModels > 0 {
            let avgReqKB = Float(totalRequestSize) / Float(totalModels) / 1024.0
            tempString += "[Avg request size] \n\(String(format: "%.1f", avgReqKB)) KB\n\n"
        } else {
            tempString += "[Avg request size] \n0.0 KB\n\n"
        }

        let totalResKB = Float(totalResponseSize) / 1024.0
        tempString += "[Total response size] \n\(String(format: "%.1f", totalResKB)) KB\n\n"

        if totalModels > 0 {
            let avgResKB = Float(totalResponseSize) / Float(totalModels) / 1024.0
            tempString += "[Avg response size] \n\(String(format: "%.1f", avgResKB)) KB\n\n"
        } else {
            tempString += "[Avg response size] \n0.0 KB\n\n"
        }

        if totalModels > 0 {
            let avgTime = totalResponseTime / Float(totalModels)
            tempString += "[Avg response time] \n\(String(format: "%.3f", avgTime))s\n\n"

            let fastest = fastestResponseTime == 999 ? 0 : fastestResponseTime
            tempString += "[Fastest response time] \n\(String(format: "%.3f", fastest))s\n\n"
        } else {
            tempString += "[Avg response time] \n0.0s\n\n"
            tempString += "[Fastest response time] \n0.0s\n\n"
        }

        tempString += "[Slowest response time] \n\(String(format: "%.3f", slowestResponseTime))s\n\n"

        return formatNFXString(tempString)
    }

    private func reloadData(with models: [NFXHTTPModel]) {
        clearStatistics()
        generateStatistics(models)
        reloadData()
    }

    private func generateStatistics(_ models: [NFXHTTPModel]) {
        totalModels = models.count

        for model in models {
            if model.isSuccessful() {
                successfulRequests += 1
            } else {
                failedRequests += 1
            }

            if let bodyLength = model.requestBodyLength {
                totalRequestSize += bodyLength
            }

            if let bodyLength = model.responseBodyLength {
                totalResponseSize += bodyLength
            }

            if let interval = model.timeInterval {
                totalResponseTime += interval

                if interval < fastestResponseTime {
                    fastestResponseTime = interval
                }

                if interval > slowestResponseTime {
                    slowestResponseTime = interval
                }
            }
        }
    }

    private func clearStatistics() {
        totalModels = 0
        successfulRequests = 0
        failedRequests = 0
        totalRequestSize = 0
        totalResponseSize = 0
        totalResponseTime = 0
        fastestResponseTime = 999
        slowestResponseTime = 0
    }
}
