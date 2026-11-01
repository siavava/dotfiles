---
name: sm
description: Squash-merge the open pull requests of the repository in the working directory. Each merge waits until every check on that pull request's head commit has finished green, and is pinned to that commit. They merge one at a time; after each, the next is rebased onto the moved base and waits for its new CI. Then it reports the base branch's run and bumps the merged repo in any parent repository that has it as a submodule. Works in any repo with gh. Trigger on "/sm", "squash-merge", "merge the open PRs once green", "merge when green".
---

# Squash-merge

## Inputs

- `gh` signed in with merge rights.
- The pull requests to merge: the numbers the user names, or else every open
  pull request by the user (`--author @me`). Merge a bot's pull request only
  when the user names it.

## Rules

- Never use `gh pr merge --auto`, a merge queue, or merge-when-ready.
- Merge only when every check on the head commit has completed as `SUCCESS`,
  `SKIPPED` or `NEUTRAL`.
  - While a check is pending, wait.
  - When one fails, read its log, then fix the cause or report it.
  - Rerun a check once only when its log shows a flake, and say so.
- Always pass `--match-head-commit <sha>` with the sha the checks ran on.
- Merge one pull request at a time.
- Give every wait a deadline.
- Follow the user's CLAUDE.md for identity, signing, bot trailers and
  attribution.

## Steps

### 1. Survey

```bash
gh pr list --state open --author @me \
  --json number,title,headRefName,headRefOid,baseRefName,mergeStateStatus
gh pr checks <n>
gh api repos/{owner}/{repo} --jq '{allow_squash_merge, delete_branch_on_merge}'
```

Order the merges:

1. A pull request based on another one's branch: merge the other one first,
   then retarget this one to the real base.
2. Pull requests that are already green go first.
3. Otherwise, oldest first.

### 2. Prepare

- Check that the body still matches the diff.
- If the body promises results "once CI finishes", fill them in now
  (`gh pr edit <n> --body-file`).

### 3. Merge

```bash
gh pr merge <n> --squash --match-head-commit <sha> --subject "<title> (#<n>)"
gh pr view <n> --json state,mergeCommit --jq '.state + " " + .mergeCommit.oid'
```

- **Your own pull request:** keep GitHub's default squash body.
- **A bot's:** pass `--body` with only the trailer the user's rules require.
- **The branch:** delete it only where the repo deletes branches on merge.
- **Check:** confirm the state is `MERGED`, and record the merge sha.

### 4. Catch up the next pull request

Read `mergeStateStatus`, polling with a deadline while it is `UNKNOWN`.
Rebase when it is `BEHIND` or `CONFLICTING`, or when the merge changed the CI
workflow files:

1. In a worktree of the branch: `git fetch origin <base>`, then
   `git rebase origin/<base>`.
2. Generated files (lockfiles, inventories, snapshots, codegen): regenerate
   them with the repo's own command. Never hand-merge them.
3. Resolve mechanical conflicts. When resolving one means deciding what the
   code should do, ask.
4. Run the repo's local lint, typecheck or fast tests. Confirm that commits
   that were signed still are (`git log --format=%G?`).
5. Push with `git push --force-with-lease`, only to a branch the user owns.
   For someone else's branch, ask first. For a bot's, ask the bot to rebase
   (`@dependabot rebase`).
6. Wait for the checks (step 5), then return to step 2.

### 5. Wait

Run this in the background, and act when it exits:

```bash
timeout 45m gh pr checks <n> --watch --interval 30
```

If it times out, report the checks that are still pending.

### 6. Finish

- **Base run:** report the result of the base branch's push run for the last
  merge (`gh run list --branch <base> --limit 5`). A run that skips because the
  same tree already passed counts as passing.
- **Parent repos:** a parent repo is one whose `.gitmodules` points at this
  repo's remote (`grep -l <repo> ../*/.gitmodules ../.gitmodules`). For each:
  1. Inside the submodule, fetch `origin <base>` and check out the merge sha.
  2. Make one commit that covers every repo merged in this run, in the
     parent's commit style, naming each repo and its short sha.
  3. Land it the way that parent lands changes, by pull request or by a direct
     push. If the push deploys and the user didn't ask for the bump, say so
     first.
  4. Report the parent's run or deploy.
- **Cleanup:** stop every watch you started. Offer to remove the merged
  branches' worktrees.

### 7. Report

For each pull request:

- the merge sha;
- what it needed before merging (a rebase, regenerated files, a body edit);
- the result of the base run;
- the parent bump's sha and its run.

List anything left unmerged, with the reason.
