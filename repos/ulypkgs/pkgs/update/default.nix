{
  lib,
  writeTextFile,
  runtimeShell,
  ulypkgsPackages,
  basePath ? toString ../..,
  packages ? ulypkgsPackages,
}:

writeTextFile {
  name = "update";

  destination = "/bin/update.sh";

  text = ''
    #!${runtimeShell}

    set -euo pipefail

    export NIX_GITHUB_PRIVATE_USERNAME="''${GITHUB_TOKEN-}"
    export NIX_GITHUB_PRIVATE_PASSWORD=x-oauth-basic
    export NIX_ITCHIO_API_KEY="''${ITCHIO_API_KEY-}"
    export NIX_MEGA_EMAIL="''${MEGA_EMAIL-}"
    export NIX_MEGA_PASSWORD="$''${MEGA_PASSWORD-}"

    original="$(mktemp)"
    updates=()
    failedUpdates=()
    failedBuilds=()
    scriptsRun=()
  ''
  + lib.concatMapAttrsStringSep "\n" (
    attr: package:
    let
      updateScriptFile = (builtins.unsafeGetAttrPos "updateScript" package).file;
      updateScript' =
        if
          package ? updateScript
          && lib.hasPrefix basePath updateScriptFile
          && lib.hasPrefix updateScriptFile package.meta.position
        then
          package.updateScript.command or package.updateScript
        else
          null;
      updateScript =
        if updateScript' != null then lib.escapeShellArgs (lib.toList updateScript') else null;
    in
    if !lib.isDerivation package then
      ''
        echo "update: Skip updating '${attr}' because it is not a derivation"
      ''
    else if updateScript == null then
      ''
        echo "update: Skip updating '${attr}' because it does not have passthru.updateScript specified in the repo"
      ''
    else
      ''
        echo "update: Updating '${attr}' (${package.name})..."
        old_version="$(nix-instantiate --eval -A ${attr}.version | cut -d'"' -f2)"
        echo "update: Current version: $old_version"

        file="$(nix-instantiate --eval -A ${attr}.meta.position | cut -d'"' -f2)"
        file="''${file%:[0-9]*}"
        cp "$file" "$original"

        export UPDATE_NIX_NAME="${package.name}"
        export UPDATE_NIX_PNAME="${package.pname or ""}"
        export UPDATE_NIX_OLD_VERSION="${package.version or ""}"
        export UPDATE_NIX_ATTR_PATH="${attr}"

        if [[ " ''${scriptsRan[*]} " =~ " ${updateScript} " ]]; then
          echo "update: Skip updating '${attr}' because its update script has already run"
        elif script --return --log-out "${attr}.update.log" --command ${lib.escapeShellArg updateScript}; then
          scriptsRan+=(${lib.escapeShellArg updateScript})

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
            if script --return --log-out "${attr}.build.log" --command 'nix build .#${attr} --show-trace --print-build-logs'; then
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
          scriptsRan+=(${updateScript})

          echo "update: Failed to update '${attr}'"
          failedUpdates+=(${attr})
        fi
      ''
  ) packages
  + ''
    rm "$original"

    set +u
    GITHUB_OUTPUT="''${GITHUB_OUTPUT:-}"
    GITHUB_STEP_SUMMARY="''${GITHUB_STEP_SUMMARY:-}"
    set -u

    output_title() {
      echo "update: $1:"
      if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
        echo "## $1" >> "$GITHUB_STEP_SUMMARY"
        echo >> "$GITHUB_STEP_SUMMARY"
      fi
      if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "$2<<CHIMICHERRYCHANGA_ARRAY_DELIMITER" >> "$GITHUB_OUTPUT"
      fi
    }

    output_array() {
      for element in "$@"; do
        echo "$element"
        if [[ -n "$GITHUB_OUTPUT" ]]; then
          echo "$element" >> "$GITHUB_OUTPUT"
        fi
        if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
          echo "- $element" >> "$GITHUB_STEP_SUMMARY"
        fi
      done
      if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "CHIMICHERRYCHANGA_ARRAY_DELIMITER" >> "$GITHUB_OUTPUT"
      fi
      if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
        echo >> "$GITHUB_STEP_SUMMARY"
      fi
    }

    output_title "All updated packages" updates
    output_array "''${updates[@]}"

    if (( ''${#failedUpdates[@]} == 0 && ''${#failedBuilds[@]} == 0 )); then
      echo "update: All succeeded"
      if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "success=1" >> "$GITHUB_OUTPUT"
      fi

    else
      output_title "Packages whose update scripts failed to run" failed-updates
      output_array "''${failedUpdates[@]}"

      output_title "Updated packages that failed to build" failed-builds
      output_array "''${failedBuilds[@]}"

      if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "success=0" >> "$GITHUB_OUTPUT"
      fi
    fi

    if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
      echo "## Logs" >> "$GITHUB_STEP_SUMMARY"
      echo >> "$GITHUB_STEP_SUMMARY"
      echo "### Update script logs" >> "$GITHUB_STEP_SUMMARY"
      echo >> "$GITHUB_STEP_SUMMARY"
      shopt -s nullglob
      for log in *.update.log; do
        attr="$(basename "$log" .update.log)"
        echo "<details><summary>$attr</summary>" >> "$GITHUB_STEP_SUMMARY"
        echo >> "$GITHUB_STEP_SUMMARY"
        echo '``````console' >> "$GITHUB_STEP_SUMMARY"
        cat "$log" >> "$GITHUB_STEP_SUMMARY"
        echo '``````' >> "$GITHUB_STEP_SUMMARY"
        echo >> "$GITHUB_STEP_SUMMARY"
      done
      echo "### Build logs" >> "$GITHUB_STEP_SUMMARY"
      echo >> "$GITHUB_STEP_SUMMARY"
      for log in *.build.log; do
        attr="$(basename "$log" .build.log)"
        echo "<details><summary>$attr</summary>" >> "$GITHUB_STEP_SUMMARY"
        echo >> "$GITHUB_STEP_SUMMARY"
        echo '``````console' >> "$GITHUB_STEP_SUMMARY"
        cat "$log" >> "$GITHUB_STEP_SUMMARY"
        echo '``````' >> "$GITHUB_STEP_SUMMARY"
        echo >> "$GITHUB_STEP_SUMMARY"
      done
      shopt -u nullglob
    fi
  '';

  executable = true;

  meta.description = "Script to update packages in this repository by running their update scripts and building the updated packages to verify the updates";
}
