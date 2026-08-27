# shellcheck shell=bash
export LANG=en_US.UTF-8
key_flags=()
[[ -f "$HOME/Secrets/nvfetcher.toml" ]] && key_flags+=(-k "$HOME/Secrets/nvfetcher.toml")
[[ -f secrets.toml ]] && key_flags+=(-k secrets.toml)

nvfetcher "${key_flags[@]}" -c nvfetcher.toml -o _sources "$@"
