{ config
, lib
, pkgs
, ...
}: {
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    plugins = {
      mappings = {
        v = "imgview";
      };
    };
  };
}
