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

        KEY_FLAG=""
        [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
        ${lib.getExe inputs'.nvfetcher.packages.default} $KEY_FLAG --keep-going -c nvfetcher.toml -o _sources "$@"
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
