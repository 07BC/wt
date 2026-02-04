//
//  ListCommand.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all worktrees"
    )

    @Flag(name: .shortAndLong, help: "Show detailed output")
    var verbose = false

    func run() throws {
        let validationService = ValidationService()
        let gitService = GitService()

        _ = try validationService.validateEnvironment()

        let worktrees = try gitService.listWorktrees()

        if worktrees.isEmpty {
            print("No worktrees found.")
            return
        }

        printWorktrees(worktrees)
    }

    private func printWorktrees(_ worktrees: [Worktree]) {
        let maxPathLength = worktrees.map { $0.path.count }.max() ?? 0
        let maxBranchLength = worktrees.map { $0.branchName.count }.max() ?? 0

        for worktree in worktrees {
            let path = worktree.path.padding(toLength: maxPathLength + 2, withPad: " ", startingAt: 0)
            let branch = worktree.branchName.padding(toLength: maxBranchLength + 2, withPad: " ", startingAt: 0)

            if verbose {
                let marker = worktree.isMainWorktree ? "[main]" : ""
                print("\(path) \(branch) \(worktree.head.prefix(7)) \(marker)")
            } else {
                let marker = worktree.isMainWorktree ? " [main]" : ""
                print("\(path) \(branch)\(marker)")
            }
        }
    }
}
