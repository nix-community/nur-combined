{pkgs}: let
  system = pkgs.stdenv.hostPlatform.system;
  script = pkgs.writeShellApplication {
    name = "update-pins";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.jq
      pkgs.nix
    ];
    text = ''
      # Run package-provided updaters for coupled URL and hash pins from the unfiltered package set.

      # Usage:
      #   nix run .#update-pins                 # run every pin updater
      #   nix run .#update-pins -- <name> ...   # run only these, with
      #                                         # forced re-prefetch
      if [[ ! -f flake.nix || ! -d pkgs ]]; then
        echo "ERROR: update-pins must be run from the repository root" >&2
        exit 1
      fi

      # Use getAttr for non-identifier package names and preserve evaluation failures.
      names_json=$(
        nix eval --json ".#legacyPackages.${system}" --apply '
          pkgs: builtins.filter
            (n: ((builtins.getAttr n pkgs).pinUpdater or null) != null)
            (builtins.attrNames pkgs)
        '
      )
      mapfile -t all < <(jq -r '.[]' <<<"$names_json")

      declare -A forced=()
      for arg in "$@"; do
        forced[$arg]=1
      done

      selected=()
      if [[ ''${#forced[@]} -gt 0 ]]; then
        # Force named packages and reject unknown names.
        bad=0
        for arg in "$@"; do
          found=0
          for name in "''${all[@]}"; do
            if [[ $name == "$arg" ]]; then
              found=1
              break
            fi
          done
          if [[ $found -eq 1 ]]; then
            selected+=("$arg")
          else
            echo "WARNING: $arg does not exist or exposes no passthru.pinUpdater" >&2
            bad=1
          fi
        done
        if [[ $bad -ne 0 || ''${#selected[@]} -eq 0 ]]; then
          exit 1
        fi
      else
        selected=("''${all[@]}")
      fi

      if [[ ''${#selected[@]} -eq 0 ]]; then
        echo "No packages with passthru.pinUpdater; nothing to do"
        exit 0
      fi

      for name in "''${selected[@]}"; do
        echo "Updating pins for $name"
        # Use getFlake/getAttr because nix build lacks `--apply`.
        updater=$(
          nix build --no-link --print-out-paths --impure --expr "
            (builtins.getAttr \"$name\"
              (builtins.getFlake (toString ./.)).legacyPackages.${system}).pinUpdater"
        )
        # Run the updater's sole executable.
        bin=$(find "$updater/bin" -maxdepth 1 \( -type f -o -type l \) | head -n 1)
        if [[ ''${#forced[@]} -gt 0 ]]; then
          "$bin" --force
        else
          "$bin"
        fi
      done
    '';
  };
in {
  update-pins = {
    type = "app";
    program = "${script}/bin/update-pins";
    meta.description = "Refresh package pins (coupled URL+hash data) via passthru.pinUpdater executables";
  };
}
