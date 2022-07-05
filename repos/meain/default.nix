# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ## personal
  traffic = pkgs.callPackage ./pkgs/traffic { };
  gh-issues-to-rss = pkgs.callPackage ./pkgs/gh-issues-to-rss { };
  tojson = pkgs.callPackage ./pkgs/tojson { };
  toffee = pkgs.callPackage ./pkgs/toffee { };
  quickserve = pkgs.callPackage ./pkgs/quickserve { };
  gloc = pkgs.callPackage ./pkgs/gloc { };
  nn = pkgs.callPackage ./pkgs/nn { };
  sirus = pkgs.callPackage ./pkgs/sirus { };
  mmm = pkgs.callPackage ./pkgs/mmm { };

  ## external
  fluent-theme = pkgs.callPackage ./pkgs/fluent-theme { };
  kmonad = pkgs.callPackage ./pkgs/kmonad { };
  warpd = pkgs.callPackage ./pkgs/warpd { };
  dmenu = pkgs.callPackage ./pkgs/dmenu { };
  # notmuch-git = pkgs.callPackage ./pkgs/notmuch-git {};
  gnomeExtensions.steal-my-focus = pkgs.callPackage ./pkgs/steal-my-focus { };
  prosemd-lsp = pkgs.callPackage ./pkgs/prosemd-lsp { };
  gcalendar = pkgs.python38.pkgs.callPackage ./pkgs/gcalendar { };
  activitywatch-bin = pkgs.python38.pkgs.callPackage ./pkgs/activitywatch-bin { };
  spaceman-diff = pkgs.callPackage ./pkgs/spaceman-diff { };
  dbui = pkgs.callPackage ./pkgs/dbui { };

  ## programming
  # buf = pkgs.callPackage ./pkgs/buf {};
  grpc-gateway = pkgs.callPackage ./pkgs/grpc-gateway { };
  # golang-migrate::tags: postgres mysql redshift cassandra spanner cockroachdb clickhouse file go_bindata github aws_s3 google_cloud_storage godoc_vfs gitlab
  golang-migrate-pg = pkgs.callPackage ./pkgs/golang-migrate { tags = [ "postgres" "file" ]; }; # with proper build tags
  protodot = pkgs.python38.pkgs.callPackage ./pkgs/protodot { };

  ## fonts
  victor-mono-nf = pkgs.callPackage ./pkgs/victor-mono-nf { }; # nerd-font version of victor mono
}
