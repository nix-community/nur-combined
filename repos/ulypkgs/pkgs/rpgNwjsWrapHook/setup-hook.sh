rpgNwjsWrapperArgs=()
rpgNwjsGameHomes=()

rpgNwjsWrap() {
  local gameHome="$1"
  local executablePath="$2"
  shift 2
  rpgNwjsGameHomes+=("$gameHome")
  makeWrapper "@nwjs@" "$executablePath" \
    --add-flags "$(printf '%q' "$gameHome")" "${rpgNwjsWrapperArgs[@]}" "$@"
}

rpgNwjsStrip() {
  local gameHome="$1"
  local oldPwd="$(pwd)"
  cd "$gameHome"
  local currentSetting=$(shopt -p nullglob)
  for file in swiftshader locales lib *.desktop *.bin *.pak *.dll *.dat *.exe credits.html; do
    if [[ -e "$file" ]]; then
      echo "rpgNwjsStrip: Removing $file"
      rm -rf "$file"
    fi
  done
  local fileOutput
  while IFS= read -r -d '' file; do
    fileOutput="$(file -b "$file")"
    if [[ "$fileOutput" == "ELF "* || "$fileOutput" == PE32* ]]; then
      echo "rpgNwjsStrip: Removing $file"
      rm -f "$file"
    fi
  done < <(find -maxdepth 1 -type f -print0)
  eval "$currentSetting"
  cd "$oldPwd"
}

rpgNwjsFix() {
  local gameHome="$1"
  local packageJson="$gameHome/package.json"
  local name="$(jq .name "$packageJson")"
  if [[ "$name" == '""' || "$name" == "null" ]]; then
    local newJson="$(jq --arg name "$(basename "$gameHome")" '.name = $name' "$packageJson")"
    echo "$newJson" > "$packageJson"
  fi
  cat "@rpgManagersPatch@" >> "$gameHome/www/js/rpg_managers.js"
}

rpgNwjsWrapHook() {
  [ -z "${rpgNwjsWrapHookHasRun-}" ] || return
  rpgNwjsWrapHookHasRun=1

  echo Executing rpgNwjsWrapPhase
  runHook preRpgNwjsWrap

  if [[ -n "${rpgNwjsWrapExecutablePath-}" ]]; then
    executablePath="$rpgNwjsWrapExecutablePath"
  elif [[ -n "${NIX_MAIN_PROGRAM-}" ]]; then
    executablePath="${!outputBin}/bin/${NIX_MAIN_PROGRAM}"
  elif [[ -n "${pname-}" ]]; then
    executablePath="${!outputBin}/bin/${pname}"
  else
    echo "rpgNwjsWrapHook: Unable to determine executable path for wrapping." \
      "Please set at least one of 'pname', 'meta.mainProgram', and 'rpgNwjsWrapExecutablePath'." >&2
    return 2
  fi

  foundGame=""
  foundMultipleGames=""
  for targetDir in "$prefix/share" "$prefix/opt"; do
    if [[ ! -d "$targetDir" ]]; then
      continue
    fi
    while IFS= read -r -d '' gameHome; do
      if [[ ! -d "$gameHome/www" ]]; then
        continue
      fi
      if [[ -n "$foundGame" ]]; then
        foundMultipleGames=1
        echo "rpgNwjsWrapHook: Multiple directories containing www and package.json found; skipping wrapping $gameHome" >&2
        continue
      fi
      foundGame=1
      echo "rpgNwjsWrapHook: Wrapping $gameHome"
      rpgNwjsWrap "$gameHome" "$executablePath"
    done < <(find "$targetDir" -mindepth 1 -type f -name package.json -printf '%h\0')
  done

  if [[ -n "$foundMultipleGames" ]]; then
    echo "rpgNwjsWrapHook: Because there are multiple directories containing www and package.json files, it is recommended to set 'dontRpgNwjsWrap = true'" \
      "and wrap the game manually with the 'rpgNwjsWrap' function." >&2
  elif [[ -z "$foundGame" ]]; then
    echo "rpgNwjsWrapHook: No directory containing www and package.json found" >&2
    return 1
  fi

  runHook postRpgNwjsWrap
  echo Finished rpgNwjsWrapPhase
}

rpgNwjsStripHook() {
  [ -z "${rpgNwjsStripHookHasRun-}" ] || return
  rpgNwjsStripHookHasRun=1

  echo Executing rpgNwjsStripPhase
  runHook preRpgNwjsStrip

  for gameHome in "${rpgNwjsGameHomes[@]}"; do
    rpgNwjsStrip "$gameHome"
  done

  runHook postRpgNwjsStrip
  echo Finished rpgNwjsStripPhase
}

rpgNwjsFixHook() {
  [ -z "${rpgNwjsFixHookHasRun-}" ] || return
  rpgNwjsFixHookHasRun=1

  echo Executing rpgNwjsFixPhase
  runHook preRpgNwjsFix

  for gameHome in "${rpgNwjsGameHomes[@]}"; do
    rpgNwjsFix "$gameHome"
  done

  runHook postRpgNwjsFix
  echo Finished rpgNwjsFixPhase
}

if [[ -z "${dontRpgNwjsWrap-}" ]]; then
  echo "Using rpgNwjsWrapHook"
  postInstallHooks+=(rpgNwjsWrapHook)
fi

if [[ -z "${dontRpgNwjsStrip-}" ]]; then
  echo "Using rpgNwjsStripHook"
  preFixupHooks+=(rpgNwjsStripHook)
fi

if [[ -z "${dontRpgNwjsFix-}" ]]; then
  echo "Using rpgNwjsFixHook"
  preFixupHooks+=(rpgNwjsFixHook)
fi
