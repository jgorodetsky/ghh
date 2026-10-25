#!/usr/bin/env bash
# search.sh - can you find each command by typing what you want?
# runs ghh's real menu through fzf with the same options ghh uses, and checks
# each query lands its command within the expected rank.
#   tests/search.sh                 run the cases
#   tests/search.sh --no-exact      same cases, extra fzf options appended (to compare)
set -u
cd "$(dirname "$0")/.."

# shellcheck source=../bin/ghh
source bin/ghh
rows=$(_ghh_menu main | _ghh_rows /dev/null 100)

# the same rows come out of zsh, which is where most people run ghh
if command -v zsh >/dev/null; then
  zrows=$(zsh -c 'source bin/ghh; _ghh_menu main | _ghh_rows /dev/null 100')
  [[ "$rows" == "$zrows" ]] || { echo "FAIL rows differ between bash and zsh"; exit 1; }
fi

pass=0 fail=0
while IFS=$'\t' read -r query want max; do
  [[ -z "$query" || "$query" == \#* ]] && continue
  got=$(printf '%s\n' "$rows" | fzf --filter="$query" "${GHH_FZF_MATCH[@]}" "$@" | cut -f2)
  rank=$(printf '%s\n' "$got" | grep -nxF -- "$want" | head -1 | cut -d: -f1)
  if [[ -n "$rank" && "$rank" -le "$max" ]]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL %-22s want %-40s got #%s, top: %s\n' "'$query'" "$want" "${rank:--}" "$(printf '%s' "$got" | head -1)"
  fi
done <<'EOF'
# query	expected command	must rank at or above (more than 1 when other
# results are just as right, like 'staged' also finding git restore --staged)
repo view web	gh repo view --web	1
open repo	gh repo view --web	1
open repo in browser	gh repo view --web	1
pr view web	gh pr view --web	1
open pr in browser	gh pr view --web	1
rebase -i	REBASE_N	1
interactive rebase	REBASE_N	1
squash	SQUASH_N	3
unstage	git restore --staged <file>	2
new branch	git switch -c <name>	1
create branch	git switch -c <name>	1
rename branch	git branch -m <name>	1
switch branch	CHECKOUT_BRANCH	1
delete branch	DELETE_BRANCH	1
force push	git push --force-with-lease	1
--force	git push --force-with-lease	1
push	git push	3
pull	git pull --rebase	2
fetch	git fetch --prune	1
staged	git diff --staged	3
diff main	git diff main...HEAD	1
pr diff	gh pr diff	2
blame	BLAME_FILE	1
stash	git stash	3
pop	git stash pop	1
amend	git commit --amend --no-edit	2
undo commit	git reset HEAD~1 --soft	2
revert	git revert <commit>	1
cherry	CHERRY_PICK	1
reflog	REFLOG_RECOVER	1
checks	gh pr checks	2
ci status	gh pr checks	1
failed logs	gh run view --log-failed	1
rerun failed	gh run rerun --failed	1
merge pr	gh pr merge --squash	3
approve	gh pr review --approve	1
my prs	gh pr list --author @me	1
review requested	gh pr list --search review-requested:@me	1
needing my review	gh pr list --search review-requested:@me	1
my issues	gh issue list --assignee @me	1
clone	gh repo clone <owner/repo>	1
fork	gh repo fork	1
release	gh release list	2
tag	git tag	2
worktree add	WORKTREE_ADD	1
conventional commit	gc	1
commit	git commit -m <message>	3
log	git log --oneline -15	3
graph	git log --oneline --graph -20	2
status	git status	2
not pushed	git log --oneline @{u}..HEAD	1
unpushed	git log --oneline @{u}..HEAD	1
open file on github	gh browse <file>	1
notifications	gh api notifications	1
logged in	gh auth status	1
discard	git checkout -- .	3
untracked	git clean -nd	2
workflow run	gh workflow run <workflow>	2
gh run watch	gh run watch	1
EOF

echo "search: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
