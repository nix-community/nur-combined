## ZSH Configuration for NixOS
## Environment variables, plugins, and startup are managed by Home Manager

# Home Manager session variables (home.sessionPath / home.sessionVariables).
# The .zshrc symlink bypasses Home Manager's own zsh integration, so PATH
# entries declared in Nix modules only reach the shell from here.
if [[ -f /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ]]; then
  source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
fi

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
