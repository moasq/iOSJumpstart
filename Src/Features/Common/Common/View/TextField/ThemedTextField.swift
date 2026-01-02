//
//  ThemedTextField.swift
//  Common
//
//

import SwiftUI

public struct ThemedTextField: View {
    // MARK: - Properties
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    
    private let title: String
    private let icon: String?
    private let clearable: Bool
    private let contentType: UITextContentType?
    private let keyboardType: UIKeyboardType
    private let isSecure: Bool
    private let autocorrection: UITextAutocorrectionType
    private let autocapitalization: TextInputAutocapitalization
    
    // MARK: - Initialization
    public init(
        text: Binding<String>,
        isFocused: FocusState<Bool>? = nil,
        title: String,
        icon: String? = nil,
        clearable: Bool = true,
        contentType: UITextContentType? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        autocorrection: UITextAutocorrectionType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) {
        self._text = text
        self.title = title
        self.icon = icon
        self.clearable = clearable
        self.contentType = contentType
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.autocorrection = autocorrection
        self.autocapitalization = autocapitalization
        self._isFocused = isFocused ?? .init()
    }
    
    // MARK: - Body
    public var body: some View {
        HStack(spacing: 12) {
            // Optional Icon
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? Theme.Colors.primary : Theme.Colors.textSecondary)
                    .frame(width: 20)
            }
            
            // Text Field
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .autocorrectionDisabled(autocorrection == .no)
            .textInputAutocapitalization(autocapitalization)
            .focused($isFocused)
            .font(Theme.Typography.callout)
            
            // Clear Button
            if clearable && !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.Colors.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Theme.Colors.primary : Theme.Colors.border, lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - Previews
#Preview("Default") {
    VStack(spacing: 16) {
        ThemedTextField(
            text: .constant(""),
            title: "Search destinations...",
            icon: "magnifyingglass"
        )
        
        ThemedTextField(
            text: .constant("Hello"),
            title: "Search destinations...",
            icon: "magnifyingglass"
        )
        
        ThemedTextField(
            text: .constant(""),
            title: "Enter your name",
            contentType: .name
        )
        
        ThemedTextField(
            text: .constant(""),
            title: "Enter password",
            icon: "lock",
            contentType: .password,
            isSecure: true
        )
    }
    .padding()
}
