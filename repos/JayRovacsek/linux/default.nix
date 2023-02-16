{ self }:
let
  inherit (self) inputs;

  # Package Sets
  inherit (self.inputs) stable unstable;

  # Extra modules
  inherit (self.inputs) microvm nixos-generators nixos-hardware nixos-wsl;

  inherit (self.common.system) stable-system unstable-system;

  inherit (self.common.package-sets)
    x86_64-linux-stable x86_64-linux-unstable aarch64-linux-stable
    aarch64-linux-unstable;

in {
  # SD Installer Images / Configs
  rpi1 = import ../common/images/rpi1.nix { inherit self; };
  rpi2 = import ../common/images/rpi2.nix { inherit self; };

  # Cloud Base Images
  linode = import ../common/images/linode.nix { inherit self; };

  # Base Configuration Hosts
  # Above cloud base images all inherit from this configuration effectively 
  # so exposure here is more to give a consistent base and be enabled to add tweaks
  # at a level in which it is inherited from all base-images
  # This host otherwise is simply a very base headless install
  ditto = let
    inherit (x86_64-linux-unstable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/ditto ];
  in unstable-system { inherit system pkgs modules; };

  # Cloud Instances

  diglett = let
    inherit (x86_64-linux-unstable) system identifier pkgs;
    # Inject the required linode settings viathe cloud base image module
    inherit (self.common.cloud-base-image-modules) linode;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/diglett linode ];
  in unstable-system { inherit system pkgs modules; };

  # Hosts
  alakazam = let
    inherit (x86_64-linux-unstable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/alakazam microvm.nixosModules.host ];
  in unstable-system { inherit system pkgs modules; };

  gastly = let
    inherit (x86_64-linux-unstable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/gastly ];
  in unstable-system { inherit system pkgs modules; };

  dragonite = let
    inherit (x86_64-linux-stable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/dragonite microvm.nixosModules.host ];
  in stable-system { inherit system pkgs modules; };

  jigglypuff = let
    inherit (aarch64-linux-stable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/jigglypuff ];
  in stable-system { inherit system pkgs modules; };

  wigglytuff = let
    inherit (aarch64-linux-unstable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base
      ++ [ ../hosts/wigglytuff nixos-hardware.nixosModules.raspberry-pi-4 ];
  in unstable-system { inherit system pkgs modules; };

  ## WSL Configuration

  zubat = let
    inherit (x86_64-linux-stable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/zubat nixos-wsl.nixosModules.wsl ];
  in stable-system { inherit system pkgs modules; };

  ## MicroVMs

  igglybuff = let
    inherit (x86_64-linux-unstable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ microvm.nixosModules.microvm ../hosts/igglybuff ];
  in unstable-system { inherit system pkgs modules; };

  aipom = let
    inherit (x86_64-linux-unstable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ microvm.nixosModules.microvm ../hosts/aipom ];
  in unstable-system { inherit system pkgs modules; };
}
