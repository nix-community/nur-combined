{pkgs, ...}: let
  callPackageArgs = pkg: {
    inherit pkgs callPackage';
    sources = pkgs.callPackage (pkg + "/_sources/generated.nix") {};
    utils = callPackage' ../utils;
  };

  callPackage' = pkg:
    pkgs.callPackage pkg (callPackageArgs pkg);

  callPackages' = pkg: pkgs.callPackages pkg (callPackageArgs pkg);

  concat = pkgs.lib.concatStringsSep ".";

  packages = {
    actuate = callPackage' ./actuate;
    aida-x = callPackage' ./aida-x;
    airwindows-consolidated = callPackage' ./airwindows-consolidated;
    apisonic = callPackages' ./apisonic;
    arboreal = callPackages' ./arboreal;
    audible-planets-bin = callPackage' ./audible-planets-bin;
    basiliskii-bin = callPackage' ./basiliskii-bin;
    bitdos-bin = callPackage' ./bitdos-bin;
    blepfx = callPackages' ./blepfx;
    blocks = callPackage' ./blocks;
    cantata = callPackage' ./cantata;
    cardinal = callPackage' ./cardinal;
    charlatan = callPackage' ./charlatan;
    cinelerra-gg-bin = callPackage' ./cinelerra-gg-bin;
    clap-info = callPackage' ./clap-info;
    cloudreverb = callPackage' ./cloudreverb;
    curl-gnutls3 = callPackage' ./curl-gnutls3;
    deemix-gui-bin = callPackage' ./deemix-gui-bin;
    digits-bin = callPackage' ./digits-bin;
    distrho-ports = callPackage' ./distrho-ports;
    dpf-plugins = callPackage' ./dpf-plugins;
    dsp56300 = callPackage' ./dsp56300;
    emacsPackages = callPackages' ./emacsPackages;
    fennel-language-server = callPackage' ./fennel-language-server;
    firefly-synth = callPackage' ./firefly-synth;
    firefoxAddons = callPackages' ./firefoxAddons;
    flexipatch = callPackages' ./flexipatch;
    geonkick = callPackage' ./geonkick;
    giada = callPackage' ./giada;
    gnomedistort2 = callPackage' ./gnomedistort2;
    guitarix-vst-bin = callPackage' ./guitarix-vst-bin;
    guitarml = callPackages' ./guitarml;
    haskellPackages = callPackages' ./haskellPackages;
    helion-bin = callPackage' ./helion-bin;
    hera = callPackage' ./hera;
    hise = callPackage' ./hise;
    hvcc = callPackage' ./hvcc;
    igorski = callPackages' ./igorski;
    ildaeil = callPackage' ./ildaeil;
    js80p = callPackage' ./js80p;
    just-a-sample-bin = callPackage' ./just-a-sample-bin;
    keepmenu = callPackage' ./keepmenu;
    kiwmi = callPackage' ./kiwmi;
    lamb = callPackage' ./lamb;
    luaPackages = callPackages' ./luaPackages;
    luakit = callPackage' ./luakit;
    lv2vst = callPackage' ./lv2vst;
    maim-bin = callPackage' ./maim-bin;
    mesonlsp-bin = callPackage' ./mesonlsp-bin;
    microbiome-bin = callPackage' ./microbiome-bin;
    misstrhortion = callPackage' ./misstrhortion;
    modstems = callPackage' ./modstems;
    musique = callPackage' ./musique;
    mxtune-bin = callPackage' ./mxtune-bin;
    nimlangserver = callPackage' ./nimlangserver;
    nodePackages = callPackages' ./nodePackages;
    octasine = callPackage' ./octasine;
    onagre = callPackage' ./onagre;
    panacea-bin = callPackage' ./panacea-bin;
    peakeater-bin = callPackage' ./peakeater-bin;
    powertab = callPackage' ./powertab;
    propertree = callPackage' ./propertree;
    protrekkr = callPackage' ./protrekkr;
    pythonPackages = callPackages' ./pythonPackages;
    rnnoise-plugin = callPackage' ./rnnoise-plugin;
    roomreverb = callPackage' ./roomreverb;
    satty = callPackage' ./satty;
    schrammel-ojd = callPackage' ./schrammel-ojd;
    sg-323 = callPackage' ./sg-323;
    sgdboop-bin = callPackage' ./sgdboop-bin;
    sheepshaver-bin = callPackage' ./sheepshaver-bin;
    showmidi-bin = callPackage' ./showmidi-bin;
    squeezer-bin = callPackage' ./squeezer-bin;
    symbols-nerd-font = callPackage' ./symbols-nerd-font;
    tal = callPackages' ./tal;
    thorium-bin = callPackage' ./thorium-bin;
    tonelib = callPackages' ./tonelib;
    tonez = callPackage' ./tonez;
    treeSitterGrammars = callPackages' ./treeSitterGrammars;
    u-he = callPackages' ./u-he;
    uhhyou = callPackage' ./uhhyou;
    umu = callPackage' ./umu;
    venn = callPackages' ./venn;
    vgmtrans = callPackage' ./vgmtrans;
    vimPlugins = callPackages' ./vimPlugins;
    waterfox-bin = callPackage' ./waterfox-bin;
    white-elephant-audio = callPackage' ./white-elephant-audio;
    winegui = callPackage' ./winegui;
    xplrPlugins = callPackages' ./xplrPlugins;
    yaziPlugins = callPackages' ./yaziPlugins;
    ysfx = callPackage' ./ysfx;
    zl-audio = callPackages' ./zl-audio;
    zrythm = callPackage' ./zrythm;
  };
in
  packages
  // pkgs.lib.mapAttrsRecursive
  (old: new:
    pkgs.lib.warn
    "${concat old} has been renamed to ${concat new}"
    (pkgs.lib.attrByPath new null packages))
  (import ./_renamed.nix)
