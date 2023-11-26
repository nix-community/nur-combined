{pkgs, ...}: let
  callPackage' = pkg:
    pkgs.callPackage pkg {
      inherit pkgs;
      sources = pkgs.callPackage (pkg + "/_sources/generated.nix") {};
    };

  callPackages = pkg: pkgs.lib.recurseIntoAttrs (callPackage' pkg);
in {
  basiliskii-bin = callPackage' ./basiliskii-bin;
  cardinal = callPackage' ./cardinal;
  dpf-plugins = callPackage' ./dpf-plugins;
  fennel-language-server = callPackage' ./fennel-language-server;
  firefoxAddons = callPackages ./firefoxAddons;
  flexipatch = callPackages ./flexipatch;
  haskellPackages = callPackages ./haskellPackages;
  ildaeil = callPackage' ./ildaeil;
  keepmenu = callPackage' ./keepmenu;
  kiwmi = callPackage' ./kiwmi;
  luaPackages = callPackages ./luaPackages;
  luakit = callPackage' ./luakit;
  lv2vst = callPackage' ./lv2vst;
  nodePackages = callPackages ./nodePackages;
  octasine = callPackage' ./octasine;
  osirus = callPackage' ./osirus;
  raze = callPackage' ./raze;
  satty = callPackage' ./satty;
  sheepshaver-bin = callPackage' ./sheepshaver-bin;
  treeSitterGrammars = callPackages ./treeSitterGrammars;
  vimPlugins = callPackage' ./vimPlugins;
  zrythm = callPackage' ./zrythm;
}
