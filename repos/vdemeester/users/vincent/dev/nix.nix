{ pkgs, ... }:

{
  home.packages = with pkgs; [
    niv
    nixpkgs-fmt
    nix-update
  ];
  xdg.configFile."nr/dev.nix" = {
    text = builtins.toJSON [
      { cmd = "nix-review"; }
      { cmd = "nix-prefetch-git"; pkg = "nix-prefetch-scripts"; }
      { cmd = "nix-prefetch-hg"; pkg = "nix-prefetch-scripts"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr dev.nix";
  };
}
