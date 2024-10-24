_: {
  perSystem =
    {
      pkgs,
      lib,
      inputs',
      ...
    }:
    {
      commands = rec {
        ci = ''
          set -euo pipefail
          if [ "$1" == "" ]; then
            echo "Usage: ci <system>";
            exit 1;
          fi

          NIX_LOGFILE=nix-build-uncached.log

          # Workaround https://github.com/NixOS/nix/issues/6572
          SUBSTITUTED=1
          TRY_NUM=0
          while [ "$SUBSTITUTED" -eq 1 ]; do
            SUBSTITUTED=0
            TRY_NUM=$(( TRY_NUM + 1 ))

            echo "::group::Try $TRY_NUM: Building packages with nix-fast-build"
            ${pkgs.nix-fast-build}/bin/nix-fast-build -f .#ciPackages.$1 --skip-cached --no-nom 2>&1 | tee $NIX_LOGFILE && exit 0
            echo "::endgroup::"

            echo "::group::Try $TRY_NUM: Error log from nix-fast-build"
            grep "ERROR:nix_fast_build" $NIX_LOGFILE || true
            echo "::endgroup::"

            if grep -q "specified:" $NIX_LOGFILE; then
              if grep -q "got:" $NIX_LOGFILE; then
                SPECIFIED_HASH=($(grep "specified:" $NIX_LOGFILE | cut -d":" -f2 | xargs))
                GOT_HASH=($(grep "got:" $NIX_LOGFILE | cut -d":" -f2 | xargs))

                for (( i=0; i<''${#SPECIFIED_HASH[@]}; i++ )); do
                  SUBSTITUTED=1

                  echo "::group::Auto replace ''${SPECIFIED_HASH[@]:$i:1} with ''${GOT_HASH[@]:$i:1}"
                  echo "Auto replace ''${SPECIFIED_HASH[@]:$i:1} with ''${GOT_HASH[@]:$i:1}"
                  sed -i "s#''${SPECIFIED_HASH[@]:$i:1}#''${GOT_HASH[@]:$i:1}#g" $(find pkgs/ -name \*.nix) || true
                  echo "::endgroup::"

                  SPECIFIED_HASH_OLD=$(nix hash convert --to nix32 "''${SPECIFIED_HASH[@]:$i:1}" || nix hash to-base32 "''${SPECIFIED_HASH[@]:$i:1}")
                  echo "::group::Auto replace ''${SPECIFIED_HASH_OLD} with ''${GOT_HASH[@]:$i:1}"
                  echo "Auto replace ''${SPECIFIED_HASH_OLD} with ''${GOT_HASH[@]:$i:1}"
                  sed -i "s#''${SPECIFIED_HASH_OLD}#''${GOT_HASH[@]:$i:1}#g" $(find pkgs/ -name \*.nix) || true
                  echo "::endgroup::"
                done
              fi
            fi
            rm -f $NIX_LOGFILE
          done

          exit 1
        '';

        nvfetcher = ''
          set -euo pipefail
          KEY_FLAG=""
          [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
          [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
          export PYTHONPATH=${pkgs.python3Packages.packaging}/lib/python${pkgs.python3.pythonVersion}/site-packages:''${PYTHONPATH:-}
          ${inputs'.nvfetcher.packages.default}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
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

        search-lib = ''
          ${inputs'.nix-index-database.packages.default}/bin/nix-locate -w "$@" | grep -v "("
        '';

        trace = ''
          rm -rf trace.txt*
          strace -ff --trace=%file -o trace.txt "$@"
        '';

        update =
          let
            py = pkgs.python3.withPackages (p: with p; [ requests ]);
            path = lib.makeBinPath [
              pkgs.cargo
              pkgs.gitMinimal
              pkgs.nix-prefetch-git
              py
            ];
          in
          ''
            set -euo pipefail
            export PATH=${path}:$PATH
            echo "$PATH"
            nix flake update
            ${nvfetcher}
            for S in $(find pkgs/ -name update.sh); do
              echo "Executing $S"
              bash "$S"
            done
            for S in $(find pkgs/ -name update.py); do
              echo "Executing $S"
              ${py}/bin/python3 "$S"
            done
            ${readme}
          '';
      };
    };
}
