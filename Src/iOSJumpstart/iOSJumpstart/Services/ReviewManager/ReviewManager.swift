import Foundation
import StoreKit
import SwiftUI
import Events
import Factory
import Common

class ReviewManager: ObservableObject {
    @LazyInjected(\.eventViewModel) private var eventViewModel: EventViewModel
    // MARK: - Constants & Dependencies
    private struct Keys {
        static let accumulatedUsage = "accumulatedUsageTime"
        static let hasReviewed = "userHasReviewed"
    }
    
    private let userDefaults: UserDefaults

    // Production threshold is 1200 seconds (20 minutes)
    // Debug threshold is 5 seconds for testing
    #if DEBUG
    private let reviewThreshold: TimeInterval = 5
    #else
    private let reviewThreshold: TimeInterval = 1200
    #endif
    
    // Session tracking
    private var sessionStartDate: Date?
    
    // MARK: - Initializer
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        subscribeToEvents()
    }

    private func subscribeToEvents() {
        eventViewModel.subscribe(for: self, to: [.appRating]) { [weak self] event in
            if event == .appRatingRequested {
                Task {
                   await self?.requestReview()
                }
            }
        }
    }

    deinit {
        eventViewModel.unsubscribe(self)
    }
    
    // MARK: - Computed Properties
    var userHasReviewed: Bool {
        get { userDefaults.bool(forKey: Keys.hasReviewed) }
        set { userDefaults.set(newValue, forKey: Keys.hasReviewed) }
    }
    
    private var accumulatedUsage: TimeInterval {
        get { userDefaults.double(forKey: Keys.accumulatedUsage) }
        set { userDefaults.set(newValue, forKey: Keys.accumulatedUsage) }
    }
    
    // MARK: - Session Management
    func startSession() {
        guard !userHasReviewed else { return }
        sessionStartDate = Date()
        log("Session started at \(sessionStartDate!)")
    }
    
    func endSession() -> Bool {
        guard !userHasReviewed, let start = sessionStartDate else { return false }
        let elapsed = Date().timeIntervalSince(start)
        log("Session elapsed: \(elapsed.rounded()) seconds")
        accumulatedUsage += elapsed
        log("Total accumulated usage: \(accumulatedUsage.rounded()) seconds")
        sessionStartDate = nil
        let shouldShowReview = accumulatedUsage >= reviewThreshold
        if shouldShowReview {
            log("Threshold reached (\(accumulatedUsage.rounded()) seconds)")
        } else {
            log("Threshold not reached (\(accumulatedUsage.rounded())/\(reviewThreshold) seconds)")
        }
        return shouldShowReview
    }
    
    // MARK: - Review Request
    @MainActor func requestReview() {
        guard !userHasReviewed else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            log("Requesting review...")
            AppStore.requestReview(in: windowScene)
            resetTracking()
        } else {
            log("No valid window scene found for review request")
        }
    }
    
    private func resetTracking() {
        accumulatedUsage = 0
        userHasReviewed = true
        log("Reset tracking; user marked as having reviewed")
    }
    
    // MARK: - Utilities
    private func log(_ message: String) {
        #if DEBUG
        print("📊 ReviewManager: \(message)")
        #endif
    }
} 
