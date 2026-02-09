//
//  CreateCommand.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import ArgumentParser
import Foundation

struct CreateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new worktree with a new branch based on main"
    )

    @Argument(help: "Name for the new worktree")
    var name: String?

    func run() throws {
        let validationService = ValidationService()
        let gitService = GitService()
        let configService = ConfigService()

        let validation = try validationService.validateEnvironment()
        let config = try configService.loadConfig()

        let worktreeName = name ?? generateWorktreeName()
        let worktreePath = buildWorktreePath(
            repositoryRoot: validation.repositoryRoot,
            worktreeDirectory: config.worktreeDirectory,
            name: worktreeName
        )

        let existingWorktrees = try gitService.listWorktrees()
        if existingWorktrees.contains(where: { $0.path == worktreePath }) {
            throw GitError.worktreeAlreadyExists(worktreeName)
        }

        try ensureWorktreeDirectoryExists(
            repositoryRoot: validation.repositoryRoot,
            worktreeDirectory: config.worktreeDirectory
        )

        print("Creating worktree '\(worktreeName)' with new branch from '\(config.mainBranch)'...")
        try gitService.addWorktreeWithNewBranch(
            path: worktreePath,
            newBranch: worktreeName,
            baseBranch: config.mainBranch
        )

        if !configService.configExists() {
            try configService.saveConfig(config)
        }

        print("Worktree created at: \(worktreePath)")
    }

    private func generateWorktreeName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "worktree-\(formatter.string(from: Date()))"
    }

    private func buildWorktreePath(repositoryRoot: String, worktreeDirectory: String, name: String) -> String {
        let base = (repositoryRoot as NSString).appendingPathComponent(worktreeDirectory)
        return (base as NSString).appendingPathComponent(name)
    }

    private func ensureWorktreeDirectoryExists(repositoryRoot: String, worktreeDirectory: String) throws {
        let path = (repositoryRoot as NSString).appendingPathComponent(worktreeDirectory)
        if !FileManager.default.fileExists(atPath: path) {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
    }
}
