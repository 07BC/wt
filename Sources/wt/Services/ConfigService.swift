//
//  ConfigService.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation

protocol ConfigServiceProtocol: Sendable {
    func loadConfig(from repositoryRoot: String) throws -> Config
    func saveConfig(_ config: Config, to repositoryRoot: String) throws
    func configExists(in repositoryRoot: String) -> Bool
}

struct ConfigService: ConfigServiceProtocol {
    init() {}

    func loadConfig(from repositoryRoot: String) throws -> Config {
        let configPath = configFilePath(for: repositoryRoot)

        guard FileManager.default.fileExists(atPath: configPath) else {
            return Config.defaultConfig
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Config.self, from: data)
    }

    func saveConfig(_ config: Config, to repositoryRoot: String) throws {
        let configDirectory = configDirectoryPath(for: repositoryRoot)
        let configPath = configFilePath(for: repositoryRoot)

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

    func configExists(in repositoryRoot: String) -> Bool {
        FileManager.default.fileExists(atPath: configFilePath(for: repositoryRoot))
    }

    private func configDirectoryPath(for repositoryRoot: String) -> String {
        (repositoryRoot as NSString).appendingPathComponent(".wt")
    }

    private func configFilePath(for repositoryRoot: String) -> String {
        (configDirectoryPath(for: repositoryRoot) as NSString).appendingPathComponent("config.json")
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
