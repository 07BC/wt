//
//  DeleteCommand.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import ArgumentParser
import Foundation

struct DeleteCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a worktree"
    )

    @Argument(help: "Name of the worktree to delete")
    var name: String

    @Flag(name: .shortAndLong, help: "Force deletion even if worktree has changes")
    var force = false

    func run() throws {
        let validationService = ValidationService()
        let gitService = GitService()
        let configService = ConfigService()

        let validation = try validationService.validateEnvironment()
        let config = try configService.loadConfig(from: validation.repositoryRoot)

        let worktreePath = buildWorktreePath(
            repositoryRoot: validation.repositoryRoot,
            worktreeDirectory: config.worktreeDirectory,
            name: name
        )

        let existingWorktrees = try gitService.listWorktrees()
        guard existingWorktrees.contains(where: { $0.path == worktreePath }) else {
            throw GitError.worktreeNotFound(name)
        }

        print("Removing worktree '\(name)'...")
        try gitService.removeWorktree(path: worktreePath, force: force)

        print("Worktree '\(name)' removed successfully.")
    }

    private func buildWorktreePath(repositoryRoot: String, worktreeDirectory: String, name: String) -> String {
        let base = (repositoryRoot as NSString).appendingPathComponent(worktreeDirectory)
        return (base as NSString).appendingPathComponent(name)
    }
}
