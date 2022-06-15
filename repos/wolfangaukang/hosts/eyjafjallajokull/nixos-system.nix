{ username, system, overlays }:
inputs: {
  inherit system;

  modules = (with inputs.self.nixosModules; [
    mobile-devices
    nix-setup
    sound
    virtualization
  ]) ++ [
    ./configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t430
    inputs.home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          inputs.sab.hmModule
          ../../modules/home-manager/personal
        ] ++ (with inputs.self.hmModules; [
          alacritty-tmux
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
