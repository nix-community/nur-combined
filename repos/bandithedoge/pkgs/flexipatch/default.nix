{
  pkgs,
  sources,
  ...
}: let
  callPackage' = pkg: pkgs.callPackage pkg {inherit pkgs sources;};
in {
  dmenu = callPackage' ./dmenu.nix;
  dwm = callPackage' ./dwm.nix;
  slock = callPackage' ./slock.nix;
  st = callPackage' ./st.nix;
}
