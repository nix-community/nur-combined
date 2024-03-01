{
  self,
  lib,
  ...
}: {
  perSystem = {
    config,
    system,
    pkgs,
    ...
  }: let
    commands = rec {
      ci = ''
        set -euo pipefail
        if [ "$1" == "" ]; then
          echo "Usage: ci <system>";
          exit 1;
        fi

        # Workaround https://github.com/NixOS/nix/issues/6572
        for i in {1..3}; do
          ${pkgs.nix-build-uncached}/bin/nix-build-uncached ci.nix -A $1 --show-trace && exit 0
        done

        exit 1
      '';

      garnix = ''
        nix eval --raw .#garnixConfig | ${pkgs.jq}/bin/jq > garnix.yaml
      '';

      nvfetcher = ''
        set -euo pipefail
        KEY_FLAG=""
        [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
        [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
        export PATH=${pkgs.nvchecker}/bin:${pkgs.nix-prefetch-scripts}/bin:$PATH
        ${pkgs.nvfetcher}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
        ${readme}
      '';

      nur-check = ''
        set -euo pipefail
        TMPDIR=$(mktemp -d)
        FLAKEDIR=$(pwd)

        git clone --depth=1 https://github.com/nix-community/NUR.git "$TMPDIR"
        cd "$TMPDIR"

        cp ${../repos.json} repos.json
        rm -f repos.json.lock

        bin/nur update
        bin/nur eval "$FLAKEDIR"

        git clone --single-branch "https://github.com/nix-community/nur-combined.git"
        cp repos.json repos.json.lock nur-combined/
        bin/nur index nur-combined > index.json

        cd "$FLAKEDIR"
        rm -rf "$TMPDIR"
      '';

      readme = ''
        set -euo pipefail
        nix build .#_meta.readme
        cat result > README.md
        ${garnix}
      '';

      trace = ''
        rm -rf trace.txt*
        strace -ff --trace=%file -o trace.txt "$@"
      '';

      update = let
        py = pkgs.python3.withPackages (p: with p; [requests]);
      in ''
        set -euo pipefail
        nix flake update
        ${nvfetcher}
        ${py}/bin/python3 pkgs/asterisk-digium-codecs/update.py
        # ${py}/bin/python3 pkgs/nvidia-grid/update.py
        ${py}/bin/python3 pkgs/openj9-ibm-semeru/update.py
        ${py}/bin/python3 pkgs/openjdk-adoptium/update.py
        ${readme}
      '';
    };

    makeAppsShell = pkgs.callPackage ../helpers/make-apps-shell.nix {};
  in rec {
    apps =
      lib.mapAttrs (n: v: {
        type = "app";
        program = pkgs.writeShellScriptBin n v;
      })
      commands;

    devShells.default = makeAppsShell apps;
  };
}
