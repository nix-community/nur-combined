copyInstallHook() {
  [ -z "${copyInstallHookHasRun-}" ] || return
  copyInstallHookHasRun=1

  echo Executing copyInstallPhase
  runHook preCopyInstall

  if [[ -n "${copyInstallDestination-}" ]]; then
    destination="$copyInstallDestination"
  elif [[ -n "${NIX_MAIN_PROGRAM-}" ]]; then
    destination="${!outputBin}/share/${NIX_MAIN_PROGRAM}"
  elif [[ -n "${pname-}" ]]; then
    destination="${!outputBin}/share/${pname}"
  else
      echo "copyInstallHook: Unable to determine copy destination." \
      "Please set at least one of 'pname', 'meta.mainProgram', and 'copyInstallDestination'." >&2
    return 2
  fi

  if [[ -n "${copyInstallSource-}" ]]; then
    src="$copyInstallSource"
  else
    src=.
  fi

  if [[ -d "$destination" ]]; then
    echo "Removing existing directory $destination"
    rm -rf "$destination"
  fi
  echo "copyInstallHook: Copying $src to $destination"
  mkdir -p "$(dirname "$destination")"
  cp -ar "$src" "$destination"

  runHook postCopyInstall
  echo Finished copyInstallPhase
}

if [[ -z "${dontCopyInstall-}" ]]; then
  preInstallHooks+=(copyInstallHook)
fi
