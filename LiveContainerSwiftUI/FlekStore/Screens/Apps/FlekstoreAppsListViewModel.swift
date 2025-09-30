//
//  FlekstoreAppsListViewModel.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 30.09.2025.
//

import SwiftUI

// MARK: - ViewModel
@MainActor
class FlekstoreAppsListViewModel: ObservableObject {
    @Published var apps: [FSAppModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = "" {
        didSet {
            Task {
                await resetAndFetchApps()
            }
        }
    }
    
    private let baseURLString = "https://nestapitest.flekstore.com/app/with-link?filter=updates"
    private var currentPage = 0
    private var canLoadMore = true
    
    func resetAndFetchApps() async {
        // Reset pagination when search changes
        currentPage = 0
        canLoadMore = true
        apps = []
        await fetchApps()
    }
    
    func fetchApps() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        errorMessage = nil
        
        // Build URL with search query and page
        let searchPart = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "\(baseURLString)&page=\(currentPage)&search=\(searchPart)"
        
        guard let url = URL(string: urlStr) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([FSAppModel].self, from: data)
            
            if decoded.isEmpty {
                canLoadMore = false
            } else {
                apps.append(contentsOf: decoded)
                currentPage += 1
            }
        } catch {
            errorMessage = "Failed to load apps: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

