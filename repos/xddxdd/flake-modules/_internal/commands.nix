_: {
  perSystem =
    _:
    let
      mkCICommand = pkgsAttr: ''
        tools/auto_build.py ${pkgsAttr} "$@"
      '';
    in
    {
      commands = rec {
        ci = mkCICommand "ciPackages";
        ci-cuda = mkCICommand "ciPackagesWithCuda";

        # Run passthru.updateScript-based updates (migrated packages).
        # Accepts the same arguments as tools/update-package.
        update-pkg = ''
          set -euo pipefail
          ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo .)
          "$ROOT"/tools/update-package "$@"
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
          set -uo pipefail
          nix build --show-trace .#_meta.readme
          cat result > README.md
        '';

        trace = ''
          rm -rf trace.txt*
          strace -ff --trace=%file -o trace.txt "$@"
        '';

        update = ''
          set -uo pipefail
          export LANG=en_US.UTF-8
          nix flake update
          # nix-update and the update-script shebangs need <nixpkgs>; pin it to the
          # freshly locked tree rather than the runner's ambient channel.
          export NIX_PATH=nixpkgs=$(nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).inputs.nixpkgs.outPath')
          is_allowed() {
            [ -f tools/auto-update-allowed-failures.txt ] &&
              grep -qxF "$1" tools/auto-update-allowed-failures.txt
          }
          STATUS=0
          FAILED=""
          ALLOWED_FAILED=""
          for S in $(command find pkgs/ \( -name 'update-standalone.*' \) -type f | sort); do
            echo "Executing $S"
            chmod +x "$S"
            if "$S"; then
              continue
            fi
            if is_allowed "$(basename "$(dirname "$S")")"; then
              ALLOWED_FAILED="$ALLOWED_FAILED $S"
              echo ">>> $S: FAILED (allowed)" >&2
            else
              FAILED="$FAILED $S"
              echo ">>> $S: FAILED" >&2
            fi
          done
          ./tools/update-package --all || STATUS=$?
          # Regenerate README even when individual updates failed
          ${readme}
          if [ -n "$ALLOWED_FAILED" ]; then
            echo "Allowed failures:$ALLOWED_FAILED" >&2
          fi
          if [ -n "$FAILED" ] || [ "$STATUS" -ne 0 ]; then
            [ -n "$FAILED" ] && echo "Finished with failures:$FAILED" >&2
            exit 1
          fi
          [ -z "$ALLOWED_FAILED" ] && echo "All update scripts finished successfully."
          exit 0
        '';
      };
    };
}
