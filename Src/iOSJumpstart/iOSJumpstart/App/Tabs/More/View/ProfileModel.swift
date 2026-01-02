//
//  ProfileModel.swift
//  iOSJumpstart
//

import Foundation
import Repositories

struct ProfileModel {
    let fullName: String?
    let avatarURL: String?

    init(fullName: String? = nil, avatarURL: String? = nil) {
        self.fullName = fullName
        self.avatarURL = avatarURL
    }

    init(from entity: ProfileEntity) {
        self.fullName = entity.displayName
        self.avatarURL = entity.avatarURL?.absoluteString
    }
}
