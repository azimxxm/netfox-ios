//
//  NFXRequestListView.swift
//  netfox
//
//  SwiftUI replacement for NFXListController_iOS.
//  Main request list with search, filtering, pinning (B9), and diff comparison (B6).
//

#if os(iOS)

import SwiftUI

struct NFXRequestListView: View {
    @ObservedObject private var manager = NFXHTTPModelManager.shared
    @State private var searchText = ""
    @State private var showClearConfirmation = false

    // B6: Diff comparison
    @State private var diffSourceModel: NFXHTTPModel?
    @State private var showDiffPicker = false

    var body: some View {
        let filtered = filteredModels
        let pinned = filtered.filter { manager.isPinned($0) }
        let unpinned = filtered.filter { !manager.isPinned($0) }

        List {
            // B9: Pinned section
            if !pinned.isEmpty {
                Section(header: Text("Pinned")) {
                    ForEach(pinned, id: \.randomHash) { model in
                        NavigationLink {
                            NFXRequestDetailView(model: model)
                        } label: {
                            NFXRequestRow(
                                model: model,
                                isPinned: true,
                                isNew: isNew(model)
                            )
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                manager.togglePin(model)
                            } label: {
                                Label("Unpin", systemImage: "pin.slash")
                            }
                            .tint(Color(UIColor.NFXOrangeColor()))
                        }
                        .swipeActions(edge: .trailing) {
                            // B6: Compare
                            Button {
                                diffSourceModel = model
                                showDiffPicker = true
                            } label: {
                                Label("Compare", systemImage: "arrow.left.arrow.right")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }

            // All requests
            Section(header: pinned.isEmpty ? nil : Text("All Requests")) {
                ForEach(unpinned, id: \.randomHash) { model in
                    NavigationLink {
                        NFXRequestDetailView(model: model)
                    } label: {
                        NFXRequestRow(
                            model: model,
                            isPinned: false,
                            isNew: isNew(model)
                        )
                    }
                    .swipeActions(edge: .leading) {
                        // B9: Pin
                        Button {
                            manager.togglePin(model)
                        } label: {
                            Label("Pin", systemImage: "pin")
                        }
                        .tint(Color(UIColor.NFXOrangeColor()))
                    }
                    .swipeActions(edge: .trailing) {
                        // B6: Compare
                        Button {
                            diffSourceModel = model
                            showDiffPicker = true
                        } label: {
                            Label("Compare", systemImage: "arrow.left.arrow.right")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search URL, method, type...")
        .navigationTitle("Requests")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    NFX.sharedInstance().hide()
                } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink {
                    NFXSettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }

                Button {
                    showClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("Clear data?", isPresented: $showClearConfirmation) {
            Button("Clear All", role: .destructive) {
                NFX.sharedInstance().clearOldData()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showDiffPicker) {
            if let sourceModel = diffSourceModel {
                NFXDiffPickerSheet(sourceModel: sourceModel)
            }
        }
    }

    // MARK: - Filtering

    private var filteredModels: [NFXHTTPModel] {
        let models = manager.filteredModels
        guard !searchText.isEmpty else { return models }

        return models.filter { model in
            model.requestURL?.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            || model.requestMethod?.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            || model.responseType?.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    private func isNew(_ model: NFXHTTPModel) -> Bool {
        guard let responseDate = model.responseDate else { return false }
        return responseDate > NFX.sharedInstance().getLastVisitDate()
    }
}

#endif
