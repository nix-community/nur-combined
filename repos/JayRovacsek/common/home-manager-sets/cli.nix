{ self }:
let inherit (self.common) home-manager-modules;
in with home-manager-modules; [
  alacritty
  bat
  dircolours
  direnv
  fzf
  git
  jq
  lsd
  man
  starship
  zsh
]
