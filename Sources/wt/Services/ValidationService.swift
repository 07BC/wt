//
//  ValidationService.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation

protocol ValidationServiceProtocol: Sendable {
    func validateEnvironment() throws -> ValidationResult
}

struct ValidationResult: Sendable {
    let repositoryRoot: String
    let isInWorktree: Bool
}

struct ValidationService: ValidationServiceProtocol {
    private let gitService: GitServiceProtocol

    init(gitService: GitServiceProtocol = GitService()) {
        self.gitService = gitService
    }

    func validateEnvironment() throws -> ValidationResult {
        guard try gitService.isGitInstalled() else {
            throw ValidationError.gitNotInstalled
        }

        guard try gitService.isInsideWorkTree() else {
            throw ValidationError.notInGitRepository
        }

        let repositoryRoot = try gitService.getRepositoryRoot()
        let isInWorktree = try gitService.isInsideWorktree()

        return ValidationResult(
            repositoryRoot: repositoryRoot,
            isInWorktree: isInWorktree
        )
    }
}

// MARK: - Errors

enum ValidationError: Error, LocalizedError {
    case gitNotInstalled
    case notInGitRepository
    case alreadyInWorktree

    var errorDescription: String? {
        switch self {
        case .gitNotInstalled:
            return "Git is not installed. Please install git and try again."
        case .notInGitRepository:
            return "Not in a git repository. Please run this command from within a git repository."
        case .alreadyInWorktree:
            return "Already inside a worktree. Please run this command from the main repository."
        }
    }
}
