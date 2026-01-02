//
//  UserProfileSection.swift
//  iOSJumpstart
//
//

import SwiftUI
import Common
import NukeUI

struct UserProfileSection: View {
    let userInfo: UserSummaryInfo
    var isSubscribed: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Profile image with proper fallbacks
            profileImageView

            // User details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(displayName)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text)

                    // Subscription badge
                    if isSubscribed {
                        Text("PRO")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }

                Text(userInfo.email)
                    .font(Theme.Typography.caption)
                    .lineLimit(1)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Spacer()

            if userInfo.needsData {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.warning)
                    .padding(.trailing, 8)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding()
        .background(Theme.Colors.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
        .shadowSmall()
    }
    
    // MARK: - Computed Properties
    
    private var displayName: String {
        userInfo.name ?? "User"
    }
    
    private var profileImageView: some View {
        ZStack {
            if let photoURL = userInfo.profilePhoto {
                LazyImage(url: photoURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        placeholderView
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.primary.opacity(0.1))
                .frame(width: 56, height: 56)
            
            if let name = userInfo.name, !name.isEmpty {
                // Use first letter of name
                Text(String(name.prefix(1).uppercased()))
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.primary)
            } else {
                // Default person icon
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.primary)
            }
        }
    }
}

struct UserSummaryInfo: Hashable {
    var profilePhoto: URL?
    var email: String
    var name: String?

    var needsData: Bool {
        name == nil || name?.isEmpty == true
    }
}

extension ProfileModel {
    func toUserSummaryInfo(email: String) -> UserSummaryInfo {
        UserSummaryInfo(
            profilePhoto: avatarURL.flatMap { URL(string: $0) },
            email: email,
            name: fullName
        )
    }
}

// Preview
struct UserProfileSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            UserProfileSection(
                userInfo: UserSummaryInfo(
                    profilePhoto: URL(string: "https://example.com/avatar.jpg"),
                    email: "user@example.com",
                    name: "John Traveler"
                )
            )

            UserProfileSection(
                userInfo: UserSummaryInfo(
                    profilePhoto: nil,
                    email: "newuser@example.com",
                    name: nil
                )
            )

            UserProfileSection(
                userInfo: UserSummaryInfo(
                    profilePhoto: nil,
                    email: "sarah@example.com",
                    name: "Sarah"
                )
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
