# Standalone nixpkgs overlay, without the NUR namespace.
_final: prev:
let
  nur = import ./default.nix { pkgs = prev; };
in
removeAttrs nur [ "overlays" ]
// {
  # aws-lc-sys is forced to use a system library by nixpkgs' Cargo hook.
  # Codex needs AWS-LC itself on Darwin; OpenSSL is not a compatible substitute.
  codex =
    let
      hasAwsLc = builtins.any (
        input: prev.lib.getName input == prev.lib.getName prev.aws-lc
      ) (prev.codex.buildInputs or [ ]);
    in
    # Pass through upstream unchanged once it includes AWS-LC on Darwin.
    if !prev.stdenv.hostPlatform.isDarwin || hasAwsLc then
      prev.codex
    else
      prev.codex.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ prev.aws-lc ];
      });

  scooter =
    let
      hasInput = inputs: pkg: builtins.any (input: prev.lib.getName input == prev.lib.getName pkg) inputs;
      missingNative = prev.lib.optional (
        !(hasInput prev.scooter.nativeBuildInputs prev.pkg-config)
      ) prev.pkg-config;
      missingBuild = prev.lib.optional (
        !(hasInput prev.scooter.buildInputs prev.oniguruma)
      ) prev.oniguruma;
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
