//
//  GitService.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation

protocol GitServiceProtocol: Sendable {
    func isGitInstalled() throws -> Bool
    func isInsideWorkTree() throws -> Bool
    func isInsideWorktree() throws -> Bool
    func getRepositoryRoot() throws -> String
    func getCurrentBranch() throws -> String
    func branchExists(_ branch: String) throws -> Bool
    func listWorktrees() throws -> [Worktree]
    func addWorktree(path: String, branch: String) throws
    func addWorktreeWithNewBranch(path: String, newBranch: String, baseBranch: String) throws
    func removeWorktree(path: String, force: Bool) throws
}

struct GitService: GitServiceProtocol {
    private let shell: ShellExecutor

    init(shell: ShellExecutor = ProcessShellExecutor()) {
        self.shell = shell
    }

    func isGitInstalled() throws -> Bool {
        do {
            _ = try shell.execute("which git")
            return true
        } catch {
            return false
        }
    }

    func isInsideWorkTree() throws -> Bool {
        do {
            let output = try shell.execute("git rev-parse --is-inside-work-tree")
            return output.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        } catch {
            return false
        }
    }

    func isInsideWorktree() throws -> Bool {
        do {
            let gitDir = try shell.execute("git rev-parse --git-dir")
            return gitDir.contains(".git/worktrees")
        } catch {
            return false
        }
    }

    func getRepositoryRoot() throws -> String {
        let output = try shell.execute("git rev-parse --show-toplevel")
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func getCurrentBranch() throws -> String {
        let output = try shell.execute("git branch --show-current")
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func branchExists(_ branch: String) throws -> Bool {
        do {
            _ = try shell.execute("git rev-parse --verify \(branch)")
            return true
        } catch {
            do {
                _ = try shell.execute("git rev-parse --verify origin/\(branch)")
                return true
            } catch {
                return false
            }
        }
    }

    func listWorktrees() throws -> [Worktree] {
        let output = try shell.execute("git worktree list --porcelain")
        return Worktree.parse(from: output)
    }

    func addWorktree(path: String, branch: String) throws {
        _ = try shell.execute("git worktree add \"\(path)\" \(branch)")
    }

    func addWorktreeWithNewBranch(path: String, newBranch: String, baseBranch: String) throws {
        _ = try shell.execute("git worktree add -b \(newBranch) \"\(path)\" \(baseBranch)")
    }

    func removeWorktree(path: String, force: Bool) throws {
        let forceFlag = force ? " --force" : ""
        _ = try shell.execute("git worktree remove \"\(path)\"\(forceFlag)")
    }
}

// MARK: - Shell Executor

protocol ShellExecutor: Sendable {
    func execute(_ command: String) throws -> String
}

struct ProcessShellExecutor: ShellExecutor {
    func execute(_ command: String) throws -> String {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 else {
            throw GitError.commandFailed(command: command, output: output)
        }

        return output
    }
}

// MARK: - Errors

enum GitError: Error, LocalizedError {
    case commandFailed(command: String, output: String)
    case notAGitRepository
    case branchNotFound(String)
    case worktreeNotFound(String)
    case worktreeAlreadyExists(String)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let command, let output):
            return "Command failed: \(command)\n\(output)"
        case .notAGitRepository:
            return "Not a git repository"
        case .branchNotFound(let branch):
            return "Branch not found: \(branch)"
        case .worktreeNotFound(let name):
            return "Worktree not found: \(name)"
        case .worktreeAlreadyExists(let name):
            return "Worktree already exists: \(name)"
        }
    }
}
