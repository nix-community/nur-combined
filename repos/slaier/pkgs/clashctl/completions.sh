generateCompletions() {
  export HOME=$(mktemp -d)
  mkdir -p "$out/share/"{bash-completion/completions,fish/vendor_completions.d,zsh/site-functions}
  $out/bin/clashctl completion bash > $out/share/bash-completion/completions/clashctl
  $out/bin/clashctl completion fish > $out/share/fish/vendor_completions.d/clashctl.fish
  $out/bin/clashctl completion zsh > $out/share/zsh/site-functions/_clashctl
}

postFixupHooks+=(generateCompletions)
