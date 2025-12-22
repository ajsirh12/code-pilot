---
description: Clean up local branches marked as [gone] (deleted on remote)
allowed-tools: Bash(git:*)
---

## Clean Up Stale Branches

Remove local branches that have been deleted from the remote repository.

## Workflow

### 1. Fetch and Prune

```bash
git fetch --prune
```

### 2. List Branches with [gone] Status

```bash
git branch -v
```

Branches with `[gone]` status have been deleted on remote.
Branches with `+` prefix have associated worktrees.

### 3. List Worktrees (if any)

```bash
git worktree list
```

### 4. Remove [gone] Branches

```bash
# Process all [gone] branches, removing '+' prefix if present
git branch -v | grep '\[gone\]' | sed 's/^[+* ]//' | awk '{print $1}' | while read branch; do
  echo "Processing branch: $branch"
  # Find and remove worktree if it exists
  worktree=$(git worktree list | grep "\\[$branch\\]" | awk '{print $1}')
  if [ ! -z "$worktree" ] && [ "$worktree" != "$(git rev-parse --show-toplevel)" ]; then
    echo "  Removing worktree: $worktree"
    git worktree remove --force "$worktree"
  fi
  # Delete the branch
  echo "  Deleting branch: $branch"
  git branch -D "$branch"
done
```

## Expected Result

- List all local branches with their status
- Remove worktrees associated with [gone] branches
- Delete all branches marked as [gone]
- Report which branches were removed

If no branches are marked as [gone], report that no cleanup was needed.
