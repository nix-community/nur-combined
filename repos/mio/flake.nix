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
  inputs.claude-desktop-src = {
    url = "github:aaddrick/claude-desktop-debian/v3.3.20+claude6.28899.6";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };
  inputs.kytyps5-nixpkgs = {
    url = "https://nixos.org/channels/nixpkgs-26.05-darwin/nixexprs.tar.zst";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nova-nix-src,
      claude-desktop-src,
      kytyps5-nixpkgs,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
          config.permittedInsecurePackages = [
            "python-2.7.18"
          ];
        };
      packagesFor =
        system:
        let
          packages = import ./default.nix {
            pkgs = pkgsFor system;
            inherit inputs;
            no-ifd = true;
          };
        in
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) packages;
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
          pkgs = pkgsFor system;
          inherit inputs;
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
          packages = self.legacyPackages.x86_64-linux;
          cutefishTests = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/desktops/cutefish/tests.nix {
            cutefishModule = self.nixosModules.cutefish;
          };
          packageTests = builtins.concatLists (
            map (
              packageName:
              let
                package = packages.${packageName};
              in
              if nixpkgs.lib.isDerivation package && package ? tests && builtins.isAttrs package.tests then
                map (testName: {
                  name = "${packageName}-${testName}";
                  value = package.tests.${testName};
                }) (builtins.attrNames package.tests)
              else
                [ ]
            ) (builtins.attrNames packages)
          );
        in
        builtins.listToAttrs packageTests
        // {
          cutefish = cutefishTests.basic;
          cutefish-dm = cutefishTests.dm;
          cutefish-dm-greeter = cutefishTests.greeter;
          cutefish-dm-splash = cutefishTests.splash;
          # lastbook_patched: boot the app under Xvfb and screenshot setup.
          lastbook-patched-setup =
            nixpkgs.legacyPackages.x86_64-linux.callPackage ./by-name/la/lastbook_patched/vm-test.nix
              {
                lastbook = packages.lastbook_patched;
              };
          # quibble: boot each variant under OVMF and check the loader keeps the
          # console and draws its menu (see by-name/qu/quibble/vm-test.nix).
          quibble-vm-boot = nixpkgs.legacyPackages.x86_64-linux.callPackage ./by-name/qu/quibble/vm-test.nix {
            quibble = packages.quibble;
          };
          quibble-patched-vm-boot =
            nixpkgs.legacyPackages.x86_64-linux.callPackage ./by-name/qu/quibble/vm-test.nix
              {
                quibble = packages.quibble_patched;
              };
          quibble-win11-vm-boot =
            nixpkgs.legacyPackages.x86_64-linux.callPackage ./by-name/qu/quibble/vm-test.nix
              {
                quibble = packages.quibble_win11;
              };
          quibble-win11-patched-vm-boot =
            nixpkgs.legacyPackages.x86_64-linux.callPackage ./by-name/qu/quibble/vm-test.nix
              {
                quibble = packages.quibble_win11_patched;
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
            inherit inputs;
          };
        in
        ppp.cached-set
      );
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
