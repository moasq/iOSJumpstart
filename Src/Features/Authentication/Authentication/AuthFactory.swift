//
//  AuthFactory.swift
//  Authentication
//
//


import Foundation
import Factory
import Common


extension Container {
    // Register repository and data sources
    var authRepository: Factory<AuthRepository> {
        self { AuthRepositoryImpl() }
    }

    var authRemoteDataSource: Factory<AuthRemoteDataSource> {
        self { AuthRemoteDataSourceImpl() }
    }

    var authLocalDataSource: Factory<AuthLocalDataSource> {
        self { AuthLocalDataSourceImpl() }
    }

    var appleAuthProvider: Factory<AppleAuthProvider> {
        self { AppleAuthProviderImpl() }
    }

    var googleAuthProvider: Factory<GoogleAuthProvider> {
        self { GoogleAuthProviderImpl(clientID: EnvironmentVars.GOOGLE_CLIENT_ID) }
    }
}

public extension Container {
    var authStatusRepository: Factory<AuthStatusRepository> {
        self { AuthStatusRepositoryImpl(authRepository: self.authRepository()) }
    }
}
