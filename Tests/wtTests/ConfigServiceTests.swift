//
//  ConfigServiceTests.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation
import Testing

@testable import wt

@Suite(.tags(.services))
struct ConfigServiceTests {
    private let sut: ConfigService
    private let testDirectory: String

    init() throws {
        testDirectory = NSTemporaryDirectory() + "wt-test-\(UUID().uuidString)"
        try FileManager.default.createDirectory(
            atPath: testDirectory,
            withIntermediateDirectories: true
        )
        sut = ConfigService(baseDirectory: testDirectory)
    }

    // MARK: - loadConfig

    @Test("Returns default config when config file does not exist")
    func loadConfig_whenNoConfigFile_returnsDefault() throws {
        let result = try sut.loadConfig()

        #expect(result.worktreeDirectory == ".worktrees")
        #expect(result.mainBranch == "main")
    }

    @Test("Returns saved config when config file exists")
    func loadConfig_whenConfigExists_returnsConfig() throws {
        let config = Config(
            worktreeDirectory: ".custom-worktrees",
            mainBranch: "develop",
            createdAt: Date()
        )
        try sut.saveConfig(config)

        let result = try sut.loadConfig()

        #expect(result.worktreeDirectory == ".custom-worktrees")
        #expect(result.mainBranch == "develop")
    }

    // MARK: - saveConfig

    @Test("Saves config to .wt/config.json")
    func saveConfig_createsConfigFile() throws {
        let config = Config(
            worktreeDirectory: ".worktrees",
            mainBranch: "main",
            createdAt: Date()
        )

        try sut.saveConfig(config)

        let configPath = (testDirectory as NSString)
            .appendingPathComponent(".wt")
            .appending("/config.json")
        #expect(FileManager.default.fileExists(atPath: configPath) == true)
    }

    @Test("Creates .wt directory if it does not exist")
    func saveConfig_createsDirectory() throws {
        let config = Config.defaultConfig

        try sut.saveConfig(config)

        let wtDirectory = (testDirectory as NSString).appendingPathComponent(".wt")
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: wtDirectory, isDirectory: &isDirectory)
        #expect(exists == true)
        #expect(isDirectory.boolValue == true)
    }

    // MARK: - configExists

    @Test("Returns false when config does not exist")
    func configExists_whenNoConfig_returnsFalse() {
        let result = sut.configExists()

        #expect(result == false)
    }

    @Test("Returns true when config exists")
    func configExists_whenConfigExists_returnsTrue() throws {
        try sut.saveConfig(Config.defaultConfig)

        let result = sut.configExists()

        #expect(result == true)
    }
}
