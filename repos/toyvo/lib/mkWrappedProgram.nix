/**
  Create a standalone wrapped program that bundles configuration.

  Usage:
    lib.mkWrappedProgram pkgs {
      name = "my-helix";
      package = pkgs.helix;
      configDir = pkgs.writeTextDir ".config/helix/config.toml" ''...'';
      envVars = { HELIX_RUNTIME = "${pkgs.helix}/lib/runtime"; };
      runtimeDeps = [ pkgs.git pkgs.ripgrep ];
      extraBinaries = [ "helix" ];
    }

  This produces a package where the binary is wrapped to use the
  provided config directory, making it runnable via `nix run` on
  any machine without installing anything system-wide.
*/

{ pkgs, ... }:

let
  inherit (pkgs) lib runCommand makeWrapper;
in

{
  name,
  package,
  binaryName ? package.meta.mainProgram or (lib.getName package),
  configDir ? null,
  envVars ? { },
  extraFlags ? [ ],
  runtimeDeps ? [ ],
  extraBinaries ? [ ],
}:

runCommand name
  {
    nativeBuildInputs = [ makeWrapper ];
    meta = package.meta // {
      description = "${package.meta.description or binaryName} with bundled configuration";
    };
  }
  ''
    mkdir -p $out/bin

    makeWrapper ${lib.getExe package} $out/bin/${binaryName} \
      ${lib.optionalString (configDir != null) "--set XDG_CONFIG_HOME ${configDir}"} \
      ${lib.optionalString (runtimeDeps != [ ]) "--prefix PATH : ${lib.makeBinPath runtimeDeps}"} \
      ${lib.concatMapStringsSep " " (n: "--set ${n} \"${envVars.${n}}\"") (lib.attrNames envVars)} \
      ${lib.concatMapStringsSep " " (flag: "--add-flags \"${flag}\"") extraFlags}

    ${lib.concatMapStringsSep "\n" (
      binName: "ln -s $out/bin/${binaryName} $out/bin/${binName}"
    ) extraBinaries}
  ''
