((magit-commit "--signoff" "--gpg-sign=B7E7CF1C634256FA")
 (magit-fetch "--prune")
 (magit-rebase "--autostash" "--gpg-sign=B7E7CF1C634256FA")
 (magit-submodule "--recursive" "--rebase" "--remote"))
