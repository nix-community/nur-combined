# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  callPackage' = pkg:
    pkgs.callPackage pkg {
      inherit pkgs callPackage';
      sources = pkgs.callPackage (pkg + "/_sources/generated.nix") { };
    };

  callPackages = pkg: pkgs.lib.recurseIntoAttrs (callPackage' pkg);
in
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
  chainlink = pkgs.callPackage ./pkgs/chainlink { };

  ## external
  fluent-theme = pkgs.callPackage ./pkgs/fluent-theme { };
  kmonad = pkgs.callPackage ./pkgs/kmonad { };
  warpd = pkgs.callPackage ./pkgs/warpd { };
  otrecorder = pkgs.callPackage ./pkgs/otrecorder { }; # owntracks-recorder
  # owntracks-frontend = pkgs.callPackage ./pkgs/owntracks-frontend { };
  dmenu = pkgs.callPackage ./pkgs/dmenu { };
  # notmuch-git = pkgs.callPackage ./pkgs/notmuch-git {};
  gnomeExtensions.steal-my-focus = pkgs.callPackage ./pkgs/steal-my-focus { };
  prosemd-lsp = pkgs.callPackage ./pkgs/prosemd-lsp { };
  # gcalendar = pkgs.python3.pkgs.callPackage ./pkgs/gcalendar { };
  spaceman-diff = pkgs.callPackage ./pkgs/spaceman-diff { };
  # dbui = pkgs.callPackage ./pkgs/dbui { };
  dotool = pkgs.callPackage ./pkgs/dotool { };
  pulseaudio-virtualmic = pkgs.callPackage ./pkgs/pulseaudio-virtualmic { };
  chatgpt-cli = pkgs.callPackage ./pkgs/chatgpt-cli { };
  logseq-doctor = pkgs.callPackage ./pkgs/logseq-doctor { };
  fabric = pkgs.callPackage ./pkgs/fabric { };

  # RUn nvfetcher in the haskellPackages directory to update sources
  haskellPackages = callPackages ./pkgs/haskellPackages;

  ## programming
  # buf = pkgs.callPackage ./pkgs/buf {};
  # grpc-gateway = pkgs.callPackage ./pkgs/grpc-gateway { };
  # golang-migrate::tags: postgres mysql redshift cassandra spanner cockroachdb clickhouse file go_bindata github aws_s3 google_cloud_storage godoc_vfs gitlab
  # golang-migrate-pg = pkgs.callPackage ./pkgs/golang-migrate { tags = [ "postgres" "file" ]; }; # with proper build tags
  protodot = pkgs.callPackage ./pkgs/protodot { };

  ## fonts
  victor-mono-nf = pkgs.callPackage ./pkgs/victor-mono-nf { }; # nerd-font version of victor mono

  # Conditionally include firefox-darwin on Darwin
  firefox-darwin = if pkgs.stdenv.isDarwin then pkgs.callPackage ./pkgs/firefox-darwin { } else null;

  # firefox extensions
  # https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/mozilla-addons-to-nix/default.nix?ref_type=heads
  # cd pkgs/firefox-addons/ && mozilla-addons-to-nix addons.json generated.nix
  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });
}
