{pkgs, ...}: let
  callPackage' = pkg:
    pkgs.callPackage pkg {
      inherit pkgs callPackage';
      sources = pkgs.callPackage (pkg + "/_sources/generated.nix") {};
    };

  callPackages = pkg: pkgs.lib.recurseIntoAttrs (callPackage' pkg);
in {
  basiliskii-bin = callPackage' ./basiliskii-bin;
  cardinal = callPackage' ./cardinal;
  cinelerra-gg-bin = callPackage' ./cinelerra-gg-bin;
  deemix-gui-bin = callPackage' ./deemix-gui-bin;
  distrho-ports = callPackage' ./distrho-ports;
  dpf-plugins = callPackage' ./dpf-plugins;
  fennel-language-server = callPackage' ./fennel-language-server;
  firefoxAddons = callPackages ./firefoxAddons;
  flexipatch = callPackages ./flexipatch;
  geonkick = callPackage' ./geonkick;
  giada = callPackage' ./giada;
  haskellPackages = callPackages ./haskellPackages;
  ildaeil = callPackage' ./ildaeil;
  keepmenu = callPackage' ./keepmenu;
  kiwmi = callPackage' ./kiwmi;
  luaPackages = callPackages ./luaPackages;
  luakit = callPackage' ./luakit;
  lv2vst = callPackage' ./lv2vst;
  nimlangserver = callPackage' ./nimlangserver;
  nodePackages = callPackages ./nodePackages;
  octasine = callPackage' ./octasine;
  osirus = callPackage' ./osirus;
  powertab = callPackage' ./powertab;
  pythonPackages = callPackages ./pythonPackages;
  raze = callPackage' ./raze;
  satty = callPackage' ./satty;
  sheepshaver-bin = callPackage' ./sheepshaver-bin;
  swift-mesonlsp-bin = callPackage' ./swift-mesonlsp-bin;
  symbols-nerd-font = callPackage' ./symbols-nerd-font;
  tal = callPackages ./tal;
  treeSitterGrammars = callPackages ./treeSitterGrammars;
  vimPlugins = callPackage' ./vimPlugins;
  xplrPlugins = callPackage' ./xplrPlugins;
  zrythm = callPackage' ./zrythm;
}
