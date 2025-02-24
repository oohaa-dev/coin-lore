//
//  DetailsViewModel.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 23/02/2025.
//


import Foundation

class DetailsViewModel: ObservableObject {
    @Published var cryptoDetails: CryptoDetailsModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository = CoinLoreRepository()

    func fetchCryptoDetails(for id: String) {
        isLoading = true
        errorMessage = nil
        
        repository.getCryptoDetails(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let details):
                    self?.cryptoDetails = details
                case .failure:
                    self?.errorMessage = "Could not retrieve details. Please check your connection."
                }
            }
        }
    }
}
