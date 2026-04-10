//
//  NFXCertificateInfo.swift
//  netfox
//
//  D6: TLS certificate info capture and storage.
//  Uses associated objects on NFXHTTPModel to avoid modifying the @objc model.
//

#if os(iOS)

import Foundation
import Security

// MARK: - Certificate Info Model

struct NFXCertificateInfo {
    let subject: String
    let issuer: String
    let expiryDate: Date?
    let publicKeyAlgorithm: String
    let isSelfSigned: Bool

    init(from serverTrust: SecTrust) {
        let certCount = SecTrustGetCertificateCount(serverTrust)

        guard certCount > 0,
              let certChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let leafCert = certChain.first else {
            self.subject = "Unknown"
            self.issuer = "Unknown"
            self.expiryDate = nil
            self.publicKeyAlgorithm = "Unknown"
            self.isSelfSigned = false
            return
        }

        let summary = SecCertificateCopySubjectSummary(leafCert) as String? ?? "Unknown"
        self.subject = summary

        // Extract details from certificate values
        var issuerName = "Unknown"
        var expiry: Date?
        var keyAlgorithm = "Unknown"

        if let certValues = SecCertificateCopyValues(leafCert, nil, nil) as? [String: Any] {
            // Issuer name
            if let issuerDict = certValues["2.16.840.1.113741.2.1.1.1.5"] as? [String: Any],
               let issuerValue = issuerDict[kSecPropertyKeyValue as String] {
                issuerName = "\(issuerValue)"
            } else if let issuerDict = certValues["2.5.4.3"] as? [String: Any],
                      let issuerValue = issuerDict[kSecPropertyKeyValue as String] {
                issuerName = "\(issuerValue)"
            }
        }

        // Use OID-based approach for dates and key info
        if let dict = SecCertificateCopyValues(leafCert, [
            kSecOIDX509V1ValidityNotAfter,
            kSecOIDX509V1IssuerName,
            kSecOIDX509V1SubjectPublicKeyAlgorithm
        ] as CFArray, nil) as? [String: [String: Any]] {

            // Expiry date
            if let expirySection = dict[kSecOIDX509V1ValidityNotAfter as String],
               let expiryNumber = expirySection[kSecPropertyKeyValue as String] as? NSNumber {
                // CoreFoundation absolute time (seconds since Jan 1, 2001)
                expiry = Date(timeIntervalSinceReferenceDate: expiryNumber.doubleValue)
            }

            // Issuer
            if let issuerSection = dict[kSecOIDX509V1IssuerName as String],
               let issuerEntries = issuerSection[kSecPropertyKeyValue as String] as? [[String: Any]] {
                for entry in issuerEntries {
                    if let label = entry[kSecPropertyKeyLabel as String] as? String,
                       label == "2.5.4.3",
                       let value = entry[kSecPropertyKeyValue as String] as? String {
                        issuerName = value
                        break
                    }
                }
            }

            // Public key algorithm
            if let keySection = dict[kSecOIDX509V1SubjectPublicKeyAlgorithm as String],
               let keyValue = keySection[kSecPropertyKeyValue as String] as? String {
                keyAlgorithm = keyValue
            }
        }

        self.issuer = issuerName
        self.expiryDate = expiry
        self.publicKeyAlgorithm = keyAlgorithm

        // Self-signed: only one cert in chain, or issuer matches subject
        self.isSelfSigned = (certCount == 1) || (issuerName == summary)
    }
}

// MARK: - Associated Object on NFXHTTPModel

private var certificateInfoKey: UInt8 = 0

extension NFXHTTPModel {
    var certificateInfo: NFXCertificateInfo? {
        get { objc_getAssociatedObject(self, &certificateInfoKey) as? NFXCertificateInfo }
        set { objc_setAssociatedObject(self, &certificateInfoKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

#endif
