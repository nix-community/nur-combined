# Nix related settings
{ config, inputs, lib, options, pkgs, ... }:
let
  cfg = config.my.system.nix;

  channels = lib.my.merge [
    {
      # Allow me to use my custom package using `nix run self#pkg`
      self = inputs.self;
      # Add NUR to run some packages that are only present there
      nur = inputs.nur;
      # Use pinned nixpkgs when using `nix run pkgs#<whatever>`
      pkgs = inputs.nixpkgs;
    }
    (lib.optionalAttrs cfg.overrideNixpkgs {
      # ... And with `nix run nixpkgs#<whatever>`
      nixpkgs = inputs.nixpkgs;
    })
  ];
in
{
  options.my.system.nix = with lib; {
    enable = my.mkDisableOption "nix configuration";

    linkInputs = my.mkDisableOption "link inputs to `/etc/nix/inputs/`";

    addToRegistry = my.mkDisableOption "add inputs and self to registry";

    addToNixPath = my.mkDisableOption "add inputs and self to nix path";

    overrideNixpkgs = my.mkDisableOption "point nixpkgs to pinned system version";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.addToNixPath -> cfg.linkInputs;
          message = ''
            enabling `my.system.nix.addToNixPath` needs to have
            `my.system.nix.linkInputs = true`
          '';
        }
      ];
    }

    {
      nix = {
        package = pkgs.nix;

        settings = {
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
    }

    (lib.mkIf cfg.addToRegistry {
      nix.registry =
        let
          makeEntry = v: { flake = v; };
          makeEntries = lib.mapAttrs (lib.const makeEntry);
        in
        makeEntries channels;
    })

    (lib.mkIf cfg.linkInputs {
      environment.etc =
        let
          makeLink = n: v: {
            name = "nix/inputs/${n}";
            value = { source = v.outPath; };
          };
          makeLinks = lib.mapAttrs' makeLink;
        in
        makeLinks channels;
    })

    (lib.mkIf cfg.addToNixPath {
      nix.nixPath = [
        "/etc/nix/inputs"
      ]
      ++ options.nix.nixPath.default;
    })
  ]);
}
