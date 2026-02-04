//
//  wt.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import ArgumentParser

@main
struct WT: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "wt",
        abstract: "Git worktree management tool",
        version: "1.0.0",
        subcommands: [
            CreateCommand.self,
            BranchCommand.self,
            DeleteCommand.self,
            ListCommand.self
        ]
    )

    @Flag(name: .short, help: "Create a new worktree with a new branch based on main (e.g. wt -c my-feature)")
    var create = false

    @Flag(name: .short, help: "Create a new worktree from a specified branch (e.g. wt -b feature-login)")
    var branch = false

    @Flag(name: .short, help: "Delete a worktree (e.g. wt -d my-feature)")
    var delete = false

    @Flag(name: .short, help: "List all worktrees (e.g. wt -l)")
    var list = false

    @Argument(help: "Name for the worktree or branch (e.g. my-feature)")
    var name: String?

    func run() throws {
        if create {
            if let name = name {
                let cmd = try CreateCommand.parse([name])
                try cmd.run()
            } else {
                let cmd = try CreateCommand.parse([])
                try cmd.run()
            }
        } else if branch {
            guard let branchName = name else {
                throw CleanExit.message("Error: Branch name is required when using -b")
            }
            let cmd = try BranchCommand.parse([branchName])
            try cmd.run()
        } else if delete {
            guard let worktreeName = name else {
                throw CleanExit.message("Error: Worktree name is required when using -d")
            }
            let cmd = try DeleteCommand.parse([worktreeName])
            try cmd.run()
        } else {
            let cmd = try ListCommand.parse([])
            try cmd.run()
        }
    }
}
