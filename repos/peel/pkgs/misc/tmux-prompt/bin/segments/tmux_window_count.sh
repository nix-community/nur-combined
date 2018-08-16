run_segment() {
  tmux display-message -p "❐ #{window_index}:#{session_windows}"
  return 0
}
