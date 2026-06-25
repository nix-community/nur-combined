{ config, ... }:
{
  perSystem =
    { final, ... }:
    let
      README = ../../README.md;
    in
    {
      packages = {
        bun2nix-js = final.pkgs.rustPlatform.buildRustPackage (finalAttrs: {
          pname = "bun2nix-js";
          inherit (config.cargoTOML.package) version;

          src = ../../programs/bun2nix;

          cargoLock = {
            lockFile = "${finalAttrs.src}/Cargo.lock";
          };

          bunDeps = final.bun2nix.fetchBunDeps {
            bunNix = "${finalAttrs.src}/bun.nix";
          };

          nativeBuildInputs = with final; [
            bun2nix.hook
            wasm-pack
            wasm-bindgen-cli_0_2_104
            binaryen
            cargo
            lld
            jq
          ];

          buildPhase = ''
            runHook preBuild

            bun run build

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir "$out"

            cp -R ./dist "$out"

            tail -n +5 "${README}" > "$out/dist/README.md"

            rm "$out/dist/.gitignore"

            runHook postInstall
          '';

          doCheck = true;

          checkPhase = ''
            runHook preCheck

            version="$(jq '.version' dist/package.json)"
            if ! [[ "$version" == "\"${config.cargoTOML.package.version}\"" ]]; then
              echo "Tag version \"$version\" does not match \"${config.cargoTOML.package.version}\" bun2nix js package'."
              exit 1
            fi

            runHook postCheck
          '';
        });
      };
    };
}
