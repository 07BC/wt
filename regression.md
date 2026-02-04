# wt CLI Regression Test

This document contains step-by-step instructions for validating the `wt` CLI tool. An AI assistant should execute each step sequentially, verify the expected outcome, and report any failures.

## Prerequisites

Before running these tests, ensure:
1. You are in the `/Users/j.lesouef/Developer/wt` directory
2. The project has been built (`swift build`)
3. Git is installed and available

## Test Environment Setup

Create a temporary test repository to avoid affecting the main project.

```bash
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init
git commit --allow-empty -m "Initial commit"
git branch feature-test
```

**Expected**: A new git repository is created with a `main` branch and a `feature-test` branch.

---

## Test 1: Help Command

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt --help
```

**Expected Output Contains**:
- `OVERVIEW: Git worktree management tool`
- `SUBCOMMANDS:`
- `create`
- `branch`
- `delete`
- `list`

**Pass Criteria**: All expected strings are present in output.

---

## Test 2: Version Command

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt --version
```

**Expected Output**: `1.0.0`

**Pass Criteria**: Output equals `1.0.0`.

---

## Test 3: List Command (Empty State)

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt list
```

**Expected Output Contains**:
- The current directory path
- `main` or `master`
- `[main]` marker indicating main worktree

**Pass Criteria**: Output shows one worktree entry with the main marker.

---

## Test 4: Create Command

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt create test-worktree
```

**Expected Output Contains**:
- `Creating worktree 'test-worktree' with new branch from 'main'`
- `Worktree created at:`
- `.worktrees/test-worktree`

**Pass Criteria**: Success message displayed and path contains `.worktrees/test-worktree`. A new branch named `test-worktree` is created based on `main`.

**Verification**:
```bash
ls -la .worktrees/
git branch
```

**Expected**: Directory `test-worktree` exists in `.worktrees/` and branch `test-worktree` appears in git branch output.

---

## Test 5: List Command (After Create)

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt list
```

**Expected Output Contains**:
- Two worktree entries
- One entry with `[main]` marker
- One entry containing `.worktrees/test-worktree`

**Pass Criteria**: Both worktrees are listed.

---

## Test 6: Branch Command

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt branch feature-test
```

**Expected Output Contains**:
- `Creating worktree 'feature-test' from branch 'feature-test'`
- `Worktree created at:`
- `.worktrees/feature-test`

**Pass Criteria**: Success message displayed.

**Verification**:
```bash
ls -la .worktrees/
```

**Expected**: Both `test-worktree` and `feature-test` directories exist.

---

## Test 7: Branch Command with Custom Name

**Setup** (create another branch first):
```bash
git branch another-branch
```

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt branch another-branch --name custom-name
```

**Expected Output Contains**:
- `Creating worktree 'custom-name' from branch 'another-branch'`
- `Worktree created at:`
- `.worktrees/custom-name`

**Pass Criteria**: Worktree created with custom name.

---

## Test 8: List Command (Multiple Worktrees)

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt list
```

**Expected Output Contains**:
- Four worktree entries total
- `test-worktree`
- `feature-test`
- `custom-name`

**Pass Criteria**: All created worktrees are listed.

---

## Test 9: Delete Command

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt delete test-worktree
```

**Expected Output Contains**:
- `Removing worktree 'test-worktree'`
- `removed successfully`

**Pass Criteria**: Success message displayed.

**Verification**:
```bash
ls -la .worktrees/
```

**Expected**: `test-worktree` no longer exists. `feature-test` and `custom-name` remain.

---

## Test 10: Delete Non-Existent Worktree

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt delete nonexistent 2>&1
```

**Expected Output Contains**:
- `Error:`
- `Worktree not found: nonexistent`

**Pass Criteria**: Error message displayed, command exits with non-zero status.

---

## Test 11: Create Duplicate Worktree

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt create feature-test 2>&1
```

**Expected Output Contains**:
- `Error:`
- `Worktree already exists`

**Pass Criteria**: Error message displayed, duplicate creation prevented.

---

## Test 12: Branch Command with Non-Existent Branch

**Command**:
```bash
/Users/j.lesouef/Developer/wt/.build/debug/wt branch nonexistent-branch 2>&1
```

**Expected Output Contains**:
- `Error:`
- `Branch not found: nonexistent-branch`

**Pass Criteria**: Error message displayed for non-existent branch.

---

## Test 13: Config File Creation

**Command**:
```bash
cat .wt/config.json 2>/dev/null || echo "Config not found"
```

**Expected**: Either valid JSON config or "Config not found" (config is created on first write operation).

If config exists, **Expected JSON Structure**:
```json
{
  "createdAt": "<ISO8601 date>",
  "mainBranch": "main",
  "worktreeDirectory": ".worktrees"
}
```

**Pass Criteria**: Config file has correct structure if present.

---

## Test 14: Error Outside Git Repository

**Command**:
```bash
cd /tmp && /Users/j.lesouef/Developer/wt/.build/debug/wt list 2>&1
```

**Expected Output Contains**:
- `Error:`
- `Not in a git repository`

**Pass Criteria**: Helpful error message when run outside git repo.

---

## Test 15: Verbose List

**Command** (run from test directory):
```bash
cd "$TEST_DIR" && /Users/j.lesouef/Developer/wt/.build/debug/wt list --verbose
```

**Expected Output Contains**:
- Commit hash (7 characters)
- Branch names
- Path information

**Pass Criteria**: Verbose output includes additional commit information.

---

## Cleanup

After all tests complete:

```bash
cd /
rm -rf "$TEST_DIR"
```

---

## Test Summary

| Test | Description | Status |
|------|-------------|--------|
| 1 | Help command | |
| 2 | Version command | |
| 3 | List (empty state) | |
| 4 | Create worktree | |
| 5 | List (after create) | |
| 6 | Branch command | |
| 7 | Branch with custom name | |
| 8 | List (multiple) | |
| 9 | Delete worktree | |
| 10 | Delete non-existent | |
| 11 | Create duplicate | |
| 12 | Branch non-existent | |
| 13 | Config file | |
| 14 | Error outside repo | |
| 15 | Verbose list | |

## Reporting

After executing all tests, report:
1. Total tests: 15
2. Passed: X
3. Failed: X
4. Any unexpected behaviour or output

If any test fails, include:
- Test number
- Actual output
- Expected output
- Possible cause
