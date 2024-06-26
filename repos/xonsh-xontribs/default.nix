# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  xontrib-abbrevs = pkgs.callPackage ./pkgs/xontrib-abbrevs {};
  xontrib-bashisms = pkgs.callPackage ./pkgs/xontrib-bashisms {};
  xontrib-chatgpt = pkgs.callPackage ./pkgs/xontrib-chatgpt {};
  xontrib-clp = pkgs.callPackage ./pkgs/xontrib-clp {};
  xontrib-debug-tools = pkgs.callPackage ./pkgs/xontrib-debug-tools {};
  xontrib-direnv = pkgs.callPackage ./pkgs/xontrib-direnv {};
  xontrib-distributed = pkgs.callPackage ./pkgs/xontrib-distributed {};
  xontrib-dot-dot = pkgs.callPackage ./pkgs/xontrib-dot-dot {};
  xontrib-fish-completer = pkgs.callPackage ./pkgs/xontrib-fish-completer {};
  xontrib-gitinfo = pkgs.callPackage ./pkgs/xontrib-gitinfo {};
  xontrib-jedi = pkgs.callPackage ./pkgs/xontrib-jedi {};
  xontrib-jupyter = pkgs.callPackage ./pkgs/xontrib-jupyter {};
  xontrib-prompt-starship = pkgs.callPackage ./pkgs/xontrib-prompt-starship {};
  xontrib-readable-traceback = pkgs.callPackage ./pkgs/xontrib-readable-traceback {};
  xontrib-sh = pkgs.callPackage ./pkgs/xontrib-sh {};
  xontrib-term-integrations = pkgs.callPackage ./pkgs/xontrib-term-integrations {};
  xontrib-vox = pkgs.callPackage ./pkgs/xontrib-vox {};
  xontrib-zoxide = pkgs.callPackage ./pkgs/xontrib-zoxide {};
}
