# ghh

**Your entire git + GitHub workflow in one searchable command.**

![demo](demo/ghh-demo.gif)
*Demo coming soon*

---

## The Problem

You know the commands exist. You just can't remember the exact syntax. So you stop what you're doing, switch to a browser, google "how to squash last 3 commits", copy the command, switch back. Multiply that by a dozen times a day across `git`, `gh`, CI checks, PR workflows, branch management.

## The Solution

Type `ghh`. Search for what you're thinking. Hit enter.

`ghh` puts **100+ git and GitHub CLI commands** into a single, searchable, fzf-powered menu. No memorization. No context switching. One command to rule them all.

It also includes `gc` — an interactive conventional commit builder that walks you through type, scope, and message with zero friction.

---

## Features

- **100+ commands** in one searchable menu — git, gh, PRs, CI, issues, branches, worktrees, stashes, diffs
- **Interactive conventional commits** via `gc` — pick type, add scope, write message, confirm
- **Smart chaining** — branch switching, stash picking, file blame, and PR checkout open secondary fzf pickers
- **Drill into CI checks** — pick a failing check and open it directly in your browser
- **Run, copy, or cancel** — every command gives you the choice
- **Cross-platform** — macOS, Linux, and WSL with automatic clipboard and browser detection
- **Zero config** — no config files, no setup, no themes. Just commands
- **One-line install** — curl it and go

---

## Install

### Quick Install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/jgorodetsky/ghh/main/install.sh | bash
```

This clones ghh to `~/.ghh/`, installs fzf if missing, and adds the source line to your shell config.

### Homebrew

```bash
brew tap jgorodetsky/ghh
brew install ghh
```

Then add to your `~/.zshrc` or `~/.bashrc`:

```bash
source $(brew --prefix)/bin/ghh
```

### Oh-My-Zsh Plugin

```bash
git clone https://github.com/jgorodetsky/ghh.git ~/.oh-my-zsh/custom/plugins/ghh
```

Add `ghh` to your plugins array in `~/.zshrc`:

```zsh
plugins=(... ghh)
```

### Manual

```bash
git clone https://github.com/jgorodetsky/ghh.git ~/.ghh
echo 'source "$HOME/.ghh/bin/ghh"' >> ~/.zshrc
source ~/.zshrc
```

---

## Usage

### `ghh` — The Command Center

```
$ ghh
```

A searchable menu appears. Type what you're thinking:

| You're thinking...       | Type...      | What happens                              |
| ------------------------ | ------------ | ----------------------------------------- |
| "I need to see my diff"  | `diff`       | Shows diff commands — pick one            |
| "Did CI pass?"           | `checks`     | Shows PR check commands                   |
| "Switch branch"          | `switch`     | Opens a branch picker                     |
| "Squash my commits"      | `squash`     | Prompts for how many, squashes            |
| "Create a PR"            | `pr create`  | Shows PR creation options                 |
| "What failed?"           | `failed`     | Shows failed run logs, failed check drill |
| "Undo last commit"       | `undo`       | Shows soft/hard reset options             |
| "Blame this file"        | `blame`      | Opens a file picker, then runs blame      |
| "Merge this PR"          | `merge`      | Shows merge strategy options              |
| "Work on another branch" | `worktree`   | Add, switch, remove, or bulk cleanup worktrees |
| "Start fresh"            | `reset`      | Fetch and reset branch to match remote    |
| "Open in browser"        | `web`        | Opens PR/repo/issue in your browser       |

For read-only commands (`git diff`, `git log`, `gh pr list`), ghh runs them directly. For commands that modify state, it shows the command and asks: **Run it? [Y/n/copy]**

### `gc` — Interactive Conventional Commit

```
$ gc
```

1. Pick commit type (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert)
2. Optionally add a scope
3. Type your message
4. Preview and confirm

Produces: `feat(auth): add OAuth2 login flow`

**Note:** `gc` does not stage files. Run `git add` first (or use `ghh` to stage interactively).

---

## Commands Reference

| Section              | What's in it                                                        |
| -------------------- | ------------------------------------------------------------------- |
| **Stage & Commit**   | `git add`, interactive staging, stash, stash pop, stash picker, `gc` |
| **Diff & Review**    | Unstaged/staged/branch diffs, log, graph, show, blame               |
| **Branch**           | Switch, list, delete, push, pull, merge, reset to remote — with fzf pickers |
| **Worktree**         | Add, switch, remove, bulk cleanup with branch deletion               |
| **Rewrite History**  | Soft/hard reset, amend, squash, interactive rebase                   |
| **Status & Info**    | Short status, remotes, email, branch name, full graph                |
| **PR: Create & Edit**| Create (interactive/fill/draft), edit title/labels/reviewers, ready/draft/close |
| **PR: View & Review**| List, view, comments, diff, checkout PR locally                      |
| **PR: Checks & CI**  | Check status, watch, required-only, drill into specific checks       |
| **PR: Merge**        | Squash/rebase/merge, auto-merge, delete branch                      |
| **PR: Feedback**     | Approve, request changes, comment                                   |
| **CI / Workflow Runs**| List, view, watch, rerun, download artifacts, cancel                |
| **Issues**           | List, view, create, close, comment                                  |
| **Repo & Search**    | Open in browser, clone, fork, search repos/code, notifications      |

---

## Dependencies

| Dependency | Required | Purpose                    | Install                      |
| ---------- | -------- | -------------------------- | ---------------------------- |
| **fzf**    | Yes      | Fuzzy finder for all menus | `brew install fzf`           |
| **git**    | Yes      | Git operations             | Pre-installed on most systems|
| **gh**     | Yes*     | GitHub CLI operations      | `brew install gh`            |

*`gh` is only required for GitHub-specific commands (PRs, issues, CI). All git commands work without it.

---

## Updating

If installed via the installer:

```bash
ghh-update
```

If installed via Homebrew:

```bash
brew upgrade ghh
```

---

## Uninstalling

If installed via the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/jgorodetsky/ghh/main/uninstall.sh | bash
```

Or manually:

```bash
rm -rf ~/.ghh
# Remove the source line from your ~/.zshrc or ~/.bashrc
```

If installed via Homebrew:

```bash
brew uninstall ghh
```

---

## Contributing

Contributions are welcome. Please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create your branch (`git checkout -b feat/my-feature`)
3. Commit using conventional commits (`gc` works great for this)
4. Push and open a PR

---

## License

[MIT](LICENSE)
