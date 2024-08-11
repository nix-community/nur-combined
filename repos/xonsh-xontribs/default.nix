# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  backtrace = pkgs.python3Packages.callPackage ./pkgs/backtrace {};
in {
  inherit backtrace;

  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  xonsh = pkgs.python3Packages.callPackage ./pkgs/xonsh/package.nix {};
  xonsh-wrapped = pkgs.python3Packages.callPackage ./pkgs/xonsh/wrapper.nix {};

  xonsh-direnv = pkgs.python3Packages.callPackage ./pkgs/xonsh-direnv {};
  xontrib-abbrevs = pkgs.python3Packages.callPackage ./pkgs/xontrib-abbrevs {};
  xontrib-bashisms = pkgs.python3Packages.callPackage ./pkgs/xontrib-bashisms {};
  xontrib-broot = pkgs.python3Packages.callPackage ./pkgs/xontrib-broot {};
  xontrib-chatgpt = pkgs.python3Packages.callPackage ./pkgs/xontrib-chatgpt {};
  xontrib-clp = pkgs.python3Packages.callPackage ./pkgs/xontrib-clp {};
  xontrib-debug-tools = pkgs.python3Packages.callPackage ./pkgs/xontrib-debug-tools {};
  xontrib-direnv = pkgs.python3Packages.callPackage ./pkgs/xonsh-direnv {};
  xontrib-distributed = pkgs.python3Packages.callPackage ./pkgs/xontrib-distributed {};
  xontrib-dot-dot = pkgs.python3Packages.callPackage ./pkgs/xontrib-dot-dot {};
  xontrib-fish-completer = pkgs.python3Packages.callPackage ./pkgs/xontrib-fish-completer {};
  xontrib-gitinfo = pkgs.python3Packages.callPackage ./pkgs/xontrib-gitinfo {};
  # TODO: diagnose why jedi fails
  # xontrib-jedi = pkgs.python3Packages.callPackage ./pkgs/xontrib-jedi {};
  xontrib-jupyter = pkgs.python3Packages.callPackage ./pkgs/xontrib-jupyter {};
  xontrib-prompt-starship = pkgs.python3Packages.callPackage ./pkgs/xontrib-prompt-starship {};
  xontrib-readable-traceback = pkgs.python3Packages.callPackage ./pkgs/xontrib-readable-traceback {inherit backtrace;};
  xontrib-sh = pkgs.python3Packages.callPackage ./pkgs/xontrib-sh {};
  xontrib-term-integrations = pkgs.python3Packages.callPackage ./pkgs/xontrib-term-integrations {};
  xontrib-vox = pkgs.python3Packages.callPackage ./pkgs/xontrib-vox {};
  xontrib-whole-word-jumping = pkgs.python3Packages.callPackage ./pkgs/xontrib-whole-word-jumping {};
  xontrib-zoxide = pkgs.python3Packages.callPackage ./pkgs/xontrib-zoxide {};
}
