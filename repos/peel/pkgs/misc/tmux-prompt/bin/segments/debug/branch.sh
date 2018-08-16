
run_segment() {
  local length=20
  local branch="author/feature_branch_name"

  if [ $TMUX_PANE_WIDTH -lt 90 ]; then
    length=15
  fi

  echo "${branch:0:length}"
}
