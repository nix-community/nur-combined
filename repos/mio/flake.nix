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
          lib = nixpkgs.lib;
          pkgs = nixpkgs.legacyPackages.${system};
          legacyPackages = lib.filterAttrs (_: v: lib.isDerivation v) self.legacyPackages.${system};
          isRunnable = value: lib.isDerivation value || builtins.isPath value || builtins.isString value;
          directUpdateScript =
            name: package:
            let
              updateScript = package.passthru.updateScript or null;
              command =
                if lib.isDerivation updateScript then
                  {
                    executable = lib.getExe updateScript;
                    arguments = [ ];
                  }
                else if
                  builtins.isList updateScript
                  && updateScript != [ ]
                  && isRunnable (builtins.head updateScript)
                  && builtins.all (argument: builtins.isString argument || builtins.isPath argument) (
                    builtins.tail updateScript
                  )
                then
                  {
                    executable =
                      if lib.isDerivation (builtins.head updateScript) then
                        lib.getExe (builtins.head updateScript)
                      else
                        builtins.toString (builtins.head updateScript);
                    arguments = builtins.tail updateScript;
                  }
                else
                  null;
            in
            if command == null then
              package
            else
              package.overrideAttrs (_: {
                passthru = (package.passthru or { }) // {
                  updateScript = pkgs.writeShellScriptBin "update-${name}" ''
                    exec ${command.executable} ${lib.escapeShellArgs command.arguments} "$@"
                  '';
                };
              });
        in
        lib.mapAttrs directUpdateScript legacyPackages
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
