run_segment() {
   tmux_path=$(get_tmux_cwd)
   cd "$tmux_path"
   echo $(rbenv version-name)
}
