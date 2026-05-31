rmmzNwjsWrapperArgs=()
rmmzNwjsGameHomes=()

rmmzNwjsWrap() {
  local gameHome="$1"
  local executablePath="$2"
  shift 2
  rmmzNwjsGameHomes+=("$gameHome")
  makeWrapper "@nwjs@" "$executablePath" \
    --add-flags "$(printf '%q' "$gameHome")" "${rmmzNwjsWrapperArgs[@]}" "$@"
}

rmmzNwjsStrip() {
  local gameHome="$1"
  local oldPwd="$(pwd)"
  cd "$gameHome"
  local currentSetting=$(shopt -p nullglob)
  for file in swiftshader locales *.bin *.pak *.dll *.dat *.exe credits.html debug.log; do
    if [[ -e "$file" ]]; then
      echo "rmmzNwjsStrip: Removing $file"
      rm -rf "$file"
    fi
  done
  local fileOutput
  while IFS= read -r -d '' file; do
    fileOutput="$(file -b "$file")"
    if [[ "$fileOutput" == "ELF "* || "$fileOutput" == PE32* ]]; then
      echo "rmmzNwjsStrip: Removing $file"
      rm -f "$file"
    fi
  done < <(find -maxdepth 1 -type f -print0)
  eval "$currentSetting"
  cd "$oldPwd"
}

rmmzNwjsFix() {
  local gameHome="$1"
  local packageJson="$gameHome/package.json"
  local name="$(jq .name "$packageJson")"
  if [[ "$name" == '""' || "$name" == "null" ]]; then
    local newJson="$(jq --arg name "$(basename "$gameHome")" '.name = $name' "$packageJson")"
    echo "$newJson" > "$packageJson"
  fi
  cat "@rmmzManagersPatch@" >> "$gameHome/js/rmmz_managers.js"
}

rmmzNwjsWrapHook() {
  [ -z "${rmmzNwjsWrapHookHasRun-}" ] || return
  rmmzNwjsWrapHookHasRun=1

  echo Executing rmmzNwjsWrapPhase
  runHook preRmmzNwjsWrap

  if [[ -n "${rmmzNwjsWrapExecutablePath-}" ]]; then
    executablePath="$rmmzNwjsWrapExecutablePath"
  elif [[ -n "${NIX_MAIN_PROGRAM-}" ]]; then
    executablePath="${!outputBin}/bin/${NIX_MAIN_PROGRAM}"
  elif [[ -n "${pname-}" ]]; then
    executablePath="${!outputBin}/bin/${pname}"
  else
    echo "rmmzNwjsWrapHook: Unable to determine executable path for wrapping." \
      "Please set at least one of 'pname', 'meta.mainProgram', and 'rmmzNwjsWrapExecutablePath'." >&2
    return 2
  fi

  foundGame=""
  foundMultipleGames=""
  for targetDir in "$prefix/share" "$prefix/opt"; do
    if [[ ! -d "$targetDir" ]]; then
      continue
    fi
    while IFS= read -r -d '' gameHome; do
      if [[ ! -f "$gameHome/Game.exe" ]]; then
        continue
      fi
      if [[ -n "$foundGame" ]]; then
        foundMultipleGames=1
        echo "rmmzNwjsWrapHook: Multiple directories containing Game.exe and package.json found; skipping wrapping $gameHome" >&2
        continue
      fi
      foundGame=1
      echo "rmmzNwjsWrapHook: Wrapping $gameHome"
      rmmzNwjsWrap "$gameHome" "$executablePath"
    done < <(find "$targetDir" -mindepth 1 -type f -name package.json -printf '%h\0')
  done

  if [[ -n "$foundMultipleGames" ]]; then
    echo "rmmzNwjsWrapHook: Because there are multiple directories containing Game.exe and package.json files, it is recommended to set 'dontRmmzNwjsWrap = true'" \
      "and wrap the game manually with the 'rmmzNwjsWrap' function." >&2
  elif [[ -z "$foundGame" ]]; then
    echo "rmmzNwjsWrapHook: No directory containing Game.exe and package.json found" >&2
    return 1
  fi

  runHook postRmmzNwjsWrap
  echo Finished rmmzNwjsWrapPhase
}

rmmzNwjsStripHook() {
  [ -z "${rmmzNwjsStripHookHasRun-}" ] || return
  rmmzNwjsStripHookHasRun=1

  echo Executing rmmzNwjsStripPhase
  runHook preRmmzNwjsStrip

  for gameHome in "${rmmzNwjsGameHomes[@]}"; do
    rmmzNwjsStrip "$gameHome"
  done

  runHook postRmmzNwjsStrip
  echo Finished rmmzNwjsStripPhase
}

rmmzNwjsFixHook() {
  [ -z "${rmmzNwjsFixHookHasRun-}" ] || return
  rmmzNwjsFixHookHasRun=1

  echo Executing rmmzNwjsFixPhase
  runHook preRmmzNwjsFix

  for gameHome in "${rmmzNwjsGameHomes[@]}"; do
    rmmzNwjsFix "$gameHome"
  done

  runHook postRmmzNwjsFix
  echo Finished rmmzNwjsFixPhase
}

if [[ -z "${dontRmmzNwjsWrap-}" ]]; then
  echo "Using rmmzNwjsWrapHook"
  postInstallHooks+=(rmmzNwjsWrapHook)
fi

if [[ -z "${dontRmmzNwjsStrip-}" ]]; then
  echo "Using rmmzNwjsStripHook"
  preFixupHooks+=(rmmzNwjsStripHook)
fi

if [[ -z "${dontRmmzNwjsFix-}" ]]; then
  echo "Using rmmzNwjsFixHook"
  preFixupHooks+=(rmmzNwjsFixHook)
fi
