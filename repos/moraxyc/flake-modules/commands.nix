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
        ${lib.getExe pkgs.nvfetcher} $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
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
