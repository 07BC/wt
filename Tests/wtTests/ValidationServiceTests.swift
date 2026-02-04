//
//  ValidationServiceTests.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation
import Testing

@testable import wt

@Suite(.tags(.services))
struct ValidationServiceTests {
    private let sut: ValidationService
    private let mockGitService: MockGitService

    init() {
        mockGitService = MockGitService()
        sut = ValidationService(gitService: mockGitService)
    }

    // MARK: - validateEnvironment

    @Test("Throws error when git is not installed")
    func validateEnvironment_whenGitNotInstalled_throws() throws {
        mockGitService.isGitInstalledResult = false

        #expect(throws: ValidationError.gitNotInstalled) {
            _ = try sut.validateEnvironment()
        }
    }

    @Test("Throws error when not in git repository")
    func validateEnvironment_whenNotInRepo_throws() throws {
        mockGitService.isGitInstalledResult = true
        mockGitService.isInsideWorkTreeResult = false

        #expect(throws: ValidationError.notInGitRepository) {
            _ = try sut.validateEnvironment()
        }
    }

    @Test("Returns validation result when environment is valid")
    func validateEnvironment_whenValid_returnsResult() throws {
        mockGitService.isGitInstalledResult = true
        mockGitService.isInsideWorkTreeResult = true
        mockGitService.repositoryRoot = "/path/to/repo"
        mockGitService.isInsideWorktreeResult = false

        let result = try sut.validateEnvironment()

        #expect(result.repositoryRoot == "/path/to/repo")
        #expect(result.isInWorktree == false)
    }

    @Test("Returns isInWorktree true when inside a worktree")
    func validateEnvironment_whenInWorktree_returnsTrue() throws {
        mockGitService.isGitInstalledResult = true
        mockGitService.isInsideWorkTreeResult = true
        mockGitService.repositoryRoot = "/path/to/repo/.worktrees/feature"
        mockGitService.isInsideWorktreeResult = true

        let result = try sut.validateEnvironment()

        #expect(result.isInWorktree == true)
    }
}

// MARK: - Mock Git Service

final class MockGitService: GitServiceProtocol, @unchecked Sendable {
    var isGitInstalledResult = true
    var isInsideWorkTreeResult = true
    var isInsideWorktreeResult = false
    var repositoryRoot = "/path/to/repo"
    var currentBranch = "main"
    var branchExistsResult = true
    var worktrees: [Worktree] = []

    func isGitInstalled() throws -> Bool {
        isGitInstalledResult
    }

    func isInsideWorkTree() throws -> Bool {
        isInsideWorkTreeResult
    }

    func isInsideWorktree() throws -> Bool {
        isInsideWorktreeResult
    }

    func getRepositoryRoot() throws -> String {
        repositoryRoot
    }

    func getCurrentBranch() throws -> String {
        currentBranch
    }

    func branchExists(_ branch: String) throws -> Bool {
        branchExistsResult
    }

    func listWorktrees() throws -> [Worktree] {
        worktrees
    }

    func addWorktree(path: String, branch: String) throws {}

    func addWorktreeWithNewBranch(path: String, newBranch: String, baseBranch: String) throws {}

    func removeWorktree(path: String, force: Bool) throws {}
}
