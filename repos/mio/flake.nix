{
  description = "My personal NUR repository";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/a98f368960a921d4fdc048e3a2401d12739bc1f9";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs.url = "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.zst";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
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
      packages = forAllSystems (
        system:
          let
            pkgs = import nixpkgs { inherit system; };
            lib = pkgs.lib;
            legacy = self.legacyPackages.${system};
            filtered = lib.filterAttrs (_: v: lib.isDerivation v) legacy;
            wrapUpdateScript = name: pkg:
              if !(pkg ? passthru && pkg.passthru ? updateScript) then pkg
              else
                let raw = pkg.passthru.updateScript; in
                if lib.isDerivation raw then pkg
                else if lib.isList raw then
                  pkg // {
                    passthru = pkg.passthru // {
                      updateScript = pkgs.writeShellApplication {
                        name = "update-${name}";
                        text = ''
                          export UPDATE_NIX_ATTR_PATH="${name}"
                          exec ${lib.escapeShellArgs raw} "$@"
                        '';
                      };
                    };
                  }
                else if lib.isString raw || lib.isPath raw then
                  pkg // {
                    passthru = pkg.passthru // {
                      updateScript = pkgs.writeShellApplication {
                        name = "update-${name}";
                        text = ''
                          export UPDATE_NIX_ATTR_PATH="${name}"
                          exec ${raw} "$@"
                        '';
                      };
                    };
                  }
                else pkg;
          in lib.mapAttrs wrapUpdateScript filtered
      );
      cached = forAllSystems (system: self.legacyPackages.${system}.cached-set);
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
