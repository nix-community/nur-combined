{pkgs ? import <nixpkgs> {}}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};

  callPackage' = pkg: pkgs.callPackage pkg {inherit pkgs sources;};
in {
  vimPlugins = (pkgs.callPackage ./vimPlugins {inherit pkgs;}).extend (import ./vimPlugins/overrides.nix {inherit pkgs;});

  haskellPackages = pkgs.lib.recurseIntoAttrs (callPackage' ./haskellPackages);

  nodePackages = pkgs.lib.recurseIntoAttrs (callPackage' ./nodePackages);

  luaPackages = pkgs.lib.recurseIntoAttrs (callPackage' ./luaPackages);

  firefoxAddons = pkgs.lib.recurseIntoAttrs (callPackage' ./firefoxAddons);

  dmenu-flexipatch = callPackage' ./flexipatch/dmenu.nix;
  dwm-flexipatch = callPackage' ./flexipatch/dwm.nix;
  slock-flexipatch = callPackage' ./flexipatch/slock.nix;
  st-flexipatch = callPackage' ./flexipatch/st.nix;

  kiwmi = callPackage' ./kiwmi.nix;

  luakit = callPackage' ./luakit.nix;

  zrythm = callPackage' ./zrythm.nix;

  lv2vst = callPackage' ./lv2vst.nix;

  raze = callPackage' ./raze.nix;

  cardinal = callPackage' ./cardinal.nix;

  keepmenu = callPackage' ./keepmenu.nix;
}
