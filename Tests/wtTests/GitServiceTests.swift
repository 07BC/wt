//
//  GitServiceTests.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation
import Testing

@testable import wt

@Suite(.tags(.services))
struct GitServiceTests {
    private let sut: GitService
    private let mockShell: MockShellExecutor

    init() {
        mockShell = MockShellExecutor()
        sut = GitService(shell: mockShell)
    }

    // MARK: - isGitInstalled

    @Test("Returns true when git is installed")
    func isGitInstalled_whenGitExists_returnsTrue() throws {
        mockShell.mockOutput = "/usr/bin/git"

        let result = try sut.isGitInstalled()

        #expect(result == true)
    }

    @Test("Returns false when git is not installed")
    func isGitInstalled_whenGitNotFound_returnsFalse() throws {
        mockShell.shouldThrow = true

        let result = try sut.isGitInstalled()

        #expect(result == false)
    }

    // MARK: - isInsideWorkTree

    @Test("Returns true when inside git work tree")
    func isInsideWorkTree_whenInWorkTree_returnsTrue() throws {
        mockShell.mockOutput = "true\n"

        let result = try sut.isInsideWorkTree()

        #expect(result == true)
    }

    @Test("Returns false when outside git work tree")
    func isInsideWorkTree_whenOutsideWorkTree_returnsFalse() throws {
        mockShell.shouldThrow = true

        let result = try sut.isInsideWorkTree()

        #expect(result == false)
    }

    // MARK: - isInsideWorktree

    @Test("Returns true when inside a worktree")
    func isInsideWorktree_whenInWorktree_returnsTrue() throws {
        mockShell.mockOutput = "/path/to/repo/.git/worktrees/feature"

        let result = try sut.isInsideWorktree()

        #expect(result == true)
    }

    @Test("Returns false when in main repository")
    func isInsideWorktree_whenInMainRepo_returnsFalse() throws {
        mockShell.mockOutput = "/path/to/repo/.git"

        let result = try sut.isInsideWorktree()

        #expect(result == false)
    }

    // MARK: - getRepositoryRoot

    @Test("Returns repository root path")
    func getRepositoryRoot_returnsPath() throws {
        mockShell.mockOutput = "/path/to/repo\n"

        let result = try sut.getRepositoryRoot()

        #expect(result == "/path/to/repo")
    }

    // MARK: - getCurrentBranch

    @Test("Returns current branch name")
    func getCurrentBranch_returnsBranchName() throws {
        mockShell.mockOutput = "main\n"

        let result = try sut.getCurrentBranch()

        #expect(result == "main")
    }

    // MARK: - branchExists

    @Test("Returns true when local branch exists")
    func branchExists_whenLocalBranchExists_returnsTrue() throws {
        mockShell.mockOutput = "abc123"

        let result = try sut.branchExists("feature")

        #expect(result == true)
    }

    @Test("Returns false when branch does not exist")
    func branchExists_whenBranchNotFound_returnsFalse() throws {
        mockShell.shouldThrow = true

        let result = try sut.branchExists("nonexistent")

        #expect(result == false)
    }

    // MARK: - listWorktrees

    @Test("Returns parsed worktrees")
    func listWorktrees_returnsParsedWorktrees() throws {
        mockShell.mockOutput = """
            worktree /path/to/repo
            HEAD abc123
            branch refs/heads/main

            worktree /path/to/repo/.worktrees/feature
            HEAD def456
            branch refs/heads/feature

            """

        let result = try sut.listWorktrees()

        #expect(result.count == 2)
        #expect(result[0].path == "/path/to/repo")
        #expect(result[0].branch == "main")
        #expect(result[1].path == "/path/to/repo/.worktrees/feature")
        #expect(result[1].branch == "feature")
    }
}

// MARK: - Mock Shell Executor

final class MockShellExecutor: ShellExecutor, @unchecked Sendable {
    var mockOutput: String = ""
    var shouldThrow: Bool = false
    var executedCommands: [String] = []

    func execute(_ command: String) throws -> String {
        executedCommands.append(command)

        if shouldThrow {
            throw GitError.commandFailed(command: command, output: "Mock error")
        }

        return mockOutput
    }
}

// MARK: - Tags

extension Tag {
    @Tag static var services: Self
}
