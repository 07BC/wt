//
//  Config.swift
//  wt
//
//  Created by Jamie Le Souëf on 4/2/2026.
//

import Foundation

struct Config: Codable, Sendable {
    var worktreeDirectory: String
    var mainBranch: String
    var createdAt: Date

    static let defaultConfig = Config(
        worktreeDirectory: ".worktrees",
        mainBranch: "main",
        createdAt: Date()
    )
}
