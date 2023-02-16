{ inputs, ... }:

let
  inherit (inputs) dotfiles;

in {
  home.file.".config/bashblog".source = "${dotfiles}/config/bashblog";
}
