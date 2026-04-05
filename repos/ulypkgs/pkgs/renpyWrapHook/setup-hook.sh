renpyWrapperArgs=()
renpyGameHomes=()

renpyWrap() {
  local gameHome="$1"
  local executablePath="$2"
  shift 2
  renpyGameHomes+=("$gameHome")
  makeWrapper "@renpy@" "$executablePath" --add-flags "$(printf '%q' "$gameHome")" "${renpyWrapperArgs[@]}" "$@"
}

renpyStrip() {
  local gameHome="$1"
  for target in game/saves lib log.txt renpy; do
    if [[ -e "$gameHome/$target" ]]; then
      echo "renpyStrip: Removing $gameHome/$target"
      rm -rf "$gameHome/$target"
    fi
  done
  while IFS= read -r -d '' file; do
    echo "renpyStrip: Removing $file"
    rm -f "$file"
  done < <(find "$gameHome" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.exe" \) -print0)
  while IFS= read -r -d '' file; do
    if [[ -f "${file}c" ]]; then
      echo "renpyStrip: Removing $file"
      rm -f "$file"
    fi
  done < <(find "$gameHome" -type f \( -name "*.rpy" -o -name "*.rpym" \) -print0)
}

renpyWrapHook() {
  [ -z "${renpyWrapHookHasRun-}" ] || return
  renpyWrapHookHasRun=1

  echo Executing renpyWrapPhase
  runHook preRenpyWrap

  if [[ -n "${renpyWrapExecutablePath-}" ]]; then
    executablePath="$renpyWrapExecutablePath"
  elif [[ -n "${NIX_MAIN_PROGRAM-}" ]]; then
    executablePath="${!outputBin}/bin/${NIX_MAIN_PROGRAM}"
  elif [[ -n "${pname-}" ]]; then
    executablePath="${!outputBin}/bin/${pname}"
  else
    echo "renpyWrapHook: Unable to determine executable path for wrapping." \
      "Please set at least one of 'pname', 'meta.mainProgram', and 'renpyWrapExecutablePath'." >&2
    return 2
  fi

  foundGame=""
  foundMultipleGames=""
  for targetDir in "$prefix/share" "$prefix/opt"; do
    if [[ ! -d "$targetDir" ]]; then
      continue
    fi
    while IFS= read -r -d '' gameHome; do
      if [[ -n "$foundGame" ]]; then
        foundMultipleGames=1
        echo "renpyWrapHook: Multiple 'game' directories found; skipping wrapping $gameHome" >&2
        continue
      fi
      foundGame=1
      echo "renpyWrapHook: Wrapping $gameHome"
      renpyWrap "$gameHome" "$executablePath"
      # This is also how Ren'Py launcher finds projects: https://github.com/renpy/renpy/blob/8.5.2.26010301/launcher/game/project.rpy#L656-L658
    done < <(find "$targetDir" -mindepth 1 -type d -name game -printf '%h\0')
  done

  if [[ -n "$foundMultipleGames" ]]; then
    echo "renpyWrapHook: Because there are multiple 'game' directories, it is recommended to set 'dontRenpyWrap = true'" \
      "and wrap the game manually with the 'renpyWrap' function." >&2
  elif [[ -z "$foundGame" ]]; then
    echo "renpyWrapHook: No 'game' directory found" >&2
    return 1
  fi

  runHook postRenpyWrap
  echo Finished renpyWrapPhase
}

renpyStripHook() {
  [ -z "${renpyStripHookHasRun-}" ] || return
  renpyStripHookHasRun=1

  echo Executing renpyStripPhase
  runHook preRenpyStrip

  for gameHome in "${renpyGameHomes[@]}"; do
    renpyStrip "$gameHome"
  done

  runHook postRenpyStrip
  echo Finished renpyStripPhase
}

if [[ -z "${dontRenpyWrap-}" ]]; then
  echo "Using renpyWrapHook"
  postInstallHooks+=(renpyWrapHook)
fi

if [[ -z "${dontRenpyStrip-}" ]]; then
  echo "Using renpyStripHook"
  preFixupHooks+=(renpyStripHook)
fi
