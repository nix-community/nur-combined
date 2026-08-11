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
      # Generic package pin runner. A "pin" is data whose URL and hash
      # must change together (unlike the static-URL vendored hashes
      # handled by update-hashes/nix-update). Packages that have such
      # data expose an executable as passthru.pinUpdater; this runner
      # discovers them in the current system's flake package set, builds
      # the updaters and runs them from the repository root. Each updater
      # owns exactly the pin files in its own package directory; this
      # script contains no package-specific logic.
      #
      # Discovery uses legacyPackages (the unfiltered package set), not
      # packages: the latter drops platform-restricted packages on other
      # systems (e.g. the Linux-only wsrx-desktop on darwin), while pin
      # updaters themselves are platform-independent scripts.
      #
      # Usage:
      #   nix run .#update-pins                 # run every pin updater
      #   nix run .#update-pins -- <name> ...   # run only these, with
      #                                         # forced re-prefetch
      if [[ ! -f flake.nix || ! -d pkgs ]]; then
        echo "ERROR: update-pins must be run from the repository root" >&2
        exit 1
      fi

      # Dynamic lookup via --apply/getAttr: Nix's flake-fragment parser
      # cannot address attribute names that are not plain identifiers
      # (e.g. icalingua++), while builtins.getAttr handles any string.
      # Not a process substitution: a failed nix eval must abort the run
      # (set -e), not masquerade as "no updaters found".
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
        # Explicitly named packages run with --force (the escape hatch
        # for upstream asset drift or fetcher behavior changes). A name
        # that matches no pinUpdater is almost certainly a typo; fail
        # instead of silently doing nothing.
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
        # --impure --expr with builtins.getFlake (same pattern as
        # update-lockfiles): nix build has no --apply flag, and flake
        # fragments cannot express names like icalingua++.
        updater=$(
          nix build --no-link --print-out-paths --impure --expr "
            (builtins.getAttr \"$name\"
              (builtins.getFlake (toString ./.)).legacyPackages.${system}).pinUpdater"
        )
        # writeShellApplication installs a single executable under bin/.
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
