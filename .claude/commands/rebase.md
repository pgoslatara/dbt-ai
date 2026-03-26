Rebase the current branch onto `main`.

1. Run `git fetch origin` to get the latest remote state.
2. Run `git rebase origin/main`.
3. If conflicts arise, resolve each one:
   - Read the conflicting files and understand both sides.
   - Choose the correct resolution (prefer the intent of the current branch's changes on top of the latest main).
   - Stage the resolved files with `git add`.
   - Continue with `git rebase --continue`.
4. Repeat until the rebase completes cleanly.
5. Run `git log --oneline -5` to confirm the history looks correct.
