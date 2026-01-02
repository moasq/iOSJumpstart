//
//  HTTPNetworking.swift
//  Common
//
//


public struct HTTPNetworking: NetworkingProtocol {
    private let baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    // Helper to apply token to headers
    private func applyAuthToken(to headers: [String: String]?, token: String?) -> [String: String]? {
        guard let token = token else {
            return headers
        }
        
        var updatedHeaders = headers ?? [:]
        updatedHeaders["Authorization"] = "Bearer \(token)"
        return updatedHeaders
    }
    
    public func post<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Apply token and custom headers
        let finalHeaders = applyAuthToken(to: headers, token: token)
        finalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let encoder = JSONEncoder()
            let bodyData = try encoder.encode(body)
            request.httpBody = bodyData
            
            // Log request
            NetworkLogger.logRequest(request, body: bodyData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            NetworkLogger.logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(U.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw error
        } catch {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw NetworkError.unknown(error)
        }
    }
    
    // No-response variant (void return)
    public func post<T: Encodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Apply token and custom headers
        let finalHeaders = applyAuthToken(to: headers, token: token)
        finalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let encoder = JSONEncoder()
            let bodyData = try encoder.encode(body)
            request.httpBody = bodyData
            
            // Log request
            NetworkLogger.logRequest(request, body: bodyData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            NetworkLogger.logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            // Success with no returned data needed
            return
            
        } catch let error as NetworkError {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw error
        } catch {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw NetworkError.unknown(error)
        }
    }
    
    public func get<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:],
        headers: [String: String]?,
        token: String?
    ) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)
        
        if !queryParams.isEmpty {
            components?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Apply token and custom headers
        let finalHeaders = applyAuthToken(to: headers, token: token)
        finalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            // Log request
            NetworkLogger.logRequest(request)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            NetworkLogger.logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw error
        } catch {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw NetworkError.unknown(error)
        }
    }
    
    public func delete<T: Decodable>(
        endpoint: String,
        queryParams: [String: String] = [:],
        headers: [String: String]?,
        token: String?
    ) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)
        
        if !queryParams.isEmpty {
            components?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Apply token and custom headers
        let finalHeaders = applyAuthToken(to: headers, token: token)
        finalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            // Log request
            NetworkLogger.logRequest(request)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            NetworkLogger.logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw error
        } catch {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw NetworkError.unknown(error)
        }
    }
    
    // No-response variant (void return)
    public func delete(
        endpoint: String,
        queryParams: [String: String] = [:],
        headers: [String: String]?,
        token: String?
    ) async throws {
        var components = URLComponents(string: baseURL + endpoint)
        
        if !queryParams.isEmpty {
            components?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Apply token and custom headers
        let finalHeaders = applyAuthToken(to: headers, token: token)
        finalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            // Log request
            NetworkLogger.logRequest(request)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            NetworkLogger.logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            // Success with no returned data needed
            return
            
        } catch let error as NetworkError {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw error
        } catch {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw NetworkError.unknown(error)
        }
    }
}


public extension HTTPNetworking {
    func patch<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Apply token and custom headers
        let finalHeaders = applyAuthToken(to: headers, token: token)
        finalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let encoder = JSONEncoder()
            let bodyData = try encoder.encode(body)
            request.httpBody = bodyData
            
            // Log request
            NetworkLogger.logRequest(request, body: bodyData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            NetworkLogger.logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(U.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw error
        } catch {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw NetworkError.unknown(error)
        }
    }
    
    // No-response variant (void return)
    func patch<T: Encodable>(
        endpoint: String,
        body: T,
        headers: [String: String]?,
        token: String?
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Apply token and custom headers
        let finalHeaders = applyAuthToken(to: headers, token: token)
        finalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let encoder = JSONEncoder()
            let bodyData = try encoder.encode(body)
            request.httpBody = bodyData
            
            // Log request
            NetworkLogger.logRequest(request, body: bodyData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            NetworkLogger.logResponse(data: data, response: response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            // Success with no returned data needed
            return
            
        } catch let error as NetworkError {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw error
        } catch {
            NetworkLogger.logError(error, url: url.absoluteString)
            throw NetworkError.unknown(error)
        }
    }
}
