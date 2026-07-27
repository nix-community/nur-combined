{ config, lib, pkgs, ... }:

with lib;
let
  capture = pkgs.writeScriptBin "capture" ''
    #!${pkgs.stdenv.shell}
    emacsclient -n -c -F '((name . "capture") (width . 150) (height . 90))' -e '(org-capture)'
  '';
  et = pkgs.writeScriptBin "et" ''
    #!${pkgs.stdenv.shell}
    emacsclient --tty $@
  '';
  ec = pkgs.writeScriptBin "ec" ''
    #!${pkgs.stdenv.shell}
    emacsclient --create-frame $@
  '';
  myExtraPackages = epkgs: with epkgs; [
    # FIXME(vdemeester) once it is fixed, re-add
    # all-the-icons
    # bongo
    # color-identifiers-mode
    # consult-lsp
    # dap-mode
    # delight
    # dired-sidebar
    # dired-subtree
    # edit-indirect
    # emacs-everywhere
    # emms
    # expand-region
    # flymake-codespell
    # flymake-languagetool
    # fontaine
    # git-annex
    # github-review
    # goto-last-change
    # hl-todo
    # icomplete-vertical
    # kind-icon
    # lin
    # lsp-focus
    # lsp-mode
    # lsp-ui
    # multiple-cursors
    # nerd-icons
    # nix-buffer
    # org-appear
    # org-capture-pop-frame
    # org-journal
    # org-super-agenda
    # org-transclusion
    # pdf-tools
    # pkgs.dired-plus
    # python-mode
    # rainbow-delimiters
    # rainbow-mode
    # treesit-grammars.with-all-grammars
    # undo-tree
    # use-package # it's now part of built-in packages
    # whole-line-or-region
    # bbdb
    ace-window
    adoc-mode
    aggressive-indent
    alert
    async
    avy
    beginend
    cape
    casual
    casual-avy
    conner
    consult
    consult-dir
    consult-notes
    copilot
    copilot-chat
    corfu
    corfu-candidate-overlay
    dape
    dash
    denote
    devdocs
    dired-collapse
    dired-narrow
    dired-rsync
    diredfl
    dockerfile-mode
    doom-modeline
    easy-kill
    eat
    edit-indirect
    editorconfig
    eldoc-box
    embark
    embark-consult
    envrc
    eshell-prompt-extras
    esup
    flimenu
    flymake-yamllint
    focus
    git-gutter
    git-gutter-fringe
    git-modes
    go-mode
    gotest
    hardhat
    helpful
    highlight
    highlight-indentation
    htmlize
    indent-bars
    ibuffer-vc
    jinx
    json-mode
    kubed
    ligature
    macrostep
    magit
    magit-popup
    marginalia
    markdown-mode
    mct
    modus-themes
    multi-vterm
    mwim
    nix-mode
    nix-ts-mode
    nixpkgs-fmt
    no-littering
    ob-async
    ob-go
    ob-http
    orderless # TODO configure this
    org
    org-contrib
    org-modern
    org-nix-shell
    org-ql
    org-review
    org-rich-yank
    org-tree-slide
    org-web-tools
    orgalist
    orgit
    ox-pandoc
    pandoc-mode
    pkgs.bookmark-plus # Do I use it ?
    popper
    rg
    ripgrep
    run-command # Try this out instead of conner, might be even better
    scopeline
    scratch
    shr-tag-pre-highlight
    smartparens
    substitute
    surround
    symbol-overlay
    tempel
    tempel-collection
    trashed
    treesit-auto
    try
    typescript-mode
    visual-fill-column
    visual-regexp
    vterm
    vundo
    web-mode
    wgrep
    with-editor
    xterm-color
    yaml-mode
  ];
in
{
  home.file.".config/emacs" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/vincent/src/home/tools/emacs";
    # recursive = true;
  };
  home.file.".local/share/applications/org-protocol.desktop".source = ./emacs/org-protocol.desktop;
  home.file.".local/share/applications/capture.desktop".source = ./emacs/capture.desktop;
  home.packages = with pkgs; [
    ditaa
    graphviz
    pandoc
    sqlite
    zip
    ugrep
    # See if I can hide this under an option
    capture
    # github-copilot-cli # for copilot.el
    nodejs
    ec
    et
    languagetool
    asciidoctor
    enchant
  ];
  programs.emacs = {
    enable = true;
    # FIXME: choose depending on the enabled modules
    #package = (pkgs.emacs29.override { withTreeSitter = true; withNativeCompilation = true; withPgtk = true; withWebP = true; withGTK3 = true; withSQLite3 = true; });
    package = (pkgs.emacs-unstable.override { withTreeSitter = true; withNativeCompilation = true; withPgtk = true; withWebP = true; withGTK3 = true; withSQLite3 = true; });
    extraPackages = myExtraPackages;
  };
  services.emacs = {
    enable = true;
    client.enable = true;
    #socketActivation.enable = true;
  };
  home.sessionVariables = {
    EDITOR = "emacs";
    ALTERNATE_EDITOR = "emacs -nw";
  };
}
