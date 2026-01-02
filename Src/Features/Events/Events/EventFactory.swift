//
//  EventFactory.swift
//  ListingShared
//
//

import Foundation
import Factory

public extension Container {
    var eventViewModel: Factory<EventViewModel> {
        Factory(self) { EventViewModel() }
            .singleton
    }
}
