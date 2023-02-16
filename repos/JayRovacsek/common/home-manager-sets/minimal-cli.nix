{ self }:
let inherit (self.common) home-manager-modules;
in with home-manager-modules; [ bat direnv fzf jq lsd man starship zsh ]
