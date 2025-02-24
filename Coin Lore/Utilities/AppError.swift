//
//  AppError.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 24/02/2025.
//


import Foundation


enum AppError: LocalizedError {
    case networkError
    case dataProcessingError
    case unknownError
    case customError(message: String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error. Please check your connection."
        case .dataProcessingError:
            return "Data processing error. Please try again."
        case .unknownError:
            return "An unknown error occurred."
        case .customError(let message):
            return message
        }
    }
}
