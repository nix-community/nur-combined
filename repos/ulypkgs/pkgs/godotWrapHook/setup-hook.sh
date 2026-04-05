godotWrapperArgs=()
godotGameHomes=()

godotWrap() {
  local gameHome="$1"
  local executablePath="$2"
  shift 2
  godotGameHomes+=("$gameHome")
  local pckFiles=("$gameHome"/*.pck)
  if [[ ${#pckFiles[@]} -eq 0 ]]; then
    echo "godotWrap: No .pck files found in $gameHome" >&2
    return 1
  elif [[ ${#pckFiles[@]} -gt 1 ]]; then
    local pickedPck="$(find "$gameHome" -maxdepth 1 -type f -iname "$(basename "$gameHome").pck" -print -quit)"
    if [[ -z "$pickedPck" ]]; then
      pickedPck="${pckFiles[0]}"
    fi
    echo "godotWrap: Multiple .pck files found in $gameHome, picked $pickedPck" >&2
  else
    local pickedPck="${pckFiles[0]}"
  fi
  makeWrapper "@godot@" "$executablePath" \
    --add-flags "--main-pack $(printf '%q' "$pickedPck")" "${godotWrapperArgs[@]}" "$@"
}

godotStrip() {
  local gameHome="$1"
  local fileOutput
  while IFS= read -r -d '' file; do
    fileOutput="$(file -b "$file")"
    if [[ "$fileOutput" == "ELF "* || "$fileOutput" == PE32* ]]; then
      echo "godotStrip: Removing $file"
      rm -f "$file"
    fi
  done < <(find "$gameHome" -maxdepth 1 -type f -print0)
}

godotWrapHook() {
  [ -z "${godotWrapHookHasRun-}" ] || return
  godotWrapHookHasRun=1

  echo Executing godotWrapPhase
  runHook preGodotWrap

  if [[ -n "${godotWrapExecutablePath-}" ]]; then
    executablePath="$godotWrapExecutablePath"
  elif [[ -n "${NIX_MAIN_PROGRAM-}" ]]; then
    executablePath="${!outputBin}/bin/${NIX_MAIN_PROGRAM}"
  elif [[ -n "${pname-}" ]]; then
    executablePath="${!outputBin}/bin/${pname}"
  else
    echo "godotWrapHook: Unable to determine executable path for wrapping." \
      "Please set at least one of 'pname', 'meta.mainProgram', and 'godotWrapExecutablePath'." >&2
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
        echo "godotWrapHook: Multiple directories containing .pck files found; skipping wrapping $gameHome" >&2
        continue
      fi
      foundGame=1
      echo "godotWrapHook: Wrapping $gameHome"
      godotWrap "$gameHome" "$executablePath"
    done < <(find "$targetDir" -mindepth 1 -type f -name "*.pck" -printf '%h\0' | sort -zu)
  done

  if [[ -n "$foundMultipleGames" ]]; then
    echo "godotWrapHook: Because there are multiple directories containing .pck files, it is recommended to set 'dontGodotWrap = true'" \
      "and wrap the game manually with the 'godotWrap' function." >&2
  elif [[ -z "$foundGame" ]]; then
    echo "godotWrapHook: No .pck files found" >&2
    return 1
  fi

  runHook postGodotWrap
  echo Finished godotWrapPhase
}

godotStripHook() {
  [ -z "${godotStripHookHasRun-}" ] || return
  godotStripHookHasRun=1

  echo Executing godotStripPhase
  runHook preGodotStrip

  for gameHome in "${godotGameHomes[@]}"; do
    godotStrip "$gameHome"
  done

  runHook postGodotStrip
  echo Finished godotStripPhase
}

if [[ -z "${dontGodotWrap-}" ]]; then
  echo "Using godotWrapHook"
  postInstallHooks+=(godotWrapHook)
fi

if [[ -z "${dontGodotStrip-}" ]]; then
  echo "Using godotStripHook"
  preFixupHooks+=(godotStripHook)
fi
