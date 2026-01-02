//
//  NetworkMonitor.swift
//  iOSJumpstart
//
//  Created by Claude on 1/1/26.
//

import Network
import SwiftUI
import Factory
import Events

public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
    case none
}

public protocol NetworkMonitorProtocol: AnyObject {
    var isConnected: Bool { get }
    var connectionType: ConnectionType { get }
}

@Observable
public final class NetworkMonitor: NetworkMonitorProtocol {
    @ObservationIgnored
    @LazyInjected(\.eventViewModel) private var eventViewModel: EventViewModel

    @ObservationIgnored
    private let monitor: NWPathMonitor

    @ObservationIgnored
    private let queue = DispatchQueue(label: "NetworkMonitor")

    public private(set) var isConnected: Bool = true
    public private(set) var connectionType: ConnectionType = .unknown

    public init() {
        self.monitor = NWPathMonitor()
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.handlePathUpdate(path)
            }
        }
        monitor.start(queue: queue)
    }

    private func handlePathUpdate(_ path: NWPath) {
        let wasConnected = isConnected

        // Update observable properties
        isConnected = path.status == .satisfied
        connectionType = determineConnectionType(path)

        // Emit event if connectivity changed
        if wasConnected != isConnected {
            eventViewModel.emit(.networkConnectivityChanged(isConnected: isConnected))
        }
    }

    private func determineConnectionType(_ path: NWPath) -> ConnectionType {
        guard path.status == .satisfied else { return .none }

        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        }
        return .unknown
    }

    deinit {
        monitor.cancel()
    }
}
