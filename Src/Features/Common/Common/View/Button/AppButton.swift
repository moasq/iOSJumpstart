//
//  AppButton.swift
//  Common
//
//

import SwiftUI

public enum AppButton {
    // MARK: - Button Colors
    public enum ColorStyle {
        case primary    // Theme.Colors.primary
        case text      // Theme.Colors.text
        case secondaryText // Theme.Colors.secondaryText
        case success   // Theme.Colors.success
        case error     // Theme.Colors.error
        case warning   // Theme.Colors.warning
        case premium   // Special premium color (gold/premium)
        
        public var color: Color {
            switch self {
            case .primary: return Theme.Colors.primary
            case .text: return Theme.Colors.text
            case .secondaryText: return Theme.Colors.textSecondary
            case .success: return Theme.Colors.success
            case .error: return Theme.Colors.error
            case .warning: return Theme.Colors.warning
            case .premium: return Color(hex: "#FFA500") // Premium gold color
            }
        }
        
        public var disabledColor: Color {
            switch self {
            case .primary: return Theme.Colors.primary.opacity(0.3)
            case .text: return Theme.Colors.text.opacity(0.3)
            case .secondaryText: return Theme.Colors.textSecondary.opacity(0.3)
            case .success: return Theme.Colors.success.opacity(0.3)
            case .error: return Theme.Colors.error.opacity(0.3)
            case .warning: return Theme.Colors.warning.opacity(0.3)
            case .premium: return Color(hex: "#FFA500").opacity(0.3)
            }
        }
    }
    
    // MARK: - Button Types
    public enum Style {
        case filled      // Solid background with text
        case outlined    // Bordered with transparent background
        case text       // Just text, no background or border
        case tonal      // Semi-transparent background
        case icon       // Circle or square with icon
    }
    
    // MARK: - Button Sizes
    public enum Size {
        case small
        case medium
        case large
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 24
            case .large: return 32
            }
        }
        
        var font: Font {
            switch self {
            case .small: return Theme.Typography.calloutMedium
            case .medium: return Theme.Typography.bodyBold
            case .large: return Theme.Typography.bodyBold
            }
        }
    }
    
    // MARK: - Icon Position
    public enum IconPosition {
        case leading
        case trailing
    }
}

// MARK: - Button Views
public extension AppButton {
    struct ButtonView: View {
        private let title: String
        private let style: Style
        private let colorStyle: ColorStyle
        private let size: Size
        private let fullWidth: Bool
        private let icon: String?
        private let iconPosition: IconPosition
        private let action: () -> Void
        @Environment(\.isEnabled) private var isEnabled
        
        public init(
            title: String,
            style: Style = .filled,
            colorStyle: ColorStyle = .primary,
            size: Size = .medium,
            fullWidth: Bool = false,
            icon: String? = nil,
            iconPosition: IconPosition = .leading,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.style = style
            self.colorStyle = colorStyle
            self.size = size
            self.fullWidth = fullWidth
            self.icon = icon
            self.iconPosition = iconPosition
            self.action = action
        }
        
        public var body: some View {
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            }) {
                HStack(spacing: 8) {
                    if let icon, iconPosition == .leading {
                        Image(systemName: icon)
                    }
                    
                    Text(title)
                        .font(size.font)
                    
                    if let icon, iconPosition == .trailing {
                        Image(systemName: icon)
                    }
                }
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.vertical, size.verticalPadding)
                .padding(.horizontal, size.horizontalPadding)
                .contentShape(Rectangle())
            }
            .buttonStyle(CustomButtonStyle(style: style, colorStyle: colorStyle, isEnabled: isEnabled))
        }
    }
    
    struct Button<Content: View>: View {
        private let action: () -> Void
        private let label: () -> Content
        
        public init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
            self.action = action
            self.label = label
        }
        
        public var body: some View {
            SwiftUI.Button {
                // Trigger haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                // Perform the action
                action()
            } label: {
                label()
                    .contentShape(Rectangle())
            }
        }
    }
}

// MARK: - Custom Button Style
private struct CustomButtonStyle: ButtonStyle {
    let style: AppButton.Style
    let colorStyle: AppButton.ColorStyle
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(ButtonModifier(style: style, colorStyle: colorStyle, isPressed: configuration.isPressed, isEnabled: isEnabled))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Button Modifier
private struct ButtonModifier: ViewModifier {
    let style: AppButton.Style
    let colorStyle: AppButton.ColorStyle
    let isPressed: Bool
    let isEnabled: Bool
    
    var currentColor: Color {
        isEnabled ? colorStyle.color : colorStyle.disabledColor
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .filled:
            content
                .foregroundColor(.white)
                .background(currentColor)
                .cornerRadius(8)
                .opacity(isPressed ? 0.8 : 1)
                
        case .outlined:
            content
                .foregroundColor(currentColor)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(currentColor, lineWidth: 1.5)
                )
                .opacity(isPressed ? 0.8 : 1)
                
        case .text:
            content
                .foregroundColor(currentColor)
                .opacity(isPressed ? 0.8 : 1)
                
        case .tonal:
            content
                .foregroundColor(currentColor)
                .background(currentColor.opacity(0.1))
                .cornerRadius(8)
                .opacity(isPressed ? 0.8 : 1)
                
        case .icon:
            content
                .foregroundColor(currentColor)
                .padding(12)
                .background(Circle().fill(currentColor.opacity(0.1)))
                .opacity(isPressed ? 0.8 : 1)
        }
    }
}

// MARK: - Preview
#Preview("Button Styles") {
    ScrollView {
        VStack(spacing: 24) {
            Group {
                AppButton.ButtonView(
                    title: "Success Filled",
                    style: .filled,
                    colorStyle: .success,
                    fullWidth: true
                ) {}
                .disabled(true)
                
                AppButton.ButtonView(
                    title: "Error Filled",
                    style: .filled,
                    colorStyle: .error,
                    fullWidth: true
                ) {}
            }
            
            Group {
                // Outlined Buttons
                AppButton.ButtonView(
                    title: "Primary Outlined",
                    style: .outlined,
                    colorStyle: .primary,
                    icon: "star.fill",
                    iconPosition: .leading
                ) {}
                .disabled(true)
                
                AppButton.ButtonView(
                    title: "Text Color Outlined",
                    style: .outlined,
                    colorStyle: .text,
                    icon: "info.circle",
                    iconPosition: .trailing
                ) {}
            }
            
            Group {
                // Text Buttons
                HStack {
                    AppButton.ButtonView(
                        title: "Cancel",
                        style: .text,
                        colorStyle: .error,
                        size: .small
                    ) {}
                    .disabled(true)
                    
                    AppButton.ButtonView(
                        title: "Confirm",
                        style: .text,
                        colorStyle: .success,
                        size: .small
                    ) {}
                }
            }
            
            Group {
                // Tonal Buttons
                HStack {
                    AppButton.ButtonView(
                        title: "Previous",
                        style: .tonal,
                        colorStyle: .primary,
                        icon: "arrow.left",
                        iconPosition: .leading
                    ) {}
                    .disabled(true)
                    
                    AppButton.ButtonView(
                        title: "Next",
                        style: .tonal,
                        colorStyle: .primary,
                        icon: "arrow.right",
                        iconPosition: .trailing
                    ) {}
                }
            }
            
            // Icon Buttons
            HStack {
                AppButton.ButtonView(
                    title: "",
                    style: .icon,
                    colorStyle: .primary,
                    icon: "plus"
                ) {}
                .disabled(true)
                
                AppButton.ButtonView(
                    title: "",
                    style: .icon,
                    colorStyle: .success,
                    icon: "checkmark"
                ) {}
                
                AppButton.ButtonView(
                    title: "",
                    style: .icon,
                    colorStyle: .error,
                    icon: "xmark"
                ) {}
            }
            
            // Premium Button
            AppButton.ButtonView(
                title: "Unlock Premium",
                style: .filled,
                colorStyle: .premium,
                icon: "sparkles",
                iconPosition: .leading
            ) {}
        }
        .padding()
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
