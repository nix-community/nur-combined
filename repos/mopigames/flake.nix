{
  # A flake for the host PC half only -- the ISO itself is built by ./build.sh
  # in a container, not by Nix.
  #
  # It exists so the agent is usable on NixOS directly, without going through
  # the Nix User Repository (packaging/nix/nur.nix), which is where it is
  # published:
  #
  #     nix run github:MopigamesYT/moonlight-os#mlos-host-utils -- pair
  #
  # and so `nix build` here checks that packaging/nix/package.nix still
  # builds, against this checkout rather than a released tag.
  description = "USB passthrough agent for the PC you stream from with Moonlight OS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        # The same derivation the NUR gets, pointed at this working tree
        # instead of a tagged tarball -- one definition, so the published
        # build and the local one cannot drift apart.
        mlos-host-utils = (pkgs.callPackage ./packaging/nix/package.nix { }).overrideAttrs (old: {
          src = self;
          version = "${old.version}-unstable-${self.shortRev or "dirty"}";
        });
        default = mlos-host-utils;
      });

      nixosModules = rec {
        mlos-host-utils = {
          imports = [ ./packaging/nix/module.nix ];
          # Nothing in nixpkgs provides pkgs.mlos-host-utils, which is what
          # the module's package option defaults to, so point it at this
          # flake's build for the host's own system.
          nixpkgs.overlays = [ self.overlays.default ];
        };
        default = mlos-host-utils;
      };

      overlays.default = final: prev: {
        mlos-host-utils = self.packages.${final.system}.mlos-host-utils;
      };

      # `nix flake check` on its own only proves nixosModules is shaped like a
      # module.  This forces the module through a real NixOS evaluation, which
      # is where an option that does not exist or a package that is not in the
      # overlay actually shows up -- and it costs an eval, not a system build.
      checks = forAllSystems (
        pkgs:
        let
          # The NUR is where this is published, and NUR imports nur.nix with a
          # plain `pkgs` -- neither the flake's package output nor its module
          # goes through that file, so a mistake in it would only show up in
          # NUR's own evaluation.
          nur = import ./packaging/nix/nur.nix { inherit pkgs; };

          machineWith =
            module:
            nixpkgs.lib.nixosSystem {
              modules = [
                module
                {
                  nixpkgs.hostPlatform = pkgs.stdenv.hostPlatform.system;
                  boot.loader.grub.devices = [ "/dev/sda" ];
                  fileSystems."/" = {
                    device = "/dev/sda1";
                    fsType = "ext4";
                  };
                  system.stateVersion = "25.05";
                  services.mlos-host-utils = {
                    enable = true;
                    openFirewall = true;
                  };
                }
              ];
            };

          # What actually has to hold for either module: the unit exists, it
          # runs the right binary, and the kernel module and port are set up
          # for it.  Rendering that to a file makes the check a build, so a
          # regression is a failure rather than a diff nobody looks at.
          evalOf =
            name: module:
            let
              machine = machineWith module;
            in
            pkgs.writeText "mlos-host-utils-${name}-eval" (
              builtins.toJSON {
                inherit (machine.config.systemd.services.mlos-host-utils) path;
                exec = machine.config.systemd.services.mlos-host-utils.serviceConfig.ExecStart;
                modules = machine.config.boot.kernelModules;
                ports = machine.config.networking.firewall.allowedTCPPorts;
              }
            );
        in
        {
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.mlos-host-utils;

          # Two ways in, and users take both: the flake's module, and the one
          # NUR hands out.  They differ in where the package comes from, which
          # is exactly the part that breaks silently.
          nixos-module = evalOf "module" self.nixosModules.default;
          nur-module = evalOf "nur-module" nur.modules.mlos-host-utils;

          nur-package = nur.mlos-host-utils;
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
