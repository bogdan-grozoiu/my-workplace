---
name: git-workflows
description: Guidelines for Git command usage and workflows. Use this skill whenever the user asks Claude to interact with Git repositories, including commits, branches, diffs, logs, or repository state inspection. Emphasizes user autonomy for write operations and Claude's responsibility for information retrieval.
---

# Git Workflows

Guidelines for how Claude should interact with Git repositories and collaborate on version control tasks.

---

## Core Principle

**User owns write operations. Claude owns information retrieval.**

The user is the decision-maker for committing, pushing, and altering repository history. Claude should fetch information directly when needed, rather than asking the user to run commands.

---

## Write Operations (git add, commit, push)

**Don't perform write operations on behalf of the user.**

### For Commits
- ❌ Don't run `git add` or `git commit` directly
- ✅ Do: Tell the user what needs to be committed, then ask them to do it
- ✅ If they agree, they can run the command; you can provide the exact command to copy/paste

**Example workflow:**
1. Claude: "I've modified `config.py` and `tests/test_config.py`. These changes implement the new validation logic we discussed. Should I show you the diff before you commit?"
2. User: "Sure, show me the diff."
3. Claude: Shows the diff, user reviews
4. Claude: "Ready to commit? Run: `git add config.py tests/test_config.py && git commit -m 'Add email validation to config parser'`"
5. User runs the command

---

## Information Retrieval (git diff, git log, git status)

**Claude performs information retrieval directly.**

Don't ask the user to run these commands—use them yourself to gather context:

### When You Need Repository Information
- **Finding what changed:** Run `git diff <commit1>..<commit2>` or `git diff HEAD`
- **Understanding history:** Run `git log --oneline` or `git log -p` to see commit messages and changes
- **Current state:** Run `git status` to see modified/staged files
- **Blame/authorship:** Run `git blame <file>` if you need to understand who changed what and why

**Example:**
- User: "Did we update the authentication module recently?"
- Claude: Runs `git log --oneline -- auth.py` to check recent commits on that file
- Claude: Reports findings directly (no asking the user to run the command)

### Why This Matters
- The user shouldn't have to context-switch to your terminal
- You need the actual state to provide accurate advice
- Information retrieval has no side effects—it's safe to do directly

---

## Merge Conflicts & Branch Operations

### For Branch Creation/Switching
- ❌ Don't run `git checkout -b` or `git switch` on behalf of the user
- ✅ Do: Tell the user which branch to create, then verify they did (ask them to run the command)

### For Resolving Merge Conflicts
- ❌ Don't resolve conflicts and commit automatically
- ✅ Do: 
  1. Run `git status` to see conflicted files
  2. Show the user which files have conflicts
  3. Explain the conflict (both sides of the merge)
  4. Ask the user which version to keep, or propose a resolution
  5. If they agree, tell them how to resolve it; let them run the resolution commands

---

## Documentation Updates from Repo Changes

When asked to update documentation based on repository changes:

1. **Diff the repo** (`git diff` or `git log -p`) to find what actually changed
2. **Don't assume** which documentation sections are affected
3. **Read the changes** to identify what to update
4. **Report findings** to the user before modifying documentation
5. **Update commit ID** in documentation to the new commit

**Example:**
- User: "Update the docs to reflect the latest changes"
- Claude: 
  1. Runs `git log -1 --stat` to see what files changed
  2. Runs `git diff HEAD~1 HEAD` to see the changes
  3. Reports to user: "I found changes to the API authentication, database schema, and rate-limiting. The docs need updates in sections 3 (Authentication), 4 (Database), and 5 (Limits). Should I update all three, or focus on specific areas?"
  4. User confirms scope
  5. Claude updates documentation and commit ID accordingly

---

## Checking Before Claiming Knowledge

**If you don't know if something is in the repo, check instead of guessing.**

- ❌ "I think the function might be in `utils.py`"
- ✅ Run `git grep "function_name"` or read the relevant files to confirm

This is especially important when:
- The user asks if a file exists
- You need to find a specific function or configuration
- Understanding repo structure is critical to your advice

---

## Summary Table

| Task | Do It Yourself | Ask User | Notes |
|------|----------------|----------|-------|
| `git add` | ❌ | ✅ | Write operation—user decides |
| `git commit` | ❌ | ✅ | Write operation—user decides |
| `git push` | ❌ | ✅ | Write operation—user decides |
| `git checkout -b` | ❌ | ✅ | Write operation—user decides |
| `git diff` | ✅ | ❌ | Fetch context directly |
| `git log` | ✅ | ❌ | Fetch context directly |
| `git status` | ✅ | ❌ | Fetch context directly |
| `git blame` | ✅ | ❌ | Fetch context directly |
| `git grep` | ✅ | ❌ | Search for code directly |
| Conflict resolution | Explain, propose | ✅ | Let user decide and execute |

---

## Best Practices

1. **Show diffs before suggesting changes.** Help the user understand what changed.
2. **Provide copy-paste commands.** If the user needs to run a command, make it easy (exact command ready to paste).
3. **Verify assumptions.** Don't claim "the file doesn't exist" without checking first.
4. **Respect repository history.** Don't suggest rewriting history (rebase, force push) lightly.
5. **Document intent in commits.** Encourage clear commit messages that explain *why*, not just *what*.
