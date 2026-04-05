{
  lib,
  writeTextFile,
  runtimeShell,
  ulypkgsPackages,
  packages ? ulypkgsPackages,
}:

writeTextFile {
  name = "update";

  destination = "/bin/update.sh";

  text = ''
    #!${runtimeShell}

    set -euo pipefail

    export NIX_GITHUB_PRIVATE_USERNAME="$GITHUB_TOKEN"
    export NIX_GITHUB_PRIVATE_PASSWORD=x-oauth-basic
    export NIX_ITCHIO_API_KEY="$ITCHIO_API_KEY"
    export NIX_MEGA_EMAIL="$MEGA_EMAIL"
    export NIX_MEGA_PASSWORD="$MEGA_PASSWORD"

    original="$(mktemp)"
    updates=()
    failedUpdates=()
    failedBuilds=()
  ''
  + lib.concatMapAttrsStringSep "\n" (
    attr: package:
    let
      updateScript' = package.passthru.updateScript or null;
      updateScript = if lib.isList updateScript' then lib.escapeShellArgs updateScript' else updateScript';
    in
    if !lib.isDerivation package then
      ''
        echo "update: Skip updating '${attr}' because it is not a derivation"
      ''
    else if updateScript == null then
      ''
        echo "update: Skip updating '${attr}' because it does not have passthru.updateScript specified"
      ''
    else
      ''
        echo "update: Updating '${attr}' (${package.name})..."
        old_version="$(nix-instantiate --eval -A ${attr}.version | cut -d'"' -f2)"
        echo "update: Current version: $old_version"

        file="$(nix-instantiate --eval -A ${attr}.meta.position | cut -d'"' -f2)"
        file="''${file%:[0-9]*}"
        cp "$file" "$original"

        if ${updateScript}; then
          echo "update: Updated '${attr}' successfully"
          new_version="$(nix-instantiate --eval -A ${attr}.version | cut -d'"' -f2)"
          echo "update: New version: $new_version"

          diff="$(diff --color=always "$original" "$file" || true)"
          if [[ -z "$diff" && "$old_version" == "$new_version" ]]; then
            echo "update: Diff is empty, version unchanged, skipping building"
          else
            updates+=(${attr})
            if [[ -n "$diff" ]]; then
              echo "update: Diff:"
              echo "$diff"
            else
              echo "update: No diff, but version changed"
            fi

            echo "update: Try building the new package..."
            if nix build .#${attr} --show-trace --print-build-logs; then
              echo "update: Built '${attr}' successfully"
              if [[ -n "$NIX_UPDATE_MAKE_COMMIT" ]]; then
                git add -A
                git commit -m "${attr}: $old_version -> $new_version"
              fi
            else
              echo "update: Failed to build '${attr}'"
              failedBuilds+=(${attr})
            fi
          fi

        else
          echo "update: Failed to update '${attr}'"
          failedUpdates+=(${attr})
        fi
      ''
  ) packages
  + ''
    rm "$original"

    set +u
    GITHUB_OUTPUT="''${GITHUB_OUTPUT:-}"
    set -u

    output_array() {
      if [[ -z "$GITHUB_OUTPUT" ]]; then
        return
      fi
      echo "$1<<ARRAY_DELIMITER" >> "$GITHUB_OUTPUT"
      shift
      for element in "$@"; do
        echo "$element" >> "$GITHUB_OUTPUT"
      done
      echo "ARRAY_DELIMITER" >> "$GITHUB_OUTPUT"
    }

    echo "update: All updated packages:"
    output_array updates "''${updates[@]}"

    if (( ''${#failedUpdates[@]} == 0 && ''${#failedBuilds[@]} == 0 )); then
      echo "update: All succeeded"
      if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "success=1" >> "$GITHUB_OUTPUT"
      fi

    else
      echo "update: Packages whose update scripts failed to run:"
      echo "''${failedUpdates[@]}"
      output_array failed-updates "''${failedUpdates[@]}"

      echo "update: Updated packages that failed to build:"
      echo "''${failedBuilds[@]}"
      output_array failed-builds "''${failedBuilds[@]}"

      if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "success=0" >> "$GITHUB_OUTPUT"
      fi
    fi
  '';

  executable = true;

  meta.description = "Script to update packages in this repository by running their update scripts and building the updated packages to verify the updates";
}
