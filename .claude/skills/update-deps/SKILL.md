---
name: update-deps
description: Merge the open Dependabot pull requests of the current repository. Lists them with their check results, squash-merges the green ones one at a time with a lowercase subject in the repo's commit convention and an evilalt co-author trailer, then reproduces and fixes the red ones in a scratch worktree (typecheck breaks, new lint rules, lockfile conflicts, deploy-preview failures), rebases them by hand against the moved main, and merges them once every check is green. Needs gh logged in with write access to the repo. Trigger on "merge the dependabot PRs", "update deps", "deal with the dependency bumps", or after Dependabot opens a batch.
---

# Update dependencies

Merge every open Dependabot PR, fixing the ones that fail. Green PRs first, red PRs
last, so a red PR is rebased once, after main has stopped moving.

## Inputs

- The repo in the working directory, with `gh` authenticated to an account that can
  merge. Confirm with `gh auth status`.
- Optional: a list of PR numbers to limit the scope. Default is every open PR by
  `app/dependabot`.
- Ask the user before: changing any repo or hosting setting, enabling auto-merge,
  force-pushing anything, or merging a PR whose checks are still red.

## Method

### Phase 0: survey

```bash
gh pr list --author app/dependabot --json number,title,headRefName,statusCheckRollup \
  --jq '.[] | "\(.number)\t\(.headRefName)\n  \(.title)\n  checks: \([.statusCheckRollup[] | "\(.name // .context)=\(.conclusion // .state)"] | join(", "))"'
```

Classify each PR as green (every check `SUCCESS`) or red. Read the repo's commit
convention from `git log --format=%s -30` and derive the squash subject style from it
(for `(type): verb …` repos, `(deps): bump <pkg> to <version>`; for a grouped PR,
`(deps): bump <n> <group> dependencies`). Fall back to the PR title, lowercased.

Also note the repo's merge settings (`gh api repos/{owner}/{repo} --jq '{allow_squash_merge, delete_branch_on_merge}'`).

### Phase 1: merge the green PRs, one at a time

Every merge moves main, so GitHub recomputes the other PRs' mergeability. Loop:

1. Poll `gh pr view N --json mergeable --jq .mergeable` until it is not `UNKNOWN`.
2. If `MERGEABLE`, merge:
   ```bash
   gh pr merge N --squash --subject "<subject>" --body "Co-authored-by: evilalt <amittaijoel@gmail.com>"
   ```
3. If `CONFLICTING`, comment `@dependabot rebase` on it, move on, and come back when
   Dependabot has pushed and the checks are green again.

The `--body` overrides the repo's default squash message (otherwise GitHub pastes the
whole Dependabot changelog). Keep it to the trailer only.

After the loop, verify main's lockfile is still consistent, since each PR's checks ran
on its own head, not on the merge result:

```bash
git fetch origin main
git archive origin/main package.json bun.lock | tar -x -C <scratch-dir>   # or the repo's lockfile
(cd <scratch-dir> && bun install --frozen-lockfile --ignore-scripts)        # npm ci / pnpm i --frozen-lockfile
```

Then watch main's CI run for the last merge (`gh run list --branch main`, then
`gh run watch <id> --exit-status`).

### Phase 2: fix the red PRs

Work in a scratch worktree, never in the user's checkout:

```bash
git fetch origin <headRefName>
git worktree add --detach <scratchpad>/prN FETCH_HEAD
cd <scratchpad>/prN && bun install --frozen-lockfile    # the worktree needs its own install
```

Diagnose from the real logs, not the summary:

- CI: find the run by full SHA (`gh run list --branch <ref> --json databaseId,headSha`;
  the `--commit` filter needs the full SHA, a short one silently matches nothing), then
  `gh run view <id> --json jobs --jq '.jobs[0].steps[] | select(.conclusion=="failure") | .name'`
  and `gh run view <id> --log-failed`.
- Deploy preview (Vercel): take the deployment id from the end of the check's
  `targetUrl` and run `vercel inspect dpl_<id> --scope <team> --logs`. Grep for
  `[error]`, `Restored build cache`, `packages installed`.
- A failing run with event `dynamic` is Dependabot's own updater, not CI. It fails when
  Dependabot cannot rebase a branch someone pushed to. Ignore it.
- A `failure` Vercel status on an intermediate main commit is usually a build that
  Vercel cancelled because a newer commit arrived. Check the latest commit only.

Reproduce locally before changing anything (`bun run typecheck`, `bunx eslint .`, the
production build). Then fix the actual cause, in this order of preference:

1. Code made wrong by the bump (narrowed types, a newly enabled lint rule). Fix the
   code; do not pin the dependency back and do not disable the rule.
2. Peer mismatch between two bumps (one PR's plugin needs the other PR's host
   version). Merging the other PR first usually resolves it; otherwise bump the peer in
   the same branch.
3. Deploy-only failure that a clean local production build does not reproduce. Suspect
   the host's restored build cache. Push the other fixes first; a fresh build often
   restores a newer cache and passes. If it does not, report it with the options
   (dashboard redeploy without cache, or a no-cache env var) and let the user pick.

Commit the fix on the PR branch with the automated identity and push it as a
fast-forward:

```bash
git alt commit -m "(fix): <what changed>"
git push origin HEAD:refs/heads/<headRefName>
```

Pushing to a Dependabot branch stops Dependabot from rebasing it. When main has moved,
rebase by hand with a merge, never a force-push:

```bash
git fetch origin main && git merge --no-commit --no-ff origin/main
git checkout --ours package.json bun.lock      # keep the PR's resolution
# re-apply main's manifest changes to package.json by exact string edits
bun install                                     # regenerates the lock for main's bumps only
bun install --frozen-lockfile --ignore-scripts  # must report no changes
git add package.json bun.lock && git alt commit -m "(update): merge main into the dependency bumps"
```

Confirm `git diff --stat origin/main` lists only the files the PR is supposed to
touch. Run the full production build from the clean worktree as proof the dependency
set works (not just typecheck). Push, wait for every check, then merge as in Phase 1.

Remove the worktree when done: `git worktree remove --force <path>`.

### Phase 3: report

Final message: the merged commits in order, what was wrong with each red PR and what
fixed it, anything left for the user (their local main is behind; generated files a
new tool version rewrites, such as a lockfile format change, left uncommitted for them;
settings you did not change). Lead with the outcome.

## Standards

- Automated commits use the evilalt identity via `git alt`. Regular work never does.
- Squash subjects follow the repo's convention and are lowercase after the type.
  Dependabot writes `(deps): Bump x from a to b`; the merge subject is
  `(deps): bump x to b`.
- Squash body is the co-author trailer only. No changelog paste, no Claude trailer.
- Fix commits on a bot branch are small and named for what they change
  (`(fix): drop stray attributes from the icon links`), never "fix CI".
- Dead initializers flagged by `no-useless-assignment`: BAD `let svg = ""` before a
  try that assigns it; GOOD `let svg: string`. Keep the declaration typed.
- Head-link type narrowing in Nuxt: a `rel: "mask-icon"` entry takes `color` but not
  `type`; `rel: "apple-touch-icon"` takes `type` but not `color`.

## Hard protections

- Never force-push, not even to a bot branch. Merge main into it instead.
- Never commit to main directly; main only moves through the PR merges.
- Never run `git stash` in a worktree; the stash is shared with the user's checkout.
- Never run the typecheck and the production build at the same time in one worktree;
  both rewrite `.nuxt` and the content database.
- Background commands inherit the shell's cwd at launch. Start every command with an
  absolute `cd`, or a watcher started after a `cd` into a scratch dir fails with
  "not a git repository".
- Leave files a new tool version regenerates (for example `spago.lock` after a spago
  major) uncommitted and tell the user; they commit from their own checkout.
- Do not change GitHub or hosting settings (auto-merge, build cache variables,
  install commands) without an explicit yes.

## Verification

Done means all of these are true:

- `gh pr list --author app/dependabot` is empty (or only lists PRs the user excluded).
- The latest main commit's CI run concluded `success`.
- The production deploy status on that commit is `success`
  (`gh api repos/{owner}/{repo}/commits/<sha>/status`).
- A frozen install of main's manifest reports no changes.
- No leftover worktrees (`git worktree list`) and no leftover `dependabot/*` branches
  (`git ls-remote --heads origin 'dependabot/*'`; Dependabot deletes its own on merge).

## Scaling

- Up to ~10 PRs: inline, sequential, as above.
- A grouped PR with dozens of bumps: read `gh pr view N --json body` for the list, and
  expect several independent failures hiding behind the first one; fix, push, re-read
  the next failure, repeat.
- Several red PRs: one worktree each, fix them in parallel with subagents, but merge
  them serially, re-rebasing each after the previous merge.

## Project integration (siavava/portfolio)

Bun lockfile, PureScript built by `bun run purs:build` before `bun run typecheck`,
lint is `bunx eslint .` (not `bun run lint`, which fixes in place), production build
is `bun run generate` (skips the TikZ blob cache without credentials; that is fine).
Vercel team scope is `amittai`, build command lives in the dashboard. Commits are
GPG-signed with a curses pinentry; if a commit fails with "Inappropriate ioctl", run it
through the terminal pane so the passphrase prompt appears. Generic fallbacks: the
package manager's frozen install, the repo's `typecheck`/`lint`/`build` scripts, and
`gh run view --log-failed` for CI.
