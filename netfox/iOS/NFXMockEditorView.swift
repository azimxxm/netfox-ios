//
//  NFXMockEditorView.swift
//  netfox
//
//  C2: Mock response editor. Allows creating/editing mock rules for URL patterns.
//

#if os(iOS)

import SwiftUI

struct NFXMockEditorView: View {
    let model: NFXHTTPModel
    @ObservedObject private var manager = NFXHTTPModelManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var urlPattern: String
    @State private var statusCode: Int
    @State private var responseBody: String
    @State private var headersText: String
    @State private var isEnabled: Bool

    private let statusCodes = [200, 201, 400, 401, 403, 404, 500, 502, 503]

    init(model: NFXHTTPModel) {
        self.model = model

        // Derive a default URL pattern from the request URL (path without query)
        let defaultPattern: String
        if let urlString = model.requestURL,
           let components = URLComponents(string: urlString) {
            var base = components.host ?? ""
            base += components.path
            defaultPattern = base
        } else {
            defaultPattern = model.requestURL ?? ""
        }

        // Check if an existing rule matches
        let existingRule = NFXHTTPModelManager.shared.mockRules[defaultPattern]

        _urlPattern = State(initialValue: defaultPattern)
        _statusCode = State(initialValue: existingRule?.statusCode ?? 200)
        _responseBody = State(initialValue: existingRule?.responseBody ?? model.getResponseBody())
        _headersText = State(initialValue: Self.formatHeaders(existingRule?.responseHeaders ?? ["Content-Type": "application/json"]))
        _isEnabled = State(initialValue: existingRule?.isEnabled ?? true)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("URL Pattern")) {
                    TextField("URL pattern to match", text: $urlPattern)
                        .font(.system(size: 13, design: .monospaced))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section(header: Text("Status Code")) {
                    Picker("Status Code", selection: $statusCode) {
                        ForEach(statusCodes, id: \.self) { code in
                            Text("\(code)").tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color(UIColor.NFXOrangeColor()))
                }

                Section(header: Text("Response Body")) {
                    TextEditor(text: $responseBody)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(minHeight: 150)
                }

                Section(header: Text("Response Headers")) {
                    TextEditor(text: $headersText)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(minHeight: 80)

                    Text("One header per line: Key: Value")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Section {
                    Toggle("Enable Mock", isOn: $isEnabled)
                        .tint(Color(UIColor.NFXOrangeColor()))
                }

                Section {
                    Button {
                        saveMockRule()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save Mock Rule")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(UIColor.NFXOrangeColor()))
                            Spacer()
                        }
                    }

                    // Show delete button if a rule already exists
                    if manager.mockRules[urlPattern] != nil {
                        Button {
                            manager.mockRules.removeValue(forKey: urlPattern)
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Mock Rule")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(UIColor.NFXRedColor()))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mock Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Helpers

    private func saveMockRule() {
        let headers = Self.parseHeaders(headersText)
        let rule = NFXMockRule(
            statusCode: statusCode,
            responseBody: responseBody,
            responseHeaders: headers,
            isEnabled: isEnabled
        )
        manager.mockRules[urlPattern] = rule
    }

    private static func formatHeaders(_ headers: [String: String]) -> String {
        return headers.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }

    private static func parseHeaders(_ text: String) -> [String: String] {
        var headers = [String: String]()
        for line in text.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            let parts = trimmed.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                headers[key] = value
            }
        }
        if headers.isEmpty {
            headers["Content-Type"] = "application/json"
        }
        return headers
    }
}

#endif
