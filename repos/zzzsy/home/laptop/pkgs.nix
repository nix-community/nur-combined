{ pkgs, ... }:

let
  nix-tools = with pkgs; [
    nixfmt
    nix-index
    nix-tree
    nil
    nixd
    package-version-server
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
    go
    # julia
    nodejs
    pnpm
    bun

    git
    just

    # coq
    # ghc
    # idris2

    typescript
    #haskellPackages.cabal-install
    #jdk21
  ];

  unix-tools = with pkgs; [
    bat
    hyfetch
    yazi
    mosh

    uutils-coreutils-noprefix

    # wasm
    #wasmtime
    #twiggy
    #binaryen
    #wabt

    scrcpy
    bind
    ripgrep
    ffmpeg_8-full
    file
    asciinema
    iw
    b3sum
    tokei
    hyperfine
    rsgain
    # my.odin
    q
    ouch
    pdftk
    duf
    nvfetcher
    #steamguard-cli
    rclone

    graphviz
    #zsh
    jq

    my.login
  ];

  office = with pkgs; [
    libreoffice-fresh
    #calibre
    #octave
    typst
    foliate
    typora
    # todesk
    texlive.combined.scheme-full
    #asciidoc-full
    # ghex
    # ida-free
    megasync
    filen-cli
    filen-desktop
    feishu
    xournalpp
    remmina
    freerdp
    filezilla
    #handbrake
    #scilab-bin
    #feishu
    #mathematica
    #virtualbox
    zed-editor
  ];

  others = with pkgs; [
    # fractal-next # matrix
    # tdesktop
    # microsoft-edge-dev
    tor-browser
    google-chrome
    zen-browser
    localsend
    # handbrake
    splayer
    # waylyrics
    # jellyfin-media-player
    # wireshark
    # gaphor
    # gimp
    # minder
    tsukimi
    materialgram
    wechat
    # antigravity
    llm-agents.codex
    qq
    #ghostty

    deluge-gtk

    # vmware-workstation
    adw-gtk3
    ventoy-full-gtk
  ];
in

{
  home.packages = office ++ others ++ build-tools ++ unix-tools ++ nix-tools;
}
