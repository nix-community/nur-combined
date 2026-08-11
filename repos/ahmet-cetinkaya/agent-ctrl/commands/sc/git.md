---
name: git
description: "Git operations with intelligent commit messages and workflow optimization"
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /sc:git - Git Operations

## Triggers
- Git repository operations: status, add, commit, push, pull, branch
- Need for intelligent commit message generation
- Repository workflow optimization requests
- Branch management and merge operations

## Usage
```
/sc:git [operation] [args] [--smart-commit] [--interactive]
```

## Behavioral Flow
1. **Analyze**: Check repository state and working directory changes
2. **Validate**: Ensure operation is appropriate for current Git context
3. **Select commit strategy**: Before committing a fix/refactor/review improvement, inspect
   recent history and upstream containment. If one provably unpushed non-merge commit owns the
   entire staged change, offer or use `git commit --fixup <sha>`; otherwise use a normal commit.
4. **Execute**: Run Git command with intelligent automation
5. **Optimize**: Apply smart commit messages and workflow patterns
6. **Report**: Provide status and next steps guidance

Key behaviors:
- Generate conventional commit messages based on change analysis
- Stage only related files or hunks; never mix independent changes into a fixup commit
- Autosquash local fixups before first push or PR creation, then rerun relevant checks
- Never rewrite published history without explicit authorization; use `--force-with-lease`, never `--force`
- Apply consistent branch naming conventions
- Handle merge conflicts with guided resolution
- Provide clear status summaries and workflow recommendations

## Tool Coordination
- **Bash**: Git command execution and repository operations
- **Read**: Repository state analysis and configuration review
- **Grep**: Log parsing and status analysis
- **Write**: Commit message generation and documentation

## Key Patterns
- **Smart Commits**: Analyze changes → generate conventional commit message
- **Local Fixups**: Related improvement + provably unpushed target → scoped `--fixup`; otherwise normal commit
- **Status Analysis**: Repository state → actionable recommendations
- **Branch Strategy**: Consistent naming and workflow enforcement
- **Error Recovery**: Conflict resolution and state restoration guidance

## Examples

### Smart Status Analysis
```
/sc:git status
# Analyzes repository state with change summary
# Provides next steps and workflow recommendations
```

### Intelligent Commit
```
/sc:git commit --smart-commit
# Generates conventional commit message from change analysis
# Applies best practices and consistent formatting
```

### Interactive Operations
```
/sc:git merge feature-branch --interactive
# Guided merge with conflict resolution assistance
```

## Boundaries

**Will:**
- Execute Git operations with intelligent automation
- Generate conventional commit messages from change analysis
- Provide workflow optimization and best practice guidance

**Will Not:**
- Modify repository configuration without explicit authorization
- Execute destructive operations without confirmation
- Handle complex merges requiring manual intervention
