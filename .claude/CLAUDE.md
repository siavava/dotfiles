# Git identity

Two GitHub accounts share this machine:

- `siavava` <amittaijoel@outlook.com> is the default identity. All ordinary work, every
  commit the user authored or asked for by hand, goes out under it with the usual GPG
  signature.
- `evilalt` <amittaijoel@gmail.com> is the utility identity for automated changes:
  dependency bumps, fixes pushed to Dependabot branches, lockfile or generated-file
  refreshes, and anything a bot or a scheduled job would otherwise have done.

Commit automated changes with `git alt commit …` (the global alias injects the evilalt
name and email for that one command; it changes no state). Those commits are
unsigned by design; do not try to sign them or add a key for that account. Never change `user.name` or
`user.email` to flip between them. When squash-merging a bot's pull request, pass
`--body "Co-authored-by: evilalt <amittaijoel@gmail.com>"` so the utility account is
credited on the merge commit. This rule applies in every repository.
