//
//  RingType.swift
//  eternal_loop
//

import Foundation

enum RingType: String, Codable, CaseIterable, Identifiable {
    case classicSolitaire
    case haloLuxury
    case minimalistBand

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classicSolitaire: return "經典單鑽"
        case .haloLuxury: return "奢華光環"
        case .minimalistBand: return "簡約素圈"
        }
    }

    var modelFileName: String {
        switch self {
        case .classicSolitaire: return "ring_classic.usdz"
        case .haloLuxury: return "ring_halo.usdz"
        case .minimalistBand: return "ring_minimal.usdz"
        }
    }
}
