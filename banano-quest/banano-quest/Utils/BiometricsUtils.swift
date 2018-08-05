//
//  BiometricsUtil.swift
//  banano-quest
//
//  Created by Luis De Leon on 8/5/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import BiometricAuthentication
import Pocket

public typealias BiometricsSetupSuccessHandler = () -> Void
public typealias BiometricsErrorHandler = (Error) -> Void
public typealias BiometricsAuthSuccessHandler = (Wallet) -> Void

public enum BiometricsUtilsError: Error {
    case biometricsUnavailable
    case playerNotFound
    case cancelledByUser
    case unknownError
    case passcodeAuthError
    case setupError
    case credentialsRetrievalError
}

public struct BiometricsUtils {
    
    public static let biometricsAvailable = BioMetricAuthenticator.canAuthenticate()
    private static let keychainKey = "BananoBiometricAuthPassphrase"
    
    private static func savePassphraseToKeychain(passphrase: String, player: Player) throws {
        guard let playerAddress = player.address else {
            throw BiometricsUtilsError.setupError
        }
        //whenUnlockedThisDeviceOnly
        let success = KeychainWrapper.standard.set(passphrase, forKey: keychainKey + playerAddress, withAccessibility: .whenUnlockedThisDeviceOnly)
        if !success {
            throw BiometricsUtilsError.setupError
        }
    }
    
    // Retrieves existing passphrase from keychain upon succesful biometric auth
    public static func retrieveWalletWithBiometricAuth(successHandler: @escaping BiometricsAuthSuccessHandler, errorHandler: @escaping BiometricsErrorHandler) {
        // Check if biometrics are available
        guard biometricsAvailable else {
            errorHandler(BiometricsUtilsError.biometricsUnavailable)
            return
        }
        
        // Fetch the current player
        var playerInstance: Player?
        do {
            playerInstance = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            print("\(error)")
            errorHandler(BiometricsUtilsError.unknownError)
        }
        
        guard let player = playerInstance else {
            errorHandler(BiometricsUtilsError.playerNotFound)
            return
        }
        
        guard let playerAddress = player.address else {
            errorHandler(BiometricsUtilsError.playerNotFound)
            return
        }
        
        let keychainKey = self.keychainKey + playerAddress
        if !KeychainWrapper.standard.allKeys().contains(keychainKey) {
            errorHandler(BiometricsUtilsError.credentialsRetrievalError)
            return
        }
        
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Biometric Authentication", fallbackTitle: "Biometric Authentication", success: {
            guard let passphrase = KeychainWrapper.standard.string(forKey: keychainKey, withAccessibility: .whenUnlockedThisDeviceOnly) else {
                errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                return
            }
            do {
                guard let wallet = try player.getWallet(passphrase: passphrase) else {
                    errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                    return
                }
                
                // Call the success handler with the retrieved wallet
                successHandler(wallet)
            } catch {
                errorHandler(BiometricsUtilsError.credentialsRetrievalError)
            }
        }) { (error) in
            // do nothing on canceled
            if error == .canceledByUser || error == .canceledBySystem {
                errorHandler(BiometricsUtilsError.cancelledByUser)
            } else if error == .biometryNotAvailable || error == .fallback || error == .biometryNotEnrolled {
                errorHandler(BiometricsUtilsError.biometricsUnavailable)
            } else if error == .biometryLockedout {
                // show passcode authentication
                BioMetricAuthenticator.authenticateWithPasscode(reason: "Biometrics Auth Locked, please provide Passcode", success: {
                    // Return wallet on success
                    guard let passphrase = KeychainWrapper.standard.string(forKey: keychainKey, withAccessibility: .whenUnlockedThisDeviceOnly) else {
                        errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                        return
                    }
                    do {
                        guard let wallet = try player.getWallet(passphrase: passphrase) else {
                            errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                            return
                        }
                        
                        // Call the success handler with the retrieved wallet
                        successHandler(wallet)
                    } catch {
                        errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                    }
                }) { (error) in
                    print(error.message())
                    errorHandler(BiometricsUtilsError.passcodeAuthError)
                }
            } else {
                errorHandler(BiometricsUtilsError.unknownError)
                print("\(error)")
            }
        }
    }
    
    // Needs for a player to exist in the local database
    public static func setupPlayerBiometricRecord(passphrase: String, successHandler: @escaping BiometricsSetupSuccessHandler, errorHandler: @escaping BiometricsErrorHandler) {
        
        // Check if biometrics are available
        guard biometricsAvailable else {
            errorHandler(BiometricsUtilsError.biometricsUnavailable)
            return
        }
        
        // Fetch the current player
        var playerInstance: Player?
        do {
            playerInstance = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            print("\(error)")
            errorHandler(BiometricsUtilsError.unknownError)
        }
        
        guard let player = playerInstance else {
            errorHandler(BiometricsUtilsError.playerNotFound)
            return
        }
        
        // Attempt bio auth
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Biometric Authentication Setup", fallbackTitle: "Biometric Authentication", success: {
            // Save passphrase to keychain with correct accesibility
            do {
                try savePassphraseToKeychain(passphrase: passphrase, player: player)
                successHandler()
            } catch {
                print("\(error)")
                errorHandler(error)
            }
        }, failure: { (error) in
            // do nothing on canceled
            if error == .canceledByUser || error == .canceledBySystem {
                errorHandler(BiometricsUtilsError.cancelledByUser)
            } else if error == .biometryNotAvailable || error == .fallback || error == .biometryNotEnrolled {
                errorHandler(BiometricsUtilsError.biometricsUnavailable)
            } else if error == .biometryLockedout {
                // show passcode authentication
                BioMetricAuthenticator.authenticateWithPasscode(reason: "Biometrics Auth Locked, please provide Passcode", success: {
                    // Save passphrase
                    do {
                        try savePassphraseToKeychain(passphrase: passphrase, player: player)
                        successHandler()
                    } catch {
                        print("\(error)")
                        errorHandler(error)
                    }
                }) { (error) in
                    print(error.message())
                    errorHandler(BiometricsUtilsError.passcodeAuthError)
                }
            } else {
                errorHandler(BiometricsUtilsError.unknownError)
                print("\(error)")
            }
        })
    }
}
