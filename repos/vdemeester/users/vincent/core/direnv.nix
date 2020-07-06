{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    stdlib = ''
      mkdir -p $HOME/.cache/direnv/layouts
      pwd_hash=$(echo -n $PWD | shasum | cut -d ' ' -f 1)
      direnv_layout_dir=$HOME/.cache/direnv/layouts/$pwd_hash
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';
  };
}
