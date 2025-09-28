{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    let
      mkCICommand = pkgsAttr: ''
        tools/auto_build.py ${pkgsAttr} "$@"
      '';
    in
    {
      commands = rec {
        ci = mkCICommand "ciPackages";
        ci-cuda = mkCICommand "ciPackagesWithCuda";

        nix-update = ''
          nix-shell \
            ${inputs.nixpkgs.outPath}/maintainers/scripts/update.nix \
            --arg include-overlays "[(final: prev: import $(pwd)/pkgs null { pkgs = prev; })]" \
            --argstr skip-prompt true \
            --argstr path "$@"
        '';

        nvfetcher = ''
          set -euo pipefail
          KEY_FLAG=""
          [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
          [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
          export PYTHONPATH=${pkgs.python3Packages.packaging}/lib/python${pkgs.python3.pythonVersion}/site-packages:''${PYTHONPATH:-}
          ${inputs'.nvfetcher.packages.default}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"

          python3 tools/postprocess_nvfetcher.py

          ${readme}
        '';

        nur-check = ''
          set -euo pipefail
          TMPDIR=$(mktemp -d)
          FLAKEDIR=$(pwd)

          git clone --depth=1 https://github.com/nix-community/NUR.git "$TMPDIR"
          cd "$TMPDIR/ci"
          nix flake update
          cd "$TMPDIR"
          sed -i "s/-p python3 /-p python311 /g" "$TMPDIR/bin/nur"

          cp ${../../repos.json} repos.json
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
          nix search . ^ --json | ${pkgs.jq}/bin/jq > nix-packages.json
        '';

        trace = ''
          rm -rf trace.txt*
          strace -ff --trace=%file -o trace.txt "$@"
        '';

        update = ''
          set -euo pipefail
          export LANG=en_US.UTF-8
          nix flake update
          ${nvfetcher}
          for S in $(find pkgs/ -name update.\*); do
            echo "Executing $S"
            chmod +x "$S"
            "$S"
          done
          ${readme}
        '';
      };
    };
}
