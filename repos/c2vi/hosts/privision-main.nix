{ inputs, self, nixpkgs, specialArgs, ... }:
{
  outputs.apps = {
    main = inputs.nix-provision.mkProvision self.outputs.nixosConfigurations.main;
  };
  outputs.nixosConfigurations.main = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    system = "x86_64-linux";

    modules = [
      ./hosts/main.nix
      ./hardware/my-hp-laptop.nix
      {
        provision = {
          type = "disk";
          # other types: phone, wsl, libirt-vm, installer,

          lvm.physicalVolumes.lvm0 = {
            logicalVolumes = [
              {
                label = "root";
                type = "btrfs";
              }
              {
                label = "swap";
                type = "swap";
              }
              {
                label = "work";
                type = "btrfs";
              }
            ];
          };

          hardware.boot = {
          };

          hardware.drive = {
            type = "gpt";
            partitions = [
              {
                label = "boot";
                type = "fat32";
              }
              {
                type = "luks";
                secret = "luks-secret";
                containing = {
                  type = "lvm-pv";
                  partOf = "lvm0";
                };
              }
            ];
          };
        };
      }
    ];
  };
}
