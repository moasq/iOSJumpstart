//
//  NetworkMonitor+Factory.swift
//  iOSJumpstart
//
//  Created by Claude on 1/1/26.
//

import Factory

public extension Container {
    var networkMonitor: Factory<NetworkMonitor> {
        self { NetworkMonitor() }.singleton
    }
}
