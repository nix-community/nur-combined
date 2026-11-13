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
            pkgs.bash
            pkgs.coreutils
            pkgs.gawk
            pkgs.gh
            pkgs.git
            pkgs.gnugrep
            pkgs.gnused
            pkgs.pnpm_11
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
