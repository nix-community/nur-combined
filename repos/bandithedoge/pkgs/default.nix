{pkgs, ...}: let
  callPackage' = pkg:
    pkgs.callPackage pkg {
      inherit pkgs callPackage';
      sources = pkgs.callPackage (pkg + "/_sources/generated.nix") {};
    };

  callPackages = pkg: pkgs.lib.recurseIntoAttrs (callPackage' pkg);

  packages = {
    basiliskii-bin = callPackage' ./basiliskii-bin;
    bitdos-bin = callPackage' ./bitdos-bin;
    cardinal = callPackage' ./cardinal;
    cinelerra-gg-bin = callPackage' ./cinelerra-gg-bin;
    clap-info = callPackage' ./clap-info;
    deemix-gui-bin = callPackage' ./deemix-gui-bin;
    digits-bin = callPackage' ./digits-bin;
    distrho-ports = callPackage' ./distrho-ports;
    dpf-plugins = callPackage' ./dpf-plugins;
    emacsPackages = callPackages ./emacsPackages;
    fennel-language-server = callPackage' ./fennel-language-server;
    firefoxAddons = callPackages ./firefoxAddons;
    flexipatch = callPackages ./flexipatch;
    geonkick = callPackage' ./geonkick;
    giada = callPackage' ./giada;
    haskellPackages = callPackages ./haskellPackages;
    hvcc = callPackage' ./hvcc;
    ildaeil = callPackage' ./ildaeil;
    keepmenu = callPackage' ./keepmenu;
    kiwmi = callPackage' ./kiwmi;
    lamb = callPackage' ./lamb;
    luaPackages = callPackages ./luaPackages;
    luakit = callPackage' ./luakit;
    lv2vst = callPackage' ./lv2vst;
    mesonlsp-bin = callPackage' ./mesonlsp-bin;
    nimlangserver = callPackage' ./nimlangserver;
    nodePackages = callPackages ./nodePackages;
    octasine = callPackage' ./octasine;
    onagre = callPackage' ./onagre;
    osirus = callPackage' ./osirus;
    powertab = callPackage' ./powertab;
    propertree = callPackage' ./propertree;
    pythonPackages = callPackages ./pythonPackages;
    raze = callPackage' ./raze;
    satty = callPackage' ./satty;
    sgdboop-bin = callPackage' ./sgdboop-bin;
    sheepshaver-bin = callPackage' ./sheepshaver-bin;
    symbols-nerd-font = callPackage' ./symbols-nerd-font;
    tal = callPackages ./tal;
    tonelib = callPackages ./tonelib;
    treeSitterGrammars = callPackages ./treeSitterGrammars;
    vgmtrans = callPackage' ./vgmtrans;
    vimPlugins = callPackages ./vimPlugins;
    xplrPlugins = callPackages ./xplrPlugins;
    zrythm = callPackage' ./zrythm;
  };
in
  packages // builtins.mapAttrs (old: new: pkgs.lib.warn "${old} has been renamed to ${new}" packages.${new}) (import ./_renamed.nix)
