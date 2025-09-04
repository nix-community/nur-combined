{ super, lib, inputs, modules, ... }:
with lib;
flip concatMapAttrs super.hosts (hostName: host:
{
  "${hostName}" = nixosSystem {
    modules = with inputs; [
      darkmatter-grub-theme.nixosModule
      disko.nixosModules.disko
      home-manager.nixosModules.home-manager
      impermanence.nixosModules.impermanence
      nur.modules.nixos.default
      sops-nix.nixosModules.sops
      host.default
      host.hardware-configuration
      ({ config, ... }: {
        _module.args = {
          inherit inputs;
        };

        nixpkgs.overlays = [
          super.overlay
          bluetooth-player.overlays."${config.nixpkgs.hostPlatform.system}".default
          inputs.nix-vscode-extensions.overlays.default
          (final: _prev: {
            niriswitcher = final.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/ni/niriswitcher/package.nix" {};
          })
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [
            sops-nix.homeManagerModules.sops
          ];
        };

        networking.hostName = hostName;
      })
    ];
  };
  "${hostName}-installer" = nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      modules.nix.default
      {
        _module.args = {
          inherit inputs;
        };
      }
      ({ config, pkgs, lib, modulesPath, ... }:
        let
          self = inputs.self;
          curConfig = self.nixosConfigurations.${hostName};
          dependencies = [
            curConfig.config.system.build.toplevel
            curConfig.config.system.build.diskoScript
            curConfig.config.system.build.diskoScript.drvPath
            curConfig.pkgs.stdenv.drvPath

            # https://github.com/NixOS/nixpkgs/blob/f2fd33a198a58c4f3d53213f01432e4d88474956/nixos/modules/system/activation/top-level.nix#L342
            curConfig.pkgs.perlPackages.ConfigIniFiles
            curConfig.pkgs.perlPackages.FileSlurp

            (curConfig.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
          ] ++ builtins.map
            (i: i.outPath)
            (builtins.attrValues self.inputs);

          closureInfo = pkgs.closureInfo { rootPaths = dependencies; };
        in
        {
          imports = [
            (modulesPath + "/profiles/installation-device.nix")
          ];

          environment.etc."install-closure".source = "${closureInfo}/store-paths";

          environment.systemPackages =
            let
              arg = builtins.toJSON {
                boot.loader.grub.devices = lib.mkOverride 9 [ "nodev" ];
              };
              shellArg = lib.escapeShellArg arg;
            in
            [
              (pkgs.writeShellScriptBin "install-nixos-unattended" ''
                exec ${pkgs.disko}/bin/disko-install --flake "${self}#${hostName}" --system-config ${shellArg} \
                  --extra-files /persist/key.txt /persist/key.txt "$@"
              '')
            ];

          # shut up state version warning
          system.stateVersion = config.system.nixos.release;
          nixpkgs.hostPlatform = curConfig.pkgs.stdenv.system;
          networking.hostName = "${hostName}-installer";

          boot.loader.systemd-boot.enable = true;
          boot.loader.systemd-boot.configurationLimit = 16;

          disko.devices = {
            disk = {
              installer = {
                device = "/dev/disk/by-label/installer";
                imageSize = "32G";
                type = "disk";
                content = {
                  type = "gpt";
                  partitions = {
                    ESP = {
                      type = "EF00";
                      size = "500M";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                        mountOptions = [ "umask=0077" ];
                      };
                    };
                    root = {
                      size = "100%";
                      content = {
                        type = "filesystem";
                        format = "ext4";
                        mountpoint = "/";
                      };
                    };
                  };
                };
              };
            };
          };
        }
      )
    ];
  };
})
