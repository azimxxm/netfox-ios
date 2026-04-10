//
//  NFXMetricsCapture.swift
//  netfox
//
//  B7: Captures URLSessionTaskMetrics via delegate callback.
//  Adds metrics storage to NFXHTTPModel without modifying NFXProtocol.swift.
//

#if os(iOS)

import Foundation

// Store metrics on the model using associated objects to avoid modifying NFXHTTPModel
// (which is @objc and shared with OSX)
private var metricsKey: UInt8 = 0

extension NFXHTTPModel {
    var taskMetrics: NFXRequestMetrics? {
        get { objc_getAssociatedObject(self, &metricsKey) as? NFXRequestMetrics }
        set { objc_setAssociatedObject(self, &metricsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

#endif
