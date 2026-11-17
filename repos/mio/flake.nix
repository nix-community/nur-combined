{
  description = "My personal NUR repository";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/a98f368960a921d4fdc048e3a2401d12739bc1f9";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs.url = "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.zst";
  # KytyPS5's macOS build is x86-64 only, and nixpkgs 26.11 dropped
  # x86_64-darwin, so it is packaged from the last branch that still has it.
  inputs.nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      kytyps5Darwin =
        (import nixpkgs-darwin {
          system = "x86_64-darwin";
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        }).callPackage
          ./by-name/ky/kytyps5/package.nix
          { };
      packagesFor =
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system};
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.android_sdk.accept_license = true;
            config.permittedInsecurePackages = [
              "python-2.7.18"
            ];
          };
          no-ifd = false;
        }
      );
      packages = forAllSystems packagesFor // {
        # The emulator only builds for x86-64 macOS; Apple Silicon runs it
        # under Rosetta 2, so expose the same derivation for both systems.
        aarch64-darwin = (packagesFor "aarch64-darwin") // {
          kytyps5 = kytyps5Darwin;
        };
        x86_64-darwin = {
          kytyps5 = kytyps5Darwin;
        };
      };
      nixosModules = import ./modules;
      homeModules = import ./home-modules;
      homeManagerModules = self.homeModules;
      cached = forAllSystems (system: self.legacyPackages.${system}.cached-set);
      # The miodroid NixOS VM tests are the only real gate on that fork: they
      # boot Android in a container in both rootful and rootless mode and wait
      # for sys.boot_completed.  They are x86_64-only (the OTA images are
      # x86_64) and heavy: each run downloads ~1.5 GiB of images and needs KVM.
      checks.x86_64-linux =
        let
          cutefishTests = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/desktops/cutefish/tests.nix {
            cutefishModule = self.nixosModules.cutefish;
          };
        in
        {
          miodroid-nixos = self.legacyPackages.x86_64-linux.miodroid.tests.nixos;
          miodroid-nixos-rootless = self.legacyPackages.x86_64-linux.miodroid.tests.nixos-rootless;
          miodroid-nixos-rootless-grow = self.legacyPackages.x86_64-linux.miodroid.tests.nixos-rootless-grow;
          miodroid-desktop-sockets = self.legacyPackages.x86_64-linux.miodroid.tests.desktop-sockets;
          cutefish = cutefishTests.basic;
          cutefish-dm = cutefishTests.dm;
          cutefish-dm-greeter = cutefishTests.greeter;
          cutefish-dm-splash = cutefishTests.splash;
          # Wine mkWindowsApp packages: X11 + FUSE overlay smoke tests.
          notepad-plus-plus = self.legacyPackages.x86_64-linux.notepad-plus-plus.tests.nixos;
          capcut = self.legacyPackages.x86_64-linux.capcut.tests.nixos;
          capcut_5 = self.legacyPackages.x86_64-linux.capcut_5.tests.nixos;
          adobe-acrobat-reader = self.legacyPackages.x86_64-linux.adobe-acrobat-reader.tests.nixos;
          # Droidloom host tools, module wiring, payload and lifecycle daemon.
          droidloom = self.legacyPackages.x86_64-linux.droidloom.tests.nixos;
        };
      cached-cuda = forAllSystems (
        system:
        let
          ppp = import ./default.nix {
            pkgs = import nixpkgs {
              config.allowUnfree = true;
              config.android_sdk.accept_license = true;
              config.cudaSupport = true;
              inherit system;
            };
          };
        in
        ppp.cached-set
      );
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
