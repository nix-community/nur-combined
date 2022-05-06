{ username, system, overlays }:
inputs: {
  inherit system;

  modules = (with inputs.self.nixosModules; [
    gaming
    mobile-devices
    moonlander
    nix-setup
    sound
    virtualization
  ]) ++ [
    ./configuration.nix
    inputs.nixos-hardware.nixosModules.system76
    inputs.home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          inputs.sab.hmModule
        ] ++ (with inputs.self.hmModules; [
          alacritty-tmux
          gaming
          neofetch
        ]);
        users."${username}" = import ./home-manager.nix;
      };
      nixpkgs = {
        config.allowUnfree = true;
        overlays = overlays;
      };
    }
  ];
}
