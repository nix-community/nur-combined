{
  lib,
  pkgs,
  ...
}:
lib.git-hooks.${pkgs.system}.run {
  src = ../..;
  hooks = {
    alejandra.enable = true;
  };
}
