## ZSH Configuration for NixOS
## Environment variables, plugins, and startup are managed by Home Manager

# Source common configuration (keybindings, history, aliases)
source "$HOME/Configs/zsh/common.zshrc"

## Plugins (Managed by Home Manager)
# - zsh-autosuggestions
# - zsh-syntax-highlighting
# - zaw
# - Starship
# - Zoxide
# These are loaded via Home Manager programs.zsh.enable and related options

## Plugin Keybindings
bindkey '^ ' autosuggest-accept    # Accept autosuggestion
bindkey '^r' zaw-history            # Zaw history search

## Startup
# Fastfetch (configured via Home Manager if desired)
if [[ "$LINES" -gt 20 ]]; then
  fastfetch --config "$HOME/Configs/fastfetch/mini-config.jsonc"
fi
