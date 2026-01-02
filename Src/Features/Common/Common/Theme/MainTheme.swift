//
//  MainTheme.swift
//  iOSJumpstart
//
//

import Foundation
import SwiftUI

public enum Theme {}

// MARK: - Colors
public extension Theme {
    enum Colors {
        // Brand
        public static let primary = Color(.primary)
        public static let secondary = Color(.secondary)

        // Backgrounds
        public static let background = Color(.background)
        public static let card = Color(.card)

        // Text
        public static let text = Color(.text)
        public static let textSecondary = Color(.textSecondary)

        // Structure
        public static let border = Color(.cardBorder)

        // Semantic
        public static let success = Color(.success)
        public static let warning = Color(.warning)
        public static let error = Color(.error)
    }
}

// MARK: - Typography
public extension Theme {
    enum Typography {
        // Titles
        public static let title1 = Font.poppins(.bold, size: 28)
        public static let title2 = Font.poppins(.semiBold, size: 24)
        public static let title3 = Font.poppins(.semiBold, size: 20)

        // Headline
        public static let headline = Font.poppins(.semiBold, size: 18)

        // Body
        public static let body = Font.poppins(.regular, size: 16)
        public static let bodyBold = Font.poppins(.semiBold, size: 16)

        // Callout
        public static let callout = Font.poppins(.regular, size: 14)
        public static let calloutMedium = Font.poppins(.medium, size: 14)

        // Caption
        public static let caption = Font.poppins(.regular, size: 12)
        public static let captionMedium = Font.poppins(.medium, size: 12)

        // Small
        public static let footnote = Font.poppins(.regular, size: 10)

        // Interactive
        public static let link = Font.poppins(.semiBold, size: 14)
    }
}
