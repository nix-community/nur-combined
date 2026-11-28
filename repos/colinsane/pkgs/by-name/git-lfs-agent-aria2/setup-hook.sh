gitLfsAria2Setup() {
  git config --global lfs.standalonetransferagent aria2
  git config --global lfs.customtransfer.aria2.path @out@/bin/git-lfs-agent-aria2
  git config --global lfs.customtransfer.aria2.direction download

  # Git LFS captures the agent's stderr for tracing, so follow a separate
  # progress log for the lifetime of the fetchgit builder.
  GIT_LFS_ARIA2_LOG=$(mktemp -t git-lfs-aria2.XXXXXX)
  export GIT_LFS_ARIA2_LOG
  tail --pid="$$" -n +1 -f "$GIT_LFS_ARIA2_LOG" >&2 &
}

preFetchHooks+=(gitLfsAria2Setup)
