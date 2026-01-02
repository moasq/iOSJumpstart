//
//  NetworkLogger.swift
//  iOSJumpstart
//
//


import Foundation
import OSLog

// MARK: - Network Logger
private extension Logger {
    static let network = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.mosal", category: "Network")
}

struct NetworkLogger {
    static func logRequest(_ request: URLRequest, body: Data? = nil) {
        let method = request.httpMethod ?? "Unknown"
        let url = request.url?.absoluteString ?? "Unknown"
        
        // Create log message components
        var components = ["⬆️ \(method) \(url)"]
        
        // Log Headers
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            components.append("Headers: \(headers)")
        }
        
        // Log Body if present
        if let body = body,
           let jsonString = String(data: body, encoding: .utf8) {
            components.append("Body: \(jsonString)")
        }
        
        // Join all components and log
        let message = components.joined(separator: "\n")
        Logger.network.debug("\(message)")
    }
    
    static func logResponse(data: Data, response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        
        let url = response.url?.absoluteString ?? "Unknown"
        let statusCode = httpResponse.statusCode
        
        // Create log message components
        var components = ["⬇️ \(url)"]
        components.append("Status Code: \(statusCode)")
        
        // Log Headers
        if let headers = httpResponse.allHeaderFields as? [String: Any] {
            components.append("Headers: \(headers)")
        }
        
        // Log Response Body
        if let jsonString = String(data: data, encoding: .utf8) {
            components.append("Response: \(jsonString)")
        }
        
        // Join all components and log
        let message = components.joined(separator: "\n")
        
        // Log with appropriate level based on status code
        if (200...299).contains(statusCode) {
            Logger.network.debug("\(message)")
        } else {
            Logger.network.error("\(message)")
        }
    }
    
    static func logError(_ error: Error, url: String) {
        let message = """
        ❌ Network Error
        URL: \(url)
        Error: \(error.localizedDescription)
        """
        Logger.network.error("\(message)")
    }
}