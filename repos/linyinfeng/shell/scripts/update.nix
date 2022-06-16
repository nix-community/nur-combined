{ writeShellScriptBin
, nixVersions
, nixpkgs-fmt
, nix-prefetch
, nix-update
, path
, nixUpdateAttributes ? [
    "cf-terraforming"
  ]
, sourcesFile ? "./pkgs/_sources/generated.nix"
, tmpDir ? "/tmp/linyinfeng-nur-packages-update"
, oldSourcesFile ? "${tmpDir}/old-generated.nix"
, changelogFile ? "${tmpDir}/changelog"
, updaterChangelogFile ? "${tmpDir}/updater-changelog"
, nixUpdateCommitMessageFile ? "${tmpDir}/commit-message"
, alternativeEnvFile ? "${tmpDir}/github-env"
, authorName ? "github-actions[bot]"
, authorEmail ? "github-actions[bot]@users.noreply.github.com"
}:

let
  nix = nixVersions.unstable;
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
  git config --global user.name "${authorName}"
  git config --global user.email "${authorEmail}"
  function commit {
    git add --all
    git commit "$@"
  }

  ## nix-update
  echo "run nix-update"
  attributes=(${toString nixUpdateAttributes})
  for attribute in "''${attributes[@]}"; do
    ${nix-update}/bin/nix-update "$attribute" --write-commit-message "${nixUpdateCommitMessageFile}"
    if [ -f "${nixUpdateCommitMessageFile}" ]; then
      commit --file="${nixUpdateCommitMessageFile}"
      cat "${nixUpdateCommitMessageFile}" >> "${changelogFile}"
      rm "${nixUpdateCommitMessageFile}"
    fi
  done

  # save old source file
  cp ${sourcesFile} ${oldSourcesFile}
  # remove old Cargo.lock files
  pushd pkgs/_sources
  rm -f */Cargo.lock
  popd

  ## run updater
  echo "run updater"
  pushd pkgs;
  ${nix}/bin/nix shell ..#updater --command updater "$@";
  popd
  ${nixpkgs-fmt}/bin/nixpkgs-fmt ${sourcesFile}

  # get changelog
  ${nix}/bin/nix eval --expr '
    (builtins.getFlake "'$PWD'").lib.versionDiff {
      oldSources = ${oldSourcesFile};
      newSources = ${sourcesFile};
    }' --impure --raw > "${updaterChangelogFile}"
  changelog_lines=$(wc --lines ${updaterChangelogFile} | cut -d ' ' -f 1)
  if [ "$changelog_lines" -eq 0 ]; then
    echo "updater changelog is empty, skip"
  elif [ "$changelog_lines" -eq 1 ]; then
    commit --file="${updaterChangelogFile}"
  else
    commit --file=- <<EOF
  Update multiple packages

  $(cat "${updaterChangelogFile}")
  EOF
  fi
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
