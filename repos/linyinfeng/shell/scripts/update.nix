{ writeShellScriptBin
, nixVersions
, nixpkgs-fmt
, nix-prefetch
, nix-update
, nvfetcher-changes-commit
, path
, nixUpdateAttributes ? [
    "cf-terraforming"
    "aws-s3-reverse-proxy"
  ]
, tmpDir ? "/tmp/linyinfeng-nur-packages-update"
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
  git config user.name "${authorName}"
  git config user.email "${authorEmail}"
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

  # remove old Cargo.lock files
  pushd pkgs/_sources
  rm -f */Cargo.lock
  popd

  ## run updater
  echo "run updater"
  pushd pkgs;
  ${nix}/bin/nix shell ..#updater --command updater "$@";
  popd
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
