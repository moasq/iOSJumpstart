//
//  ScaleButtonStyle.swift
//  Common
//
//


import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
//            .onChange(of: configuration.isPressed) { _, isPressed in
//                if isPressed {
//                    let generator = UIImpactFeedbackGenerator(style: .light)
//                    generator.impactOccurred()
//                }
//            }
    }
}

public struct OpacityButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
