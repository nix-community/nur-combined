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
    (lib.optionalAttrs cfg.overrideNixpkgs {
      # ... And with `nix run nixpkgs#<whatever>`
      nixpkgs = inputs.nixpkgs;
    })
  ];
in
{
  options.my.home.nix = with lib; {
    enable = my.mkDisableOption "nix configuration";

    linkInputs = my.mkDisableOption "link inputs to `$XDG_CONFIG_HOME/nix/inputs`";

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

    (lib.mkIf cfg.addToRegistry {
      nix.registry =
        let
          makeEntry = v: { flake = v; };
          makeEntries = lib.mapAttrs (lib.const makeEntry);
        in
        makeEntries channels;
    })

    (lib.mkIf cfg.linkInputs {
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

    (lib.mkIf cfg.addToNixPath {
      home.sessionVariables.NIX_PATH = "${config.xdg.configHome}/nix/inputs\${NIX_PATH:+:$NIX_PATH}";
    })
  ]);
}
