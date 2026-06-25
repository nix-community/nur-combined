{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options.perSystem = mkPerSystemOption {
    options.fetchBunDeps.patchedDependenciesToOverrides = mkOption {
      description = ''
        Helper function that converts a `patchedDependencies` attribute set
        into a valid `overrides` set for use with `fetchBunDeps`.
      '';
      type = types.functionTo types.attrs;
      example = lib.literalExpression ''
        let
          src = ./.;
          packageJsonPath = ./package.json;
          packageJsonContents = lib.importJSON packageJsonPath;
          patchedDependencies = lib.mapAttrs (_: path: "''${src}/''${path}") (
            packageJsonContents.patchedDependencies or { }
          );
          patchOverrides = bun2nix.patchedDependenciesToOverrides {
            inherit patchedDependencies;
          };
        in
        bun2nix.fetchBunDeps {
          bunNix = ./bun.nix;
          overrides = patchOverrides;
        }
      '';
    };
  };

  config.perSystem =
    { pkgs, ... }:
    {
      fetchBunDeps.patchedDependenciesToOverrides =
        {
          patchedDependencies ? { },
        }:
        lib.mapAttrs (
          name: patchFile:
          let
            # Patch file paths may also contain '@' (e.g. @storybook+nextjs@10.3.5.patch),
            # so import them into the store with a sanitized name.
            safePatchFile = builtins.path {
              path = patchFile;
              name = lib.pipe patchFile [
                toString
                baseNameOf
                lib.strings.sanitizeDerivationName
                builtins.unsafeDiscardStringContext
              ];
            };
          in
          pkg:
          pkgs.runCommandLocal "patched-${lib.strings.sanitizeDerivationName name}"
            { nativeBuildInputs = [ pkgs.patch ]; }
            ''
              mkdir $out
              cp -r ${pkg}/. $out
              chmod -R u+w $out

              echo "Applying patch for ${name}..."
              patch -p1 -d $out < ${safePatchFile}
            ''
        ) patchedDependencies;
    };
}
