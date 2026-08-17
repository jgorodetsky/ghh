# ghh

**Your entire git + GitHub workflow in one searchable command.**

![demo](demo/ghh-demo.gif)

---

## The Problem

You know the commands exist. You just can't remember the exact syntax. So you stop what you're doing, switch to a browser, google "how to squash last 3 commits", copy the command, switch back. Multiply that by a dozen times a day across `git`, `gh`, CI checks, PR workflows, branch management.

## The Solution

Type `ghh`. Search for what you're thinking. Hit enter. Or skip a step: `ghh squash` opens the menu already filtered.

`ghh` puts **120+ git and GitHub CLI commands** into a single, searchable, fzf-powered menu. No memorization. No context switching. One command to rule them all.

It also includes `gc` — an interactive conventional commit builder that walks you through type, scope, and message with zero friction.

---

## Features

- **120+ commands** in one searchable menu — git, gh, PRs, CI, issues, branches, worktrees, tags, releases, stashes, diffs
- **Pre-filter from the command line** — `ghh squash`, `ghh undo`, `ghh worktree`
- **Your shell history works** — every command ghh runs lands in history as the resolved command, so the up arrow recalls `git switch hotfix-2`, not a mystery
- **Risk tiers** — read-only commands run instantly, mutating ones confirm, destructive ones require typing `yes`
- **Preview panes** — branch pickers show the log, stash pickers show the diff, cherry-pick shows the patch, staging shows per-file diffs
- **Diff builder** — pick what vs what (branch, tag, commit, staged, working tree) and the format; ghh composes the command
- **Fill-in-the-blank pickers** — `<branch>`, `<commit>`, `<file>`, `<tag>`, `<pr>` placeholders open fuzzy pickers; text ones prompt before anything runs
- **RECENT section** — your most-used commands float to the top of the menu
- **Custom commands** — add your own to `~/.config/ghh/commands.local`
- **Interactive conventional commits** via `gc` — pick type, add scope, write message, confirm
- **Drill into CI checks** — pick a failing check and open it directly in your browser
- **Cross-platform** — macOS, Linux, and WSL with automatic clipboard and browser detection
- **Zero config required** — no setup, no themes. Just commands
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
| "Find who changed this"  | `search`     | Search commits by message, code, or author |
| "Apply that one commit"  | `cherry`     | Pick a commit from the log and cherry-pick |
| "I lost a commit"        | `reflog`     | Browse reflog, recover via cherry-pick or checkout |
| "Tag a release"          | `tag`        | Create, delete, or list tags              |
| "Open in browser"        | `web`        | Opens PR/repo/issue in your browser       |

Every command carries a risk tier, shown in the preview pane before you commit to it:

| Tier | Meaning | What happens on enter |
| ---- | ------- | --------------------- |
| `RO`   | read-only   | runs instantly, no prompt |
| `MUT`  | mutating    | shows the command, asks **Run it? [Y/n/copy]** |
| `DGR`  | destructive | requires typing `yes` — plain enter cancels |
| `PICK` | guided      | opens a follow-up picker or prompt |

Whatever ghh runs is also pushed into your shell history, so the up arrow gives you the exact command to tweak and rerun.

### `gc` — Interactive Conventional Commit

```
$ gc
```

1. Shows you what's staged (and refuses immediately if nothing is)
2. Pick commit type (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert)
3. Optionally add a scope
4. Type your message, preview, confirm

Produces: `feat(auth): add OAuth2 login flow` — and puts that exact `git commit -m ...` in your shell history.

**Note:** `gc` does not stage files. Run `git add` first (or `ghh stage` to pick files with diffs).

### Custom commands

Add your own entries — same format as the built-in menu:

```bash
mkdir -p ~/.config/ghh
echo 'terraform fmt -recursive @@ format all terraform' >> ~/.config/ghh/commands.local
```

They show up under a CUSTOM section, searchable like everything else. Pick log and query history live in `~/.local/state/ghh/` — delete it to reset the RECENT section.

---

## Commands Reference

| Section              | What's in it                                                        |
| -------------------- | ------------------------------------------------------------------- |
| **Stage & Commit**   | `git add`, interactive staging, stash, stash pop, stash picker, `gc` |
| **Diff & Review**    | Diffs, log, graph, blame, commit search (message/code/author), cherry-pick, reflog recovery |
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
| **Tags & Releases** | List/create/delete tags, list/create/view releases                   |

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
