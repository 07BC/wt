//
//  BranchCommand.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import ArgumentParser
import Foundation

struct BranchCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "branch",
        abstract: "Create a new worktree from a specified branch"
    )

    @Argument(help: "Name of the branch to create worktree from")
    var branchName: String

    @Option(name: .shortAndLong, help: "Custom name for the worktree directory")
    var name: String?

    func run() throws {
        let validationService = ValidationService()
        let gitService = GitService()
        let configService = ConfigService()

        let validation = try validationService.validateEnvironment()
        let config = try configService.loadConfig(from: validation.repositoryRoot)

        guard try gitService.branchExists(branchName) else {
            throw GitError.branchNotFound(branchName)
        }

        let worktreeName = name ?? sanitiseBranchName(branchName)
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

        print("Creating worktree '\(worktreeName)' from branch '\(branchName)'...")
        try gitService.addWorktree(path: worktreePath, branch: branchName)

        if !configService.configExists(in: validation.repositoryRoot) {
            try configService.saveConfig(config, to: validation.repositoryRoot)
        }

        print("Worktree created at: \(worktreePath)")
    }

    private func sanitiseBranchName(_ branch: String) -> String {
        branch
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
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
