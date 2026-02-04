//
//  Worktree.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation

struct Worktree: Sendable {
    let path: String
    let head: String
    let branch: String?
    let isBare: Bool

    var branchName: String {
        branch ?? head.prefix(7).description
    }

    var isMainWorktree: Bool {
        branch != nil && !path.contains(".worktrees")
    }
}

// MARK: - Parsing

extension Worktree {
    static func parse(from porcelainOutput: String) -> [Worktree] {
        let blocks = porcelainOutput.components(separatedBy: "\n\n")
        return blocks.compactMap { block -> Worktree? in
            let lines = block.split(separator: "\n", omittingEmptySubsequences: true)
            guard !lines.isEmpty else { return nil }

            var path: String?
            var head: String?
            var branch: String?
            var isBare = false

            for line in lines {
                if line.hasPrefix("worktree ") {
                    path = String(line.dropFirst("worktree ".count))
                } else if line.hasPrefix("HEAD ") {
                    head = String(line.dropFirst("HEAD ".count))
                } else if line.hasPrefix("branch ") {
                    let fullBranch = String(line.dropFirst("branch ".count))
                    branch = fullBranch.replacingOccurrences(of: "refs/heads/", with: "")
                } else if line == "bare" {
                    isBare = true
                }
            }

            guard let worktreePath = path, let worktreeHead = head else {
                return nil
            }

            return Worktree(
                path: worktreePath,
                head: worktreeHead,
                branch: branch,
                isBare: isBare
            )
        }
    }
}
