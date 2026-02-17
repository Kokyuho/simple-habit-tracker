import Foundation
import CryptoKit
import Security

enum SecureHabitStoreError: Error {
    case keychainFailure(OSStatus)
    case malformedEncryptedData
}

final class SecureHabitStore {
    private let fileManager = FileManager.default
    private let service = "com.example.SimpleHabitTracker"
    private let keyAccount = "habits.encryption.key"
    private let appSupportFolderName = "SimpleHabitTracker"
    private let encryptedFileName = "habits.enc"

    func save(_ habits: [Habit]) throws {
        let payload = try JSONEncoder().encode(habits)
        let encrypted = try encrypt(payload)
        let fileURL = try encryptedFileURL()
        try encrypted.write(to: fileURL, options: .atomic)
    }

    func load() throws -> [Habit]? {
        let fileURL = try encryptedFileURL()
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let encrypted = try Data(contentsOf: fileURL)
        let decrypted = try decrypt(encrypted)
        return try JSONDecoder().decode([Habit].self, from: decrypted)
    }

    func encryptedStoragePath() throws -> String {
        try encryptedFileURL().path
    }

    private func encrypt(_ data: Data) throws -> Data {
        let key = try obtainOrCreateKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw SecureHabitStoreError.malformedEncryptedData
        }
        return combined
    }

    private func decrypt(_ encrypted: Data) throws -> Data {
        let key = try obtainOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encrypted)
        return try AES.GCM.open(sealedBox, using: key)
    }

    private func obtainOrCreateKey() throws -> SymmetricKey {
        if let existingKey = try fetchKeyFromKeychain() {
            return existingKey
        }

        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        try storeKeyInKeychain(keyData)
        return newKey
    }

    private func fetchKeyFromKeychain() throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: keyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess, let data = item as? Data else {
            throw SecureHabitStoreError.keychainFailure(status)
        }

        return SymmetricKey(data: data)
    }

    private func storeKeyInKeychain(_ keyData: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: keyAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureHabitStoreError.keychainFailure(status)
        }
    }

    private func encryptedFileURL() throws -> URL {
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw CocoaError(.fileNoSuchFile)
        }

        let folderURL = appSupportURL.appendingPathComponent(appSupportFolderName, isDirectory: true)
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        return folderURL.appendingPathComponent(encryptedFileName)
    }
}
