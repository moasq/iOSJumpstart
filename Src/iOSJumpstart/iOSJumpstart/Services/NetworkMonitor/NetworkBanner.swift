//
//  NetworkBanner.swift
//  iOSJumpstart
//
//  Created by Claude on 1/1/26.
//

import SwiftUI
import Common

struct NetworkBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 14))
            Text("No internet connection")
                .font(Theme.Typography.caption)
        }
        .foregroundColor(.white)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.error)
    }
}

#Preview {
    NetworkBanner()
}
