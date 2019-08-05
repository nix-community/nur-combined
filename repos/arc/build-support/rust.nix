{ self, super, lib, ... }: let

  # Find mozilla overlay or pinned fallback
  hasMozillaPath = builtins.filter ({ prefix, ... }: prefix == "mozilla") builtins.nixPath;
  mozillaOverlayRev = "200cf0640fd8fdff0e1a342db98c9e31e6f13cd7";
  mozillaOverlay =
    if hasMozillaPath
    then <mozilla>
    else builtins.fetchTarball {
      name = "source";
      url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${mozillaOverlayRev}.tar.gz";
      sha256 = "0gv7acx2vy2n9wbgays0s3ag43sqqx9pqyr90ffglli0rsm0m1p1";
    };
  mozilla = pkgs: import (mozillaOverlay + "/package-set.nix") { inherit pkgs; };

  builders = {
    rustChannelWith = { rustChannelOf ? (mozilla pkgs).rustChannelOf, pkgs ? null }: lib.makeOverridable ({
      dist_root ? null, date ? null, staging ? false, channel ? null, rustToolchain ? null,
      extensions ? [], targetExtensions ? [], targets ? []
    } @ args: let
      channel = rustChannelOf (builtins.removeAttrs args [ "extensions" "targetExtensions" "targets" ]);
      overrides = {
        rust = channel.rust.override { inherit extensions targetExtensions targets; };
      };
    in channel // lib.optionalAttrs (args ? extensions || args ? targetExtensions || args ? targets) overrides);
    rustChannelPlatform = {
      makeRustPlatform, rustChannelWith
    }: args: let
      channel = if args ? rust then args else rustChannelWith args;
      inherit (channel) rust;
    in makeRustPlatform {
      rustc = rust;
      cargo = rust;
    } // {
      inherit channel;
      rustcSrc = if channel ? rust-src
        then rust # channel.rust-src or throw?
        else throw "rust-src extension required";
    };
    rustChannel = { rustChannelWith }: {
      stable = rustChannelWith { channel = "1.36.0"; };
      # TODO: beta
      nightly = rustChannelWith { date = "2019-07-19"; channel = "nightly"; };
    };
  };
in (builtins.mapAttrs (_: p: self.callPackage p { }) builders)
