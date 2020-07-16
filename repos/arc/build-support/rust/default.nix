{ self, super, lib, ... }: let

  /* Find mozilla overlay or pinned fallback
  mozillaOverlayRev = "b52a8b7de89b1fac49302cbaffd4caed4551515f";
  mozilla = channelOrPin {
    name = "mozilla";
    check = pkgs: pkgs.latest or null;
    imp = channel: pkgs: import (channel + "/package-set.nix") { inherit pkgs; };
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${mozillaOverlayRev}.tar.gz";
    sha256 = lib.fakeSha256;
  };*/

  # Find rust overlay or pinned fallback
  rust = lib.channelOrPin {
    name = "rust";
    check = pkgs: pkgs.rustChannel or null;
    imp = channel: pkgs: import (channel + "/default.nix") { inherit pkgs; };
    url = "https://github.com/arcnmx/nixexprs-rust/archive/${rustOverlayRev}.tar.gz";
    sha256 = "18zyr2hkg3sjhv6cl9idfqg4ag5pwxybhc7v14l9rr0axndhysin";
  };
  rustOverlayRev = "b65720bc1c306c7d063509c0f7ece0b41ee8e62e";
  rustPlatformFor = { rustPlatform, ... }: rustPlatform;

  builders = {
    rustPlatforms = { rustChannel ? rust pkgs, pkgs ? null }: with lib;
      mapAttrs (_: rustPlatformFor) rustChannel.releases // {
        stable = rustPlatformFor rustChannel.releases."1.45.0";
        # An occasionally pinned unstable release
        # Check https://rust-lang.github.io/rustup-components-history/ before updating this to avoid breaking things
        nightly = rustPlatformFor (rustChannel.nightly.override {
          date = "2020-07-12";
          sha256 = "1fhnhii7969rdh42n00gxs65jrwhbrgq5i6amqkalg6mzmy9mi9s";
          manifestPath = ./channel-rust-nightly.toml;
        });
        impure = mapAttrs (_: rustPlatformFor) {
          inherit (rustChannel) stable beta nightly;
        };
      };
    rustPlatformFor = { rustChannel ? rust pkgs, pkgs ? null }: args:
      rustPlatformFor (rustChannel args);
  };
in builtins.mapAttrs (_: p: self.callPackage p { }) builders
