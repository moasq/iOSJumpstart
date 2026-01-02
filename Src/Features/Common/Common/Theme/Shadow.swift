//
//  Shadow.swift
//  iOSJumpstart
//
//

import Foundation
import SwiftUI

// MARK: - Shadow Values
public extension Theme {
    enum Shadows {
        static let smallShadow = Shadow(
            color: Color.black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let mediumShadow = Shadow(
            color: Color.black.opacity(0.08),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let largeShadow = Shadow(
            color: Color.black.opacity(0.12),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Shadow Modifier
struct ShadowModifier: ViewModifier {
    let shadow: Theme.Shadow
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

// MARK: - View Extensions
extension View {
    public func shadowSmall() -> some View {
        modifier(ShadowModifier(shadow: Theme.Shadows.smallShadow))
    }
    
    public func shadowMedium() -> some View {
        modifier(ShadowModifier(shadow: Theme.Shadows.mediumShadow))
    }
    
    public func shadowLarge() -> some View {
        modifier(ShadowModifier(shadow: Theme.Shadows.largeShadow))
    }
}
