//
//  FlekstoreAppsListView.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 30.09.2025.
//

import SwiftUI

// MARK: - View
// FlekstoreAppsListView.swift
import SwiftUI

struct FlekstoreAppsListView: View {
    @StateObject private var viewModel = FlekstoreAppsListViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            VStack {
                // Horizontal categories
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        CategoryButton(
                            title: "Updates",
                            isSelected: viewModel.selectedCategoryID == nil
                        ) { viewModel.selectCategory(nil) }

                        CategoryButton(
                            title: "Top",
                            isSelected: viewModel.selectedCategoryID == "downloads"
                        ) { viewModel.selectCategory("downloads") }

                        ForEach(viewModel.categories) { cat in
                            CategoryButton(
                                title: cat.name,
                                isSelected: viewModel.selectedCategoryID == cat.id
                            ) { viewModel.selectCategory(cat.id) }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 44)

                // Content
                Group {
                    if viewModel.apps.isEmpty && viewModel.isLoading {
                        ProgressView("Loading apps…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                            Button("Retry") { Task { await viewModel.fetchApps() } }
                        }
                    } else {
                        List {
                            ForEach(viewModel.apps) { app in
                                AppRow(app: app, selectedTab: $selectedTab)
                                    .buttonStyle(BorderlessButtonStyle())
                                    .onAppear {
                                        if app == viewModel.apps.last {
                                            Task { await viewModel.fetchApps() }
                                        }
                                    }
                            }

                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.inset)
                        .refreshable {
                            Task { await viewModel.resetAndFetchApps() }
                        }
                    }
                }
            }
            .navigationTitle("FlekSt0re")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search by app name"
            )
            .onChange(of: viewModel.searchQuery) { newValue in
                Task { await viewModel.resetAndFetchApps() }
            }
        }
        .task { await viewModel.fetchApps() }
    }
}


fileprivate struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.16))
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.blue.opacity(0.8) : Color.clear, lineWidth: 0)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Row
struct AppRow: View {
    let app: FSAppModel
    @Binding var selectedTab: Int
    @EnvironmentObject private var flekstoreSharedModel: FlekstoreSharedModel
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: app.app_icon)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.app_name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Version \(app.app_version)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(app.app_short_description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            VStack {
                Spacer()
                Button(action: {
                    selectedTab = 1
                    flekstoreSharedModel.appInstallURL = app.install_url
                }) {
                    Text("GET")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 6)
    }
}


