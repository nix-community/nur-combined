{ pkgs, ... }:

let
  nix-tools = with pkgs; [
    nixfmt-rfc-style
    nix-index
    nix-tree
    nix-output-monitor
    nh
  ];

  build-tools = with pkgs; [
    cmake
    meson
    gnumake

    clang
    clang-tools
    llvm
    lldb

    rustup
    lua
    python3
    nim
    zig
    go
    #julia
    nodejs
    nodePackages.pnpm

    git
    # hugo
    just

    #ghc
    #haskellPackages.cabal-install
    #jdk21
  ];

  unix-tools = with pkgs; [
    bat
    hyfetch
    yazi
    onefetch

    # wasm
    #wasmtime
    #twiggy
    #binaryen
    #wabt

    scrcpy
    bind
    ripgrep
    ffmpeg_7-full
    file
    asciinema
    iw
    b3sum
    lrzip
    tokei
    hyperfine
    rsgain
    my.odin
    q
    ouch
    lf
    pdftk
    duf
    nvfetcher
    #steamguard-cli
    rclone

    nur.repos.nykma.zen-browser

    #zsh
    jq
  ];

  office = with pkgs; [
    libreoffice-fresh
    #calibre
    #octave
    typst
    foliate
    texlive.combined.scheme-full
    asciidoc-full
    ghex
    #feishu
    #mathematica
    #virtualbox
  ];

  others = with pkgs; [
    # fractal-next # matrix
    tdesktop
    # microsoft-edge-dev
    tor-browser-bundle-bin
    google-chrome
    localsend
    # handbrake
    go-musicfox
    # jellyfin-media-player
    # wireshark
    # gaphor
    # gimp
    # minder
    my.tsukimi

    # matlab
    # vmware-workstation
    adw-gtk3
    (ventoy.override {
      defaultGuiType = "gtk3";
      withGtk3 = true;
    })
  ];
in

{
  home.packages = office ++ others ++ build-tools ++ unix-tools ++ nix-tools;
}
