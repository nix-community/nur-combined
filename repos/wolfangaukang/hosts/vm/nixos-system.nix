{ username, system, overlays }:
inputs: {
  inherit system;

  modules = [
    ./configuration.nix
    #inputs.home-manager.nixosModules.home-manager {
    #  home-manager = {
    #    useGlobalPkgs = true;
    #    useUserPackages = true;
    #    sharedModules = [
    #      inputs.sab.hmModule
    #    ] ++ (with inputs.self.hmModules; [
    #      alacritty-tmux
    #      neofetch
    #    ]);
    #    users."${username}" = import ./home-manager.nix;
    #  };
    #  nixpkgs = {
    #    config.allowUnfree = true;
    #    overlays = overlays;
    #  };
    #}
  ];
}
