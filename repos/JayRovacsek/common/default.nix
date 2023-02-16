{ self }: {
  age = import ./age.nix { inherit self; };
  base-users = import ./base-users.nix { inherit self; };
  cloud-base-image-modules =
    import ./cloud-base-image-modules { inherit self; };
  home-manager = import ./home-manager.nix { inherit self; };
  home-manager-module-sets = import ./home-manager-sets { inherit self; };
  home-manager-modules = import ./home-manager-modules.nix { inherit self; };
  images = import ./images { inherit self; };
  modules = import ./modules.nix { inherit self; };
  options = import ./options.nix { inherit self; };
  package-sets = import ./package-sets.nix { inherit self; };
  pre-commit-unsupported = import ./pre-commit-unsupported.nix;
  self-reference = import ./self-reference.nix { inherit self; };
  standardise-nix = import ./standardise-nix.nix { inherit self; };
  system = import ./system.nix { inherit self; };
  users = import ./users.nix { inherit self; };
}
