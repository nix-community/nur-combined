{pkgs ? import <nixpkgs> {}}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};

  callPackage' = pkg: pkgs.callPackage pkg {inherit pkgs sources;};
in {
  vimPlugins = (pkgs.callPackage ./vimPlugins {inherit pkgs;}).extend (import ./vimPlugins/overrides.nix {inherit pkgs;});

  firefoxAddons = pkgs.lib.recurseIntoAttrs (callPackage' ./firefoxAddons);
  haskellPackages = pkgs.lib.recurseIntoAttrs (callPackage' ./haskellPackages);
  luaPackages = pkgs.lib.recurseIntoAttrs (callPackage' ./luaPackages);
  nodePackages = pkgs.lib.recurseIntoAttrs (callPackage' ./nodePackages);

  dmenu-flexipatch = callPackage' ./flexipatch/dmenu.nix;
  dwm-flexipatch = callPackage' ./flexipatch/dwm.nix;
  slock-flexipatch = callPackage' ./flexipatch/slock.nix;
  st-flexipatch = callPackage' ./flexipatch/st.nix;

  basiliskii-bin = callPackage' ./basiliskii-bin.nix;
  cardinal = callPackage' ./cardinal.nix;
  dpf-plugins = callPackage' ./dpf-plugins.nix;
  fennel-language-server = callPackage' ./fennel-language-server.nix;
  ildaeil = callPackage' ./ildaeil.nix;
  keepmenu = callPackage' ./keepmenu.nix;
  kiwmi = callPackage' ./kiwmi.nix;
  luakit = callPackage' ./luakit.nix;
  lv2vst = callPackage' ./lv2vst.nix;
  raze = callPackage' ./raze.nix;
  sheepshaver-bin = callPackage' ./sheepshaver-bin.nix;
  zrythm = callPackage' ./zrythm.nix;
}
