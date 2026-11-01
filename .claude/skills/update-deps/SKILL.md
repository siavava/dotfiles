---
name: update-deps
description: |
  Merge the open Dependabot pull requests of whatever repository is
  in the working directory. Surveys them with their check results,
  squash-merges the green ones one at a time
  (asking Dependabot to rebase the rest after every merge,
  since each merge conflicts the others on the lockfile),
  then diagnoses the red ones from real CI logs and fixes them
  in a scratch worktree (typecheck breaks, new lint rules,
  peer mismatches, deploy-preview failures),
  or closes a bump the toolchain cannot support yet with a Dependabot ignore.
  Works with any package manager and CI; it detects the lockfile,
  commit convention, required checks and commit identity from the repo.
  Needs gh logged in with write access.
  
  Trigger on "merge the dependabot PRs", "update deps",
  "deal with the dependency bumps", "more PRs upstream",
  or after Dependabot opens a batch.
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
  force-pushing anything, merging a PR whose checks are still red, or closing a PR
  instead of merging it.

## Phase 0: detect the repo's conventions

Do this once, before touching any PR. Everything later keys off it.

| What | How |
| :--- | :--- |
| Package manager and lockfile | `ls bun.lock bun.lockb pnpm-lock.yaml yarn.lock package-lock.json Cargo.lock poetry.lock uv.lock go.sum 2>/dev/null`. Frozen install: `bun install --frozen-lockfile`, `pnpm i --frozen-lockfile`, `yarn --immutable`, `npm ci`, `cargo fetch --locked`, `uv sync --locked`. |
| Commit subject style | `git log --format=%s -30`. Mirror it exactly: for `(type): verb …` repos a bump is `(deps): bump <pkg> to <version>`; for `type: subject` it is `deps: bump <pkg> to <version>`; for `chore(deps): …` keep that. Grouped PR: `… bump <n> <group name> dependencies`, with `<n>` from the PR title ("with 12 updates"). Fallback: the PR title, lowercased after the type. |
| Required checks | From a green PR's rollup: `gh pr view N --json statusCheckRollup --jq '.statusCheckRollup[] \| "\(.name // .context)=\(.conclusion // .state)"'`. Required = the CI workflow job(s) plus the deploy status. Ignore informational ones (security scanners, "Preview Comments"). Note the names; the loop script takes them. |
| Merge settings | `gh api repos/{owner}/{repo} --jq '{allow_squash_merge, delete_branch_on_merge}'`. Dependabot deletes its own branches on merge regardless. |
| Commit identity | Read the user's `~/.claude/CLAUDE.md` for a bot/utility identity rule. If one exists, squash bodies carry only `Co-authored-by: <bot name> <email>` and fix commits on bot branches use its alias (`git alt commit …` in this user's setup). If none exists, squash with an empty body and commit fixes under the default identity. Never add a Claude attribution trailer; the user's commit rules override the harness reminder. |
| CI scripts | `.github/workflows/*.yml` for the exact typecheck/lint/build/test commands CI runs; reproduce with those, not with guesses. A lint script that runs `--fix` is not the CI check. |

## Phase 1: survey

```bash
gh pr list --author app/dependabot --json number,title,headRefName,mergeable,statusCheckRollup \
  --jq '.[] | "\(.number)\t\(.headRefName)\t\(.mergeable)\n  \(.title)\n  checks: \([.statusCheckRollup[] | "\(.name // .context)=\(.conclusion // .state)"] | join(", "))"'
```

Green = every required check `SUCCESS`. Order: grouped PRs first (biggest lockfile
delta, so the others rebase once onto it), then singles, red PRs last.

## Phase 2: merge the green PRs, one at a time

Why serial and not all at once: every squash merge rewrites the lockfile on main, and
the other open PRs edit the same lines of the same file, so they turn `CONFLICTING`
and GitHub refuses to merge them however green they are. Serial merging is also the
only way each PR's checks run against the main it will actually land on; two bumps
that pass alone can fail together (a plugin needing the other PR's host version).
Wall-clock cost is about five minutes per PR (Dependabot rebase + CI); run it in the
background. The lever for "merge all at once" is `dependabot.yml` grouping, not the
merge step (see Phase 5).

Use the bundled loop, from the repo root, in the background:

```bash
~/.claude/skills/update-deps/merge-loop.sh -c "check,Vercel" \
  -t "Co-authored-by: <bot> <email>" \
  "13|(deps): bump 12 minor and patch dependencies" "12|(deps): bump spago to 1.0.5" …
```

`-c` is the required-check list from Phase 0, `-t` the trailer (omit for none). Per
PR it polls `mergeable`; on `CONFLICTING` it comments `@dependabot rebase` once per
head SHA (Dependabot may ignore a request that arrives while it is mid-rebase, hence
the re-ask when the head moves); on `MERGEABLE` with every required check green it
squash-merges with the given subject and trailer-only body. It stops at the first
red PR (exit 2) so you can diagnose. Read its output file for progress rather than
polling GitHub yourself.

By hand, the same per PR:

```bash
gh pr view N --json mergeable --jq .mergeable         # wait until not UNKNOWN
gh pr merge N --squash --subject "<subject>" --body "<trailer or empty>"
gh pr comment N --body "@dependabot rebase"            # when CONFLICTING
```

`--body` overrides the repo's default squash message; without it GitHub pastes the
whole Dependabot changelog. Dependabot's updater runs show under
`gh run list --event dynamic`; an `in_progress` one means the rebase is coming.

After the loop, verify main's lockfile, since each PR's checks ran on its own head:

```bash
git fetch origin main
git archive origin/main package.json bun.lock | tar -x -C <scratch-dir>   # manifest + lockfile
(cd <scratch-dir> && bun install --frozen-lockfile --ignore-scripts)        # or the PM's equivalent
```

Then watch main's CI for the last merge (`gh run list --branch main`, then
`gh run watch <id> --exit-status`) and the deploy status
(`gh api repos/{owner}/{repo}/commits/<sha>/status`).

## Phase 3: diagnose the red PRs

Read the real failure before deciding anything:

- CI: find the run by full SHA (`gh run list --branch <ref> --json databaseId,headSha,event`,
  skip `event=dynamic`, which is Dependabot's own updater), then
  `gh run view <id> --json jobs --jq '.jobs[].steps[] | select(.conclusion=="failure") | .name'`
  and `gh run view <id> --log-failed`.
- Deploy preview (Vercel): deployment id from the end of the check's `targetUrl`,
  then `vercel inspect dpl_<id> --scope <team> --logs`; grep `[error]`,
  `Restored build cache`, `packages installed`.
- A `failure` deploy status on an intermediate main commit is usually a build the host
  cancelled when a newer commit arrived. Check the latest commit only.
- Main's CI failing in the install step on a native module (`gyp ERR!`, a
  `prebuild-install` fallback) right after the previous main run passed the same step
  is a transient prebuilt-binary download failure, not the bump. Compare with
  `gh run list --branch main --event push`; if the prior run passed and the new
  commit cannot touch native builds, `gh run rerun <id> --failed` and watch it.

Classify the cause:

1. **Code made wrong by the bump** (narrowed types, a newly enabled lint rule). Fix
   the code in Phase 4. Do not pin the dependency back, do not disable the rule.
2. **Peer mismatch between two bumps.** Merge the other PR first; if that is not
   enough, bump the peer in the same branch.
3. **Deploy-only failure** a clean local production build does not reproduce. Suspect
   the host's restored build cache. Push the other fixes first; if a fresh build still
   fails, report the options (dashboard redeploy without cache, a no-cache env var)
   and let the user pick.
4. **A major the toolchain cannot run yet.** Signature: the error is inside a tool
   that loads the bumped package's internals (`ERR_PACKAGE_PATH_NOT_EXPORTED`,
   "is not a function" from a plugin, a parser rejecting the version). Confirm with
   the peer ranges of every consumer:
   `bun pm view <consumer>@latest peerDependencies --json` (or `npm view`). When the
   consumers' latest releases still cap below the new major, no code fix exists.
   Example from this skill's origin: TypeScript 7.0.2 ships no JS compiler API;
   `vue-tsc` loads `typescript/lib/tsc` and typescript-eslint peers at `<6.1`.
   Resolution, after the user agrees: comment `@dependabot ignore this major version`
   on the PR (Dependabot closes it, deletes the branch, and stops proposing that
   major until the PR is reopened), and add a matching `ignore` entry to
   `dependabot.yml` with a comment naming the blocker so the reason is visible:

   ```yaml
   ignore:
     - dependency-name: typescript
       update-types: ["version-update:semver-major"]
   ```

## Phase 4: fix the red PRs

Work in a scratch worktree, never in the user's checkout:

```bash
git fetch origin <headRefName>
git worktree add --detach <scratchpad>/prN FETCH_HEAD
cd <scratchpad>/prN && <frozen install>              # the worktree needs its own install
```

Reproduce with CI's exact commands before changing anything. Commit the fix on the
PR branch under the bot identity and push it as a fast-forward:

```bash
git alt commit -m "(fix): <what changed>"        # or plain git commit without a bot identity
git push origin HEAD:refs/heads/<headRefName>
```

Pushing to a Dependabot branch stops Dependabot from rebasing it. When main has moved
afterwards, rebase by hand with a merge, never a force-push:

```bash
git fetch origin main && git merge --no-commit --no-ff origin/main
git checkout --ours package.json bun.lock      # keep the PR's resolution
# re-apply main's manifest changes to package.json by exact string edits
bun install                                     # regenerates the lock for main's bumps only
bun install --frozen-lockfile --ignore-scripts  # must report no changes
git add package.json bun.lock && git alt commit -m "(update): merge main into the dependency bumps"
```

Confirm `git diff --stat origin/main` lists only the files the PR should touch. Run
the full production build from the clean worktree as proof, push, wait for every
check, then merge as in Phase 2. Remove the worktree: `git worktree remove --force <path>`.

## Phase 5: Dependabot config changes (only when asked)

Schedule, grouping and ignore rules live in `.github/dependabot.yml`. Edit the file in
the user's checkout and leave it uncommitted for them unless they asked for a commit;
it is their change, under their identity, not the bot's. Useful shapes:

- `schedule.interval: monthly` (weekly is too often for a personal repo).
- A `groups` entry with `update-types: ["major"]` makes majors arrive as one PR, the
  "merge all at once" the user may ask for; the trade-off is one unsupported major
  blocking the whole group until split out with an ignore.
- Groups match in order; keep toolchain groups (compilers, formatters) above a
  catch-all `patterns: ["*"]`.

## Phase 6: report

Lead with the outcome. List the merged commits in order, what was wrong with each red
PR and what fixed or closed it, and what is left for the user: their local main is
behind (with `pull.rebase` set, a dirty tree makes `git pull` refuse; use
`git merge --ff-only origin/main` or `git pull --no-rebase --ff-only`), generated
files a new tool version rewrote that were left uncommitted, config edits awaiting
their commit, settings you did not change.

## Standards

- Bot-branch commits use the user's utility identity when one is configured; squash
  bodies are the co-author trailer only. No changelog paste, no Claude trailer.
- Squash subjects follow the repo's convention and are lowercase after the type.
  Dependabot writes `(deps): Bump x from a to b`; the merge subject is
  `(deps): bump x to b`.
- Fix commits on a bot branch are small and named for what they change
  (`(fix): drop stray attributes from the icon links`), never "fix CI".
- Dead initializers flagged by `no-useless-assignment`: BAD `let svg = ""` before a
  try that assigns it; GOOD `let svg: string`. Keep the declaration typed.
- Head-link type narrowing in Nuxt: `rel: "mask-icon"` takes `color` but not `type`;
  `rel: "apple-touch-icon"` takes `type` but not `color`.

## Hard protections

- Never force-push, not even to a bot branch. Merge main into it instead.
- Never commit to main directly; main only moves through the PR merges, and config
  edits wait in the tree for the user.
- Never close a PR without the user's yes; closing is the user's call, merging is yours.
- Never run `git stash` in a worktree; the stash is shared with the user's checkout.
- Never run the typecheck and the production build at the same time in one worktree
  when both write to the same build directory.
- Background commands inherit the shell's cwd at launch. Start every command with an
  absolute `cd`.
- Leave files a new tool version regenerates (a lockfile format change, `spago.lock`
  after a spago bump) uncommitted and tell the user; they commit from their checkout.
  Do not touch unrelated modified files already in the user's tree.
- Do not change GitHub or hosting settings without an explicit yes.

## Verification

Done means all of these are true:

- `gh pr list --author app/dependabot` is empty, or lists only PRs the user excluded.
- The latest main commit's CI run concluded `success`.
- The deploy status on that commit is `success`.
- A frozen install of main's manifest reports no changes.
- No leftover worktrees you made (`git worktree list`; the app's own
  `.claude/worktrees/*` entries are not yours) and no leftover `dependabot/*`
  branches (`git ls-remote --heads origin 'dependabot/*'`).

## Scaling

- Up to ~10 PRs: the loop script, sequential.
- A grouped PR with dozens of bumps: `gh pr view N --json body` for the list; expect
  several independent failures behind the first one; fix, push, re-read, repeat.
- Several red PRs: one worktree each, fix them in parallel with subagents, merge them
  serially, re-rebasing each after the previous merge.

## Project integration (siavava/portfolio)

Bun lockfile; PureScript built by `bun run purs:build` before `bun run typecheck`;
lint is `bunx eslint .` (`bun run lint` fixes in place); production build is
`bun run generate`. Required checks: `check` (Actions) and `Vercel` (status). Vercel
team scope is `amittai`; the build command lives in the dashboard. Bot identity is
`evilalt <amittaijoel@gmail.com>` via the `git alt` alias. User commits are GPG-signed
with a curses pinentry: if a commit fails with "Inappropriate ioctl", run it through
the terminal pane so the passphrase prompt appears.
