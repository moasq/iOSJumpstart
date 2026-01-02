//
//  PoppinsWeight.swift
//  Common
//
//

import SwiftUI

public enum PoppinsWeight {
    case thin
    case extraLight
    case light
    case regular
    case medium
    case semiBold
    case bold
    case extraBold
    case black
    
    var value: String {
        switch self {
        case .thin: return "Poppins-Thin"
        case .extraLight: return "Poppins-ExtraLight"
        case .light: return "Poppins-Light"
        case .regular: return "Poppins-Regular"
        case .medium: return "Poppins-Medium"
        case .semiBold: return "Poppins-SemiBold"
        case .bold: return "Poppins-Bold"
        case .extraBold: return "Poppins-ExtraBold"
        case .black: return "Poppins-Black"
        }
    }
}

public extension Font {
    static func poppins(_ weight: PoppinsWeight, size: CGFloat = 16) -> Font {
        return .custom(weight.value, size: size)
    }
}
