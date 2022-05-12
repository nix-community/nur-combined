{ writeShellScriptBin
, nixVersions
, nixpkgs-fmt
, nix-prefetch
, path
, sourcesFile ? "./pkgs/_sources/generated.nix"
, tmpDir ? "/tmp/linyinfeng-nur-packages-update"
, oldSourcesFile ? "${tmpDir}/old-generated.nix"
, changelogFile ? "${tmpDir}/changelog"
, alternativeEnvFile ? "${tmpDir}/github-env"
}:

let
  nix = nixVersions.unstable;
in

writeShellScriptBin "update" ''
  set -e

  export PATH=${nix-prefetch}/bin:$PATH

  mkdir -p ${tmpDir}

  if [ -z "$GITHUB_ENV" ]; then
    ENV_FILE="${alternativeEnvFile}"
  else
    ENV_FILE="$GITHUB_ENV"
  fi

  # save old source file
  cp ${sourcesFile} ${oldSourcesFile}

  # remove old Cargo.lock files
  pushd pkgs/_sources
  rm -f */Cargo.lock
  popd

  # perform update
  pushd pkgs;
  export NIX_PATH="nixpkgs=${path}"
  ${nix}/bin/nix shell ..#updater --command updater "$@";
  popd
  ${nixpkgs-fmt}/bin/nixpkgs-fmt ${sourcesFile}
  # update done

  ${nix}/bin/nix eval --expr '
    (builtins.getFlake "'$PWD'").lib.versionDiff {
      oldSources = ${oldSourcesFile};
      newSources = ${sourcesFile};
    }' --impure --raw > ${changelogFile}

  echo "writing information to $ENV_FILE"

  echo "UPDATER_CHANGELOG<<EOF" >> $ENV_FILE
  cat ${changelogFile} >> $ENV_FILE
  echo "EOF" >> $ENV_FILE

  changelog_lines=$(wc --lines ${changelogFile} | cut -d ' ' -f 1)
  if [ "$changelog_lines" -eq "1" ]; then
      echo "COMMIT_TITLE=$(cat ${changelogFile})" >> $ENV_FILE
      echo "COMMIT_BODY=" >> $ENV_FILE
  else
      echo "COMMIT_TITLE=Update multiple packages" >> $ENV_FILE
      echo "COMMIT_BODY<<EOF" >> $ENV_FILE
      echo -ne "\n\n" >> $ENV_FILE
      cat ${changelogFile} >> $ENV_FILE
      echo "EOF" >> $ENV_FILE
  fi
''
