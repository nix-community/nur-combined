{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable/";
    hm-flatpak.url = "github:gmodena/nix-flatpak";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    asahi.url = "github:tpwrules/nixos-apple-silicon/1b16e4290a5e4a59c75ef53617d597e02078791e";
    asahi.inputs.nixpkgs.follows = "nixpkgs";

    # Nix darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, asahi, ... }@attrs: 
  let default_cfg = ({ pkgs, ... }: {
    # Zsh required for nix-darwin and nixos to work
    programs.zsh.enable = true;

    # Enable flakes and hard links
    nix.settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      show-trace = true;
      trusted-users = [ "@admin" "@wheel" "root" ];
    };
  
    environment.systemPackages = with pkgs; [
      android-tools
      htop
      git
      curl
      coreutils-full
      util-linux
      smartmontools
      pciutils
      wget
      bat
      unar
      nano
      python3
    ];
  }); in {
    nixosConfigurations."nix-isnt-xnu" = nixpkgs.lib.nixosSystem {
      specialArgs = attrs;
      modules = [
        default_cfg
        home-manager.nixosModules.home-manager
        asahi.nixosModules.apple-silicon-support
        ./devices/nix-isnt-xnu
        ./users/haruka
      ];
    };
  
    darwinConfigurations."walled-garden" = attrs.nix-darwin.lib.darwinSystem {
      modules = [
        default_cfg
        home-manager.darwinModules.home-manager
        ./devices/walled-garden
        ./users/haruka
      ];
    };
  };
}
