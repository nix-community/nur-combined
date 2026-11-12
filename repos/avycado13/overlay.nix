# Standalone nixpkgs overlay, without the NUR namespace.
_final: prev:
let
  nur = import ./default.nix { pkgs = prev; };
in
removeAttrs nur [ "overlays" ]
// {
  scooter =
    let
      hasInput = inputs: pkg: builtins.any (input: prev.lib.getName input == prev.lib.getName pkg) inputs;
      missingNative = prev.lib.optional (!(hasInput prev.scooter.nativeBuildInputs prev.pkg-config)) prev.pkg-config;
      missingBuild = prev.lib.optional (!(hasInput prev.scooter.buildInputs prev.oniguruma)) prev.oniguruma;
    in
    # Pass through upstream unchanged once it declares both dependencies.
    if missingNative == [ ] && missingBuild == [ ] then
      prev.scooter
    else
      prev.scooter.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ missingNative;
        buildInputs = (old.buildInputs or [ ]) ++ missingBuild;
      });
}
