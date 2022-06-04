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
    sha256 = "1gldv2rlb4l1ml90n2nr11qmglh9jj7rbxfxzbrsrpb0kv4720lb";
  };
  rustOverlayRev = "130b3bbdb55cc1c62314bd7108493d9e6ffc0784";
  rustPlatformFor = { rustPlatform, ... }: rustPlatform;

  builders = {
    rustPlatforms = { rustChannel ? rust pkgs, pkgs ? null }: with lib;
      mapAttrs (_: rustPlatformFor) rustChannel.releases // {
        stable = rustPlatformFor rustChannel.releases."1.61.0";
        # An occasionally pinned unstable release
        # Check https://rust-lang.github.io/rustup-components-history/ before updating this to avoid breaking things
        nightly = rustPlatformFor (rustChannel.nightly.override {
          date = "2022-05-24";
          sha256 = "0vigz8x2l9zcyphpf476n02q9n3hln2q8pbb93pd03r71l6yqm19";
          manifestPath = ./channel-rust-nightly.toml;
          rustcDev = true;
        });
        impure = mapAttrs (_: rustPlatformFor) {
          inherit (rustChannel) stable beta nightly;
        };
      };
    rustPlatformFor = { rustChannel ? rust pkgs, pkgs ? null }: args:
      rustPlatformFor (rustChannel.distChannel args);
  };
in builders
