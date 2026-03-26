Resolve all merge conflicts in the working tree.

1. Run `git status` to identify all conflicted files.
2. For each conflicted file:
   - Read the file and understand the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
   - Determine the correct resolution by understanding both sides of the conflict.
   - Edit the file to remove conflict markers and apply the correct resolution.
   - Stage the resolved file with `git add`.
3. After all conflicts are resolved, run `git status` to confirm no conflicts remain.
4. If in the middle of a rebase, run `git rebase --continue`. If in the middle of a merge, run `git merge --continue`.
