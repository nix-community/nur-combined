_: {
  perSystem =
    {
      lib,
      pkgs,
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

        nvfetcher = ''
          set -euo pipefail
          KEY_FLAG=""
          [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
          [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
          export PYTHONPATH=${pkgs.python3Packages.packaging}/lib/python${pkgs.python3.pythonVersion}/site-packages:''${PYTHONPATH:-}
          ${lib.getExe pkgs.nvfetcher} $KEY_FLAG -c nvfetcher.toml -o _sources "$@"

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
          nix search . ^ --json | ${lib.getExe pkgs.jq} > nix-packages.json
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

        update-hashes = ''
          # Only check hashes that are not src hashes
          ATTRS=$(grep --files-with-matches "Hash = \"sha256-" \
            pkgs/kernel-modules/**/*.nix \
            pkgs/python-packages/**/*.nix \
            pkgs/uncategorized/**/*.nix \
            | xargs dirname | sort | uniq | xargs -n1 basename)

          for ATTR in $ATTRS; do
            echo "Updating $ATTR"
            ${lib.getExe pkgs.nix-update} --flake "$ATTR" --version skip
          done
        '';
      };
    };
}
