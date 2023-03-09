{ lib
, selfLib
, writeShellScriptBin
, nixVersions
, nixpkgs-fmt
, nix-prefetch
, nix-update
, nvfetcher-changes-commit
, path
, repoPackages
, tmpDir ? "/tmp/linyinfeng-nur-packages-update"
, changelogFile ? "${tmpDir}/changelog"
, updaterChangelogFile ? "${tmpDir}/updater-changelog"
, updateScriptCommitMessageFile ? "${tmpDir}/commit-message"
, alternativeEnvFile ? "${tmpDir}/github-env"
, nvcheckerKeyFile ? "keyfile.toml"
}:

let
  nix = nixVersions.unstable;
  updateScripts = selfLib.getUpdateScripts repoPackages;
  escapedUpdateScripts = builtins.map lib.escapeShellArgs updateScripts;
in

writeShellScriptBin "update" ''
  set -e

  export PATH=${nix-prefetch}/bin:$PATH
  export NIX_PATH="nixpkgs=${path}"

  rm -rf "${tmpDir}"
  mkdir -p "${tmpDir}"
  if [ -z "$GITHUB_ENV" ]; then
    ENV_FILE="${alternativeEnvFile}"
  else
    ENV_FILE="$GITHUB_ENV"
  fi

  # setup git
  function commit {
    git add --all
    git commit "$@"
  }

  # remove old Cargo.lock files
  pushd pkgs/_sources
  rm -f */Cargo.lock
  popd

  ## run updater
  echo "run updater"
  NVCHECKER_EXTRA_OPTIONS=()
  if [ -f "${nvcheckerKeyFile}" ]; then
    NVCHECKER_EXTRA_OPTIONS+=("--keyfile" "$(realpath "${nvcheckerKeyFile}")")
  fi
  pushd pkgs;
  set -x
  "${repoPackages.updater}/bin/updater" "''${NVCHECKER_EXTRA_OPTIONS[@]}";
  set +x
  popd

  ## update scripts
  echo "run update scripts"
  function handle_update_script {
    "$@" --write-commit-message "${updateScriptCommitMessageFile}"
    if [ -f "${updateScriptCommitMessageFile}" ]; then
      commit --file="${updateScriptCommitMessageFile}"
      cat "${updateScriptCommitMessageFile}" >> "${changelogFile}"
      rm "${updateScriptCommitMessageFile}"
    fi
  }
  ${ lib.concatStringsSep "\n" (builtins.map (s: "handle_update_script ${s}") escapedUpdateScripts) }

  # format repository
  ${nixpkgs-fmt}/bin/nixpkgs-fmt .

  # get changelog
  ${nvfetcher-changes-commit}/bin/nvfetcher-changes-commit "pkgs/_sources/generated.nix" > "${updaterChangelogFile}"
  cat "${updaterChangelogFile}" >> "${changelogFile}"

  ## nix flake update
  # do nix flake update if sources were updated
  if [ -n "$(cat "${changelogFile}")" ]; then
    echo "update flake inputs"
    nix flake update --commit-lock-file
  fi

  ## write to env file
  echo "writing information to $ENV_FILE"
  echo "CHANGELOG<<EOF" > $ENV_FILE
  cat ${changelogFile} >> $ENV_FILE
  echo "EOF" >> $ENV_FILE
''
