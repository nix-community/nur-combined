_: {
  perSystem =
    {
      lib,
      pkgs,
      config,
      inputs',
      ...
    }:
    let
      updater = pkgs.writeShellScriptBin "update-packages" ''
        set -euo pipefail
        export NIXPKGS_ALLOW_UNFREE=1
        export PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.gh
          ]
        }:$PATH

        exec ${lib.getExe inputs'.fetchrix.packages.default} --config fetchrix.toml --out-dir _sources update "$@"
      '';
    in
    {
      devShells.default = pkgs.mkShell {
        inherit (config.pre-commit.settings) shellHook;
        nativeBuildInputs = config.pre-commit.settings.enabledPackages;
        buildInputs = with pkgs; [
          updater
          just
          nix-output-monitor
        ];
      };
    };
}
