{
  lib,
  selfLib,
  writeShellApplication,
  nvfetcher-self,
  nvfetcher-changes-commit,
  gawk,
  path,
  selfPackages,
  tmpDir ? "/tmp/linyinfeng-nur-packages-update",
  changelogFile ? "${tmpDir}/changelog",
  nvfetcherChangelogFile ? "${tmpDir}/nvfetcher-changelog",
  updateScriptCommitMessageFile ? "${tmpDir}/commit-message",
  alternativeOutputFile ? "${tmpDir}/github-output",
  nvcheckerKeyFile ? "keyfile.toml",
}:

let
  updateScripts = selfLib.getUpdateScripts selfPackages;
  escapedUpdateScripts = map lib.escapeShellArgs updateScripts;
in
writeShellApplication {
  name = "update";
  runtimeInputs = [
    gawk
    nvfetcher-self
    nvfetcher-changes-commit
  ];
  text = ''
    export NIX_PATH="nixpkgs=${path}"

    rm -rf "${tmpDir}"
    mkdir -p "${tmpDir}"
    if [ -z "$GITHUB_OUTPUT" ]; then
      OUTPUT_FILE="${alternativeOutputFile}"
    else
      OUTPUT_FILE="$GITHUB_OUTPUT"
    fi

    # setup git
    function commit {
      git add --all
      git commit "$@"
    }

    ## update scripts
    echo "run update scripts"
    function handle_update_script {
      if [ -f "${updateScriptCommitMessageFile}" ]; then
        rm "${updateScriptCommitMessageFile}"
      fi
      "$@" --write-commit-message "${updateScriptCommitMessageFile}"
      if [ -f "${updateScriptCommitMessageFile}" ]; then
        nix fmt
        commit --file="${updateScriptCommitMessageFile}"
        cat "${updateScriptCommitMessageFile}" >> "${changelogFile}"
        rm "${updateScriptCommitMessageFile}"
      fi
    }
    ${lib.concatStringsSep "\n" (map (s: "handle_update_script ${s}") escapedUpdateScripts)}

    # remove old Cargo.lock files
    pushd pkgs/_sources
    rm -f ./*/Cargo.lock
    popd

    ## run nvfetcher
    echo "run nvfetcher"
    NVCHECKER_EXTRA_OPTIONS=()
    if [ -f "${nvcheckerKeyFile}" ]; then
      NVCHECKER_EXTRA_OPTIONS+=("--keyfile" "$(realpath "${nvcheckerKeyFile}")")
    fi
    pushd pkgs;
    set -x
    nvfetcher-self "''${NVCHECKER_EXTRA_OPTIONS[@]}";
    set +x
    popd
    nix fmt

    # get changelog
    nvfetcher-changes-commit "pkgs/_sources/generated.nix" > "${nvfetcherChangelogFile}"
    cat "${nvfetcherChangelogFile}" >> "${changelogFile}"

    ## nix flake update
    # do nix flake update if sources were updated
    if [ -n "$(cat "${changelogFile}")" ]; then
      echo "update flake inputs"
      nix flake update --commit-lock-file
    fi

    ## write to env file
    echo "writing information to $OUTPUT_FILE"
    echo "changelog<<EOF" > "$OUTPUT_FILE"
    awk 1 "${changelogFile}" >> "$OUTPUT_FILE" # add missing newline automatically
    echo "EOF" >> "$OUTPUT_FILE"
  '';
  meta = with lib; {
    platforms = nvfetcher-self.meta.platforms;
    maintainers = with maintainers; [ yinfeng ];
  };
}
