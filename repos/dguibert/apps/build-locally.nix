{
  config,
  inputs,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: let
    drv = let
      name = "build-locally-${builtins.replaceStrings ["/"] ["-"] pkgs.nixStore}";
    in
      pkgs.writeScriptBin name (with pkgs; let
      in ''
        #!${runtimeShell}
        host=$1
        drv=$2
        set -x
        ${config.apps.nix.program} nix copy --from $host --derivation $drv
        ${config.apps.nix.program} nix build -L --option extra-substituters $host?trusted=1 $drv^*
        ${config.apps.nix.program} nix copy --to $host $drv^* --no-check-sigs
      '');
  in {
    checks.app-build-locally = drv;
    apps.build-locally = inputs.flake-utils.lib.mkApp {
      inherit drv;
    };
  };
}
