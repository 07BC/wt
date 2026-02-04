# wt - Git Worktree Management Tool

A Swift command-line tool that simplifies git worktree management.

## What Are Git Worktrees?

Git worktrees will change your life. Maybe even spacetime itself. They are genuinely one of Git's best-kept secrets... and also a complete pain in the arse to use.

**The Problem**: You're halfway through a feature branch, your code is a beautiful disaster of half-finished experiments, and suddenly someone needs an urgent hotfix on `main`. What do you do?

- `git stash`? Good luck remembering what you stashed three weeks ago.
- Commit your work-in-progress? Enjoy that `"WIP: stuff and things"` polluting your history.
- Clone the repo again? Now you have two repos and existential confusion.

**The Solution**: Git worktrees let you have multiple branches checked out *simultaneously* in separate directories. It's like having parallel universes of your codebase, except you don't need a PhD in quantum mechanics to manage them.

### Why They're Brilliant

- **No more stashing** - Leave your feature branch exactly as it is
- **Instant context switching** - Just `cd` to another worktree
- **Shared `.git` directory** - One repo, multiple checkouts, minimal disk space
- **Run tests in parallel** - Build your feature while running tests on `main`
- **Review PRs properly** - Check out the PR branch without disrupting your flow

### Why This Tool Exists

Because the native git commands look like this:

```bash
git worktree add ../my-repo-feature-branch feature-branch
git worktree list
git worktree remove ../my-repo-feature-branch
```

And remembering the exact path you used three days ago when you created that worktree? Absolutely not happening.

`wt` keeps everything organised in a `.worktrees` directory and handles the faff so you don't have to.

## Requirements

- macOS 13+ (Intel or Apple Silicon)
- Git

## Installation

### Download Pre-built Binary (Recommended)

```bash
# Download the latest release
curl -L https://github.com/07BC/wt/releases/latest/download/wt -o /usr/local/bin/wt

# Make it executable
chmod +x /usr/local/bin/wt
```

### From Source

Requires Swift 6.0+

```bash
# Clone the repository
git clone https://github.com/07BC/wt.git
cd wt

# Build and install
make install
```

Or manually:

```bash
swift build -c release
cp .build/release/wt /usr/local/bin/wt
```

## Usage

### Subcommands

```bash
# List all worktrees (default command)
wt
wt list

# Create a worktree from the main branch
wt create                    # Auto-generates name
wt create my-feature         # Custom name

# Create a worktree from a specific branch
wt branch feature-login
wt branch feature-login --name custom-name

# Delete a worktree
wt delete my-feature
wt delete my-feature --force  # Force delete with uncommitted changes

# Show help
wt --help
wt create --help
```

### Shorthand Flags

For quick access, use the shorthand flags with an optional name argument:

```bash
# List all worktrees
wt -l                        # Same as: wt list

# Create a worktree with a new branch from main
wt -c                        # Same as: wt create (auto-generates name)
wt -c my-feature             # Same as: wt create my-feature

# Create a worktree from an existing branch
wt -b feature-login          # Same as: wt branch feature-login

# Delete a worktree
wt -d my-feature             # Same as: wt delete my-feature
```

## Configuration

Configuration is stored in `.wt/config.json` at the repository root:

```json
{
    "worktreeDirectory": ".worktrees",
    "mainBranch": "main",
    "createdAt": "2026-02-04T12:00:00Z"
}
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `worktreeDirectory` | `.worktrees` | Directory where worktrees are stored |
| `mainBranch` | `main` | Default branch for `wt create` |

## Directory Structure

Worktrees are stored in `.worktrees/` at the repository root:

```
my-repo/
├── .git/
├── .wt/
│   └── config.json
├── .worktrees/
│   ├── feature-login/
│   └── bugfix-auth/
└── src/
```

## Shell Integration

### Aliases (Optional)

The tool has built-in shorthand flags (`-c`, `-b`, `-d`, `-l`), but you can add shell aliases for even quicker access:

```bash
# Add to .zshrc or .bashrc
alias wtl='wt -l'
alias wtc='wt -c'
alias wtb='wt -b'
alias wtd='wt -d'
```

### Function to change directory to worktree

```bash
# Change to a worktree directory
wtcd() {
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Not in a git repository"
        return 1
    fi
    cd "$repo_root/.worktrees/$1"
}

# Tab completion for wtcd
_wtcd() {
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$repo_root" && -d "$repo_root/.worktrees" ]]; then
        COMPREPLY=($(ls "$repo_root/.worktrees" 2>/dev/null | grep "^$2"))
    fi
}
complete -F _wtcd wtcd
```

## Development

```bash
# Build
make build

# Run tests
make test

# Clean
make clean
```

## Licence

MIT
