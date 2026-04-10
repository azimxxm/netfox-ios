//
//  NFXCertificateView.swift
//  netfox
//
//  D6: Displays TLS certificate details for a captured request.
//

#if os(iOS)

import SwiftUI

struct NFXCertificateView: View {
    let certInfo: NFXCertificateInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TLS Certificate")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 8) {
                certRow(label: "Subject", value: certInfo.subject)
                certRow(label: "Issuer", value: certInfo.issuer)

                if let expiry = certInfo.expiryDate {
                    certRow(label: "Expires", value: formattedDate(expiry))
                }

                certRow(label: "Key Algorithm", value: certInfo.publicKeyAlgorithm)

                HStack {
                    Text("Self-Signed")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: certInfo.isSelfSigned ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                        .foregroundColor(certInfo.isSelfSigned ? Color(UIColor.NFXOrangeColor()) : Color(UIColor.NFXGreenColor()))
                    Text(certInfo.isSelfSigned ? "Yes" : "No")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }

    // MARK: - Helpers

    private func certRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#endif
