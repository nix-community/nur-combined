{ self, lib, ... }:
{
  programs.bash.promptInit = lib.mkBefore (with self.inputs; ''
    export BASE_NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=$NIXCFG_ROOT_PATH/nix/compat/overlay.nix:nur=${nur}
  '');
}
