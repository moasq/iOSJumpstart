//
//  Loadable.swift
//  iOSJumpstart
//
//


import Foundation

public enum Loadable<T> {
    case notInitiated
    case loading(existing: T?)
    case success(T)
    case failure(Error)
    case empty
    
    public var value: T? {
        switch self {
        case .notInitiated, .empty:
            return nil
        case .loading(let existing):
            return existing
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    public var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
    
    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }
    
    public var isNotInitiated: Bool {
        switch self {
        case .notInitiated:
            return true
        default:
            return false
        }
    }
}
