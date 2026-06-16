## ZSH Configuration for Generic Linux
## Manual plugin loading and PATH configuration

# Source common configuration (keybindings, history, aliases)
source "$HOME/Configs/zsh/common.zshrc"

## Development Tools
# NodeJS - NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export NODE_OPTIONS="--max-old-space-size=8192"

# .NET - DNVM
if [ -f "$HOME/.local/share/dnvm/env" ]; then
    . "$HOME/.local/share/dnvm/env"
fi
export PATH="$PATH:$HOME/.local/share/dnvm/dn"

# Android
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

## Plugins (manual loading - adjust paths as needed)
# zsh-autosuggestions
[ -f "$HOME/Configs/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$HOME/Configs/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting
[ -f "$HOME/Configs/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$HOME/Configs/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# zaw
[ -f "$HOME/Configs/zsh/zaw/zaw.zsh" ] && \
  source "$HOME/Configs/zsh/zaw/zaw.zsh"

## Plugin Keybindings
bindkey '^ ' autosuggest-accept    # Accept autosuggestion
bindkey '^r' zaw-history            # Zaw history search

## Startup
# Starship
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Fastfetch
if command -v fastfetch &>/dev/null && [[ "$LINES" -gt 20 ]]; then
  fastfetch --config "$HOME/Configs/fastfetch/mini-config.jsonc"
fi
