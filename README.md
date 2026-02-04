# wt - Git Worktree Management Tool

A Swift command-line tool that simplifies git worktree management.

## Requirements

- macOS 13+
- Swift 6.0+
- Git

## Installation

### From Source

```bash
# Clone the repository
git clone https://github.com/yourusername/wt.git
cd wt

# Build and install
./install.sh
```

Or using make:

```bash
make install
```

### Manual Build

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

```bash
wt -l                        # List all worktrees
wt -c my-feature             # Create worktree with new branch
wt -b feature-login          # Create worktree from existing branch
wt -d my-feature             # Delete worktree
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
