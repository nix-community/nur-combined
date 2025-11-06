{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      sops-nix,
      deploy-rs,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (flake-utils.lib) eachDefaultSystem mkApp;
      systems = flake-utils.lib.system;
      myPkgs = import ./packages;
    in
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        appPkgs =
          (
            if system == systems.x86_64-linux then
              {
                home-manager = home-manager.packages.${system}.default;
              }
            else
              { }
          )
          // {
            deploy = deploy-rs.packages.${system}.default;
          };
        platformPackages = myPkgs.packages {
          inherit pkgs inputs;
          filterByPlatform = true;
        };
        shellPackages =
          if system == systems.x86_64-linux then
            platformPackages
          else if system == systems.aarch64-linux then
            lib.getAttrs [
              "einat"
              "kcptun"
              "mosdns"
              "rtl8152-led-ctrl"
              "ubootNanopiR2s"
              "vlmcsd"
            ] platformPackages
          else
            { };
      in
      rec {
        packages = platformPackages;
        checks = platformPackages;
        apps = builtins.mapAttrs (name: drv: mkApp { inherit name drv; }) appPkgs;
        devShells.default = pkgs.mkShell {
          buildInputs = builtins.filter (f: f != null) (
            (builtins.attrValues shellPackages) ++ (builtins.attrValues appPkgs)
          );
        };
      }
    )
    // {
      overlays = myPkgs.overlays;

      nixosModules = import ./modules;

      homeConfigurations.eh5 = import ./homes/eh5 {
        system = systems.x86_64-linux;
        username = "eh5";
        inherit
          self
          nixpkgs
          home-manager
          inputs
          ;
      };

      nixosConfigurations = {
        nixos-r2s = import ./machines/r2s {
          system = systems.aarch64-linux;
          inherit self nixpkgs sops-nix;
        };
        nixos-srv-m = import ./machines/srv-m {
          system = systems.x86_64-linux;
          inherit self nixpkgs sops-nix;
        };
      };

      deploy.nodes.r2s = with deploy-rs.lib.aarch64-linux; {
        hostname = "r2s";
        sshUser = "root";
        fastConnection = true;
        profiles.system.path = activate.nixos self.nixosConfigurations.nixos-r2s;
      };
      deploy.nodes.srv-m = with deploy-rs.lib.x86_64-linux; {
        hostname = "srv-m";
        sshUser = "root";
        profiles.system.path = activate.nixos self.nixosConfigurations.nixos-srv-m;
      };
    };
}
