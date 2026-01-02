//
//  ExpandableContentView.swift
//  DestinationDetails
//
//

import SwiftUI

public struct ExpandableContentView<Content: View>: View {
    let content: Content
    let collapsedHeight: CGFloat
    @State private var isExpanded: Bool = false
    @State private var contentHeight: CGFloat = 0 // Track the height of the content

    public init(collapsedHeight: CGFloat = 150, @ViewBuilder content: () -> Content) {
        self.collapsedHeight = collapsedHeight
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Content with height restriction
            ZStack(alignment: .bottom) {
                content
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                // Measure the height of the content
                                contentHeight = geometry.size.height
                            }
                    })
                    .frame(maxWidth: .infinity, maxHeight: isExpanded || contentHeight <= collapsedHeight ? nil : collapsedHeight, alignment: .top)
                    .clipped() // Ensure content doesn't overflow
                    .animation(.easeOut(duration: 0.2), value: isExpanded)

                // Gradient overlay when collapsed
                if !isExpanded && contentHeight > collapsedHeight {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Theme.Colors.background
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    .transition(.opacity) // Smooth fade-out when expanded
                }
            }

            // "Show More" button when collapsed
            if !isExpanded && contentHeight > collapsedHeight {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isExpanded = true
                    }
                } label: {
                    HStack {
                        Text("Show More")
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.primary)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
        }
    }
}
