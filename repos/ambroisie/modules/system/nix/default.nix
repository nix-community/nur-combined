# Nix related settings
{ config, inputs, lib, options, pkgs, ... }:
let
  cfg = config.my.system.nix;
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
      nix.registry = {
        # Allow me to use my custom package using `nix run self#pkg`
        self.flake = inputs.self;
        # Use pinned nixpkgs when using `nix run pkgs#<whatever>`
        pkgs.flake = inputs.nixpkgs;
        # ... And with `nix run nixpkgs#<whatever>`
        nixpkgs.flake = lib.mkIf cfg.overrideNixpkgs inputs.nixpkgs;
        # Add NUR to run some packages that are only present there
        nur.flake = inputs.nur;
      };
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
        makeLinks {
          inherit (inputs)
            self
            nixpkgs
            nur
            ;
        };
    })

    (lib.mkIf cfg.addToNixPath {
      nix.nixPath = [
        "self=/etc/nix/inputs/self"
        "pkgs=/etc/nix/inputs/nixpkgs"
        "nur=/etc/nix/inputs/nur"
      ]
      ++ lib.optional cfg.overrideNixpkgs "nixpkgs=/etc/nix/inputs/nixpkgs"
      ++ options.nix.nixPath.default;
    })
  ]);
}
