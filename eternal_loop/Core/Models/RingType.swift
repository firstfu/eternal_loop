//
//  RingType.swift
//  eternal_loop
//

import Foundation

enum RingType: String, Codable, CaseIterable, Identifiable {
    case classicSolitaire
    case haloLuxury
    case minimalistBand
    case roseGoldHeart
    case eternityBand
    case vintageArtDeco

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classicSolitaire: return "經典單鑽"
        case .haloLuxury: return "奢華光環"
        case .minimalistBand: return "簡約素圈"
        case .roseGoldHeart: return "玫瑰金心形"
        case .eternityBand: return "永恆對戒"
        case .vintageArtDeco: return "復古藝術"
        }
    }

    var description: String {
        switch self {
        case .classicSolitaire: return "永恆經典的單顆鑽石設計"
        case .haloLuxury: return "璀璨奪目的光環環繞設計"
        case .minimalistBand: return "簡約純粹的素面戒指"
        case .roseGoldHeart: return "浪漫心形切割玫瑰金"
        case .eternityBand: return "環繞鑽石象徵永恆"
        case .vintageArtDeco: return "復古裝飾藝術風格"
        }
    }

    var modelFileName: String {
        switch self {
        case .classicSolitaire: return "ring_classic.usdz"
        case .haloLuxury: return "ring_halo.usdz"
        case .minimalistBand: return "ring_minimal.usdz"
        case .roseGoldHeart: return "ring_rose_heart.usdz"
        case .eternityBand: return "ring_eternity.usdz"
        case .vintageArtDeco: return "ring_vintage.usdz"
        }
    }

    var previewColor: String {
        switch self {
        case .classicSolitaire: return "#FFD700"  // Gold
        case .haloLuxury: return "#E5C100"        // Rich Gold
        case .minimalistBand: return "#E5E4E2"   // Platinum
        case .roseGoldHeart: return "#B76E79"    // Rose Gold
        case .eternityBand: return "#C0C0C0"     // Silver
        case .vintageArtDeco: return "#CFB53B"   // Antique Gold
        }
    }
}
