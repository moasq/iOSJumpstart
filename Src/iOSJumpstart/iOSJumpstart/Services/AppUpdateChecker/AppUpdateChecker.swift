//
//  AppUpdateChecker.swift
//  iOSJumpstart
//
//  Created by Claude on 1/1/26.
//

import Foundation
import Common

public struct AppUpdateInfo {
    public let currentVersion: String
    public let latestVersion: String
    public let updateURL: URL
    public let isUpdateAvailable: Bool
    public let isForceUpdateRequired: Bool
}

public protocol AppUpdateCheckerProtocol {
    func checkForUpdate() async throws -> AppUpdateInfo?
}

public final class AppUpdateChecker: AppUpdateCheckerProtocol {
    private let bundleID: String
    private let currentVersion: String
    private let appStoreID: String

    public init(
        bundleID: String = AppConfiguration.App.bundleID,
        currentVersion: String = AppConfiguration.App.version,
        appStoreID: String = AppConfiguration.App.appStoreID
    ) {
        self.bundleID = bundleID
        self.currentVersion = currentVersion
        self.appStoreID = appStoreID
    }

    public func checkForUpdate() async throws -> AppUpdateInfo? {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"
        guard let url = URL(string: urlString) else {
            log("Invalid iTunes lookup URL")
            return nil
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            log("Invalid response from iTunes API")
            return nil
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let appInfo = results.first,
              let latestVersion = appInfo["version"] as? String else {
            log("Could not parse iTunes response")
            return nil
        }

        let updateURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
        let isUpdateAvailable = isVersionNewer(latestVersion, than: currentVersion)
        let isForceUpdateRequired = isMajorVersionNewer(latestVersion, than: currentVersion)

        log("Current: \(currentVersion), Latest: \(latestVersion), Update available: \(isUpdateAvailable), Force: \(isForceUpdateRequired)")

        return AppUpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            updateURL: updateURL,
            isUpdateAvailable: isUpdateAvailable,
            isForceUpdateRequired: isForceUpdateRequired
        )
    }

    // MARK: - Version Comparison

    private func isVersionNewer(_ new: String, than current: String) -> Bool {
        let newComponents = new.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(newComponents.count, currentComponents.count)

        for i in 0..<maxCount {
            let newPart = i < newComponents.count ? newComponents[i] : 0
            let currentPart = i < currentComponents.count ? currentComponents[i] : 0

            if newPart > currentPart {
                return true
            } else if newPart < currentPart {
                return false
            }
        }
        return false
    }

    private func isMajorVersionNewer(_ new: String, than current: String) -> Bool {
        let newMajor = new.split(separator: ".").first.flatMap { Int($0) } ?? 0
        let currentMajor = current.split(separator: ".").first.flatMap { Int($0) } ?? 0
        return newMajor > currentMajor
    }

    private func log(_ message: String) {
        #if DEBUG
        print("🔄 AppUpdateChecker: \(message)")
        #endif
    }
}
