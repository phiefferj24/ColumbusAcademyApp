//
//  SageDiningVenueInformation.swift
//  CA
//
//  Created by Jim Phieffer on 8/11/22.
//

import Foundation

// MARK: - SageDiningVenueInformation
struct SageDiningVenueInformation: Codable {
    let venueName: String
    let menus: [SageDiningVenueInformationMenu]
    let recipeDotColorMap: SageDiningVenueInformationRecipeDotColorMap?
}

// MARK: - SageDiningVenueInformationMenu
struct SageDiningVenueInformationMenu: Codable {
    let id: String
    let name: String
    let meals: [String]
}

// MARK: - SageDiningVenueInformationRecipeDotColorMap
struct SageDiningVenueInformationRecipeDotColorMap: Codable {
    let notServing: SageDiningVenueInformationColor?
    let red: SageDiningVenueInformationColor?
    let yellow: SageDiningVenueInformationColor?
    let green: SageDiningVenueInformationColor?
    let greenYellow: SageDiningVenueInformationColor?
    let yellowRed: SageDiningVenueInformationColor?
    let greenYellowRed: SageDiningVenueInformationColor?
    let greenRed: SageDiningVenueInformationColor?
}

// MARK: - SageDiningVenueInformationColor
struct SageDiningVenueInformationColor: Codable {
    let imagePath: String?
    let colorCode: String?
}
