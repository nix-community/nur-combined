# Nix related settings
{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.my.home.nix;

  channels = lib.my.merge [
    {
      # Allow me to use my custom package using `nix run self#pkg`
      self = inputs.self;
      # Add NUR to run some packages that are only present there
      nur = inputs.nur;
      # Use pinned nixpkgs when using `nix run pkgs#<whatever>`
      pkgs = inputs.nixpkgs;
    }
    (lib.optionalAttrs cfg.inputs.overrideNixpkgs {
      # ... And with `nix run nixpkgs#<whatever>`
      nixpkgs = inputs.nixpkgs;
    })
  ];
in
{
  options.my.home.nix = with lib; {
    enable = my.mkDisableOption "nix configuration";

    gc = {
      enable = my.mkDisableOption "nix GC configuration";
    };

    cache = {
      selfHosted = my.mkDisableOption "self-hosted cache";
    };

    inputs = {
      link = my.mkDisableOption "link inputs to `$XDG_CONFIG_HOME/nix/inputs/`";

      addToRegistry = my.mkDisableOption "add inputs and self to registry";

      addToNixPath = my.mkDisableOption "add inputs and self to nix path";

      overrideNixpkgs = my.mkDisableOption "point nixpkgs to pinned system version";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.inputs.addToNixPath -> cfg.inputs.link;
          message = ''
            enabling `my.home.nix.addToNixPath` needs to have
            `my.home.nix.linkInputs = true`
          '';
        }
      ];
    }

    {
      nix = {
        package = lib.mkDefault pkgs.nix; # NixOS module sets it unconditionally

        settings = {
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
    }

    (lib.mkIf cfg.gc.enable {
      nix.gc = {
        automatic = true;

        # Every week, with some wiggle room
        frequency = "weekly";
        randomizedDelaySec = "10min";

        # Use a persistent timer for e.g: laptops
        persistent = true;

        # Delete old profiles automatically after 15 days
        options = "--delete-older-than 15d";
      };
    })

    (lib.mkIf cfg.cache.selfHosted {
      nix = {
        settings = {
          extra-substituters = [
            "https://cache.belanyi.fr/"
          ];

          extra-trusted-public-keys = [
            "cache.belanyi.fr:LPhrTqufwfxTceg1nRWueDWf7/2zSVY9K00pq2UI7tw="
          ];
        };
      };
    })

    (lib.mkIf cfg.inputs.addToRegistry {
      nix.registry =
        let
          makeEntry = v: { flake = v; };
          makeEntries = lib.mapAttrs (lib.const makeEntry);
        in
        makeEntries channels;
    })

    (lib.mkIf cfg.inputs.link {
      xdg.configFile =
        let
          makeLink = n: v: {
            name = "nix/inputs/${n}";
            value = { source = v.outPath; };
          };
          makeLinks = lib.mapAttrs' makeLink;
        in
        makeLinks channels;
    })

    (lib.mkIf cfg.inputs.addToNixPath {
      nix.nixPath = [ "${config.xdg.configHome}/nix/inputs" ];
    })
  ]);
}
