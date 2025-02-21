//
//  NumberConversionHelper.swift
//  Coin Lore
//
//  Created by Ola Oldernes Hårstad on 21/02/2025.
//


import Foundation

struct NumberConversionHelper {
    /// Safely converts a String to a Double, returns 0 if conversion fails
    static func safeDouble(_ value: String) -> Double {
        return Double(value) ?? 0
    }
}
