{
  config,
  ...
}:
let
  rootConfig = config;
in
{
  perSystem =
    { pkgs, config, ... }:
    let
      inherit (pkgs) lib;
    in
    {
      packages = rec {
        bun2nix = pkgs.rustPlatform.buildRustPackage (
          finalAttrs:
          let
            pkgInfo = rootConfig.cargoTOML.package;
          in
          {
            pname = pkgInfo.name;
            inherit (pkgInfo) version;

            src = ../programs/bun2nix;

            cargoLock = {
              lockFile = "${finalAttrs.src}/Cargo.lock";
            };

            passthru = with config; {
              inherit (mkDerivation) hook;
              inherit writeBunScriptBin writeBunApplication;

              fetchBunDeps = fetchBunDeps.function;
              mkDerivation = mkDerivation.function;
              inherit (fetchBunDeps) patchedDependenciesToOverrides;
            };

            meta = {
              description = "A fast rust based bun lockfile to nix expression converter.";
              homepage = "https://github.com/nix-community/bun2nix";
              license = lib.licenses.mit;
              maintainers = [ lib.maintainers.baileylu ];
              mainProgram = "bun2nix";
            };
          }
        );
        default = bun2nix;
      };
    };

}
