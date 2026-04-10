//
//  NFXDetailsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation

class NFXDetailsController: NFXGenericController {

    enum EDetailsView {
        case info
        case request
        case response
    }

    private enum Constants: String {
        case headersTitle = "-- Headers --\n\n"
        case bodyTitle = "\n-- Body --\n\n"
        case tooLongToShowTitle = "Too long to show. If you want to see it, please tap the following button\n"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func getInfoStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        var tempString = ""

        tempString += "[URL] \n\(object.requestURL ?? "-")\n\n"
        tempString += "[Method] \n\(object.requestMethod ?? "-")\n\n"
        if !object.noResponse {
            tempString += "[Status] \n\(object.responseStatus ?? 0)\n\n"
        }
        tempString += "[Request date] \n\(object.requestDate.map { "\($0)" } ?? "-")\n\n"
        if !object.noResponse {
            tempString += "[Response date] \n\(object.responseDate.map { "\($0)" } ?? "-")\n\n"
            tempString += "[Time interval] \n\(object.timeInterval.map { "\($0)" } ?? "-")\n\n"
        }
        tempString += "[Timeout] \n\(object.requestTimeout ?? "-")\n\n"
        tempString += "[Cache policy] \n\(object.requestCachePolicy ?? "-")\n\n"

        return formatNFXString(tempString)
    }

    func getRequestStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        var tempString = ""

        tempString += Constants.headersTitle.rawValue

        if let headers = object.requestHeaders, !headers.isEmpty {
            for (key, val) in headers {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Request headers are empty\n\n"
        }

        #if os(iOS)
        tempString += getRequestBodyStringFooter(object)
        #endif
        return formatNFXString(tempString)
    }

    func getRequestBodyStringFooter(_ object: NFXHTTPModel) -> String {
        var tempString = Constants.bodyTitle.rawValue
        let bodyLength = object.requestBodyLength ?? 0
        if bodyLength == 0 {
            tempString += "Request body is empty\n"
        } else if bodyLength > 1024 {
            tempString += Constants.tooLongToShowTitle.rawValue
        } else {
            tempString += "\(object.getRequestBody())\n"
        }
        return tempString
    }

    func getResponseStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        if object.noResponse {
            return NSMutableAttributedString(string: "No response")
        }

        var tempString = ""

        tempString += Constants.headersTitle.rawValue

        if let headers = object.responseHeaders, !headers.isEmpty {
            for (key, val) in headers {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Response headers are empty\n\n"
        }

        #if os(iOS)
        tempString += getResponseBodyStringFooter(object)
        #endif
        return formatNFXString(tempString)
    }

    func getResponseBodyStringFooter(_ object: NFXHTTPModel) -> String {
        var tempString = Constants.bodyTitle.rawValue
        let bodyLength = object.responseBodyLength ?? 0
        if bodyLength == 0 {
            tempString += "Response body is empty\n"
        } else if bodyLength > 1024 {
            tempString += Constants.tooLongToShowTitle.rawValue
        } else {
            tempString += "\(object.getResponseBody())\n"
        }
        return tempString
    }
}
