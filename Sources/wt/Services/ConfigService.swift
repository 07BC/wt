//
//  ConfigService.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation

protocol ConfigServiceProtocol: Sendable {
    func loadConfig() throws -> Config
    func saveConfig(_ config: Config) throws
    func configExists() -> Bool
}

struct ConfigService: ConfigServiceProtocol {
    private let baseDirectory: String

    init(baseDirectory: String = NSHomeDirectory()) {
        self.baseDirectory = baseDirectory
    }

    func loadConfig() throws -> Config {
        let configPath = configFilePath()

        guard FileManager.default.fileExists(atPath: configPath) else {
            return Config.defaultConfig
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Config.self, from: data)
    }

    func saveConfig(_ config: Config) throws {
        let configDirectory = configDirectoryPath()
        let configPath = configFilePath()

        if !FileManager.default.fileExists(atPath: configDirectory) {
            try FileManager.default.createDirectory(
                atPath: configDirectory,
                withIntermediateDirectories: true
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)

        try data.write(to: URL(fileURLWithPath: configPath))
    }

    func configExists() -> Bool {
        FileManager.default.fileExists(atPath: configFilePath())
    }

    private func configDirectoryPath() -> String {
        (baseDirectory as NSString).appendingPathComponent(".wt")
    }

    private func configFilePath() -> String {
        (configDirectoryPath() as NSString).appendingPathComponent("config.json")
    }
}

// MARK: - Errors

enum ConfigError: Error, LocalizedError {
    case failedToLoad(String)
    case failedToSave(String)

    var errorDescription: String? {
        switch self {
        case .failedToLoad(let reason):
            return "Failed to load configuration: \(reason)"
        case .failedToSave(let reason):
            return "Failed to save configuration: \(reason)"
        }
    }
}
