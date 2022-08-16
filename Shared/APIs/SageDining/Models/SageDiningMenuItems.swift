//
//  SageDiningMenuItems.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation

// MARK: - SageDiningMenuItem
struct SageDiningMenuItem: Codable {
    let id: String
    let menuID: String?
    let meal: String
    let name: String
    let dot: String?
    let allergens: SageDiningMenuItemAllergens?
}

// MARK: - SageDiningMenuItemAllergens
struct SageDiningMenuItemAllergens: Codable {
    let allergenCodes: [String]
    let allergenNames: [String]
    let lmAllergenCodes: [String]
    let lmAllergenNames: [String]
    let lifestyleCodes: [String]
    let lifestyleNames: [String]
    let lmLifestyleCodes: [String]
    let lmLifestyleNames: [String]
}

typealias SageDiningMenuItems = [String: [SageDiningMenuItem]]

typealias SageDiningWeeklyMenuItems = [String: SageDiningMenuItems]
