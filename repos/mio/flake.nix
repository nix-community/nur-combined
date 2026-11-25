{
  description = "My personal NUR repository";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/a98f368960a921d4fdc048e3a2401d12739bc1f9";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs.url = "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.zst";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  # The nova-nix source tree supplies the native Windows stdenv.  It is not a
  # flake, so it is fetched as a plain source input; flake-compat.nix resolves
  # it for nova-nix, which has no flake support.  The URL tracks the branch and
  # flake.lock pins the revision.
  inputs.nova-nix-src = {
    url = "github:Novavero-AI/nova-nix";
    flake = false;
  };
  outputs =
    {
      self,
      nixpkgs,
      nova-nix-src,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      packagesFor =
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system};
    in
    {
      # Built by nova-nix on Windows from the repository root:
      #   nova-nix build default.nix -A notepad-plus-plus --store C:\nix\store
      # Also reachable from the flake as
      # `nix eval .#windowsPackages.notepad-plus-plus.drvPath`.
      windowsPackages = {
        notepad-plus-plus = import ./windows.nix { inherit nova-nix-src; };
      };
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
      packages = forAllSystems packagesFor;
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
          wine4office = self.legacyPackages.x86_64-linux.wine4office-word.tests.nixos;
          flightdeck = self.legacyPackages.x86_64-linux.flightdeck.tests.nixos;
          # Droidloom host tools, module wiring, payload and lifecycle daemon.
          droidloom = self.legacyPackages.x86_64-linux.droidloom.tests.nixos;
          # lastbook_patched: boot the app under Xvfb and screenshot setup.
          lastbook-patched-setup =
            nixpkgs.legacyPackages.x86_64-linux.callPackage ./by-name/la/lastbook_patched/vm-test.nix
              {
                lastbook = self.legacyPackages.x86_64-linux.lastbook_patched;
              };
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
