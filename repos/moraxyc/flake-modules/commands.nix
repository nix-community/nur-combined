_: {
  perSystem =
    {
      pkgs,
      lib,
      config,
      inputs',
      ...
    }:
    let
      nvfetcher = pkgs.writeShellScriptBin "nvfetcher" ''
        set -euo pipefail
        KEY_FLAG=""
        [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
        ${inputs'.nvfetcher.packages.default}/bin/nvfetcher $KEY_FLAG --keep-going -c nvfetcher.toml -o _sources "$@"
      '';
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs =
          [
            nvfetcher
          ]
          ++ (with pkgs; [
            just
            nix-output-monitor
          ]);
      };
    };
}
