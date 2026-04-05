renpyPackImages() {
  local gameHome="$1"

  local rpaFile="$gameHome/game/images.rpa"
  local files=()
  local originalFiles=()
  local isPresplash=""
  while IFS= read -r -d '' file; do
    for presplashFilename in "$gameHome/game"/presplash{,_foreground,_background}.{png,jpg,jpeg,avif,webp}; do
      if [[ "$file" == "$presplashFilename" ]]; then
        isPresplash=1
        break
      fi
    done
    if [[ -z "$isPresplash" ]]; then
      files+=("${file#"$gameHome/game/"}=$file")
      originalFiles+=("$file")
    fi
    isPresplash=""
  done < <(find "$gameHome/game" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.avif" -o -iname "*.webp" \) -print0)
  if [[ ${#files[@]} -gt 0 ]]; then
    echo "Packing images in $gameHome/game to $rpaFile"
    rpatool -c "$rpaFile"
    printf '%s\0' "${files[@]}" | xargs -0 rpatool -a "$rpaFile"
    printf '%s\0' "${originalFiles[@]}" | xargs -0 rm
  fi
}

renpyPackAudio() {
  local gameHome="$1"

  rpaFile="$gameHome/game/audio.rpa"
  files=()
  originalFiles=()
  while IFS= read -r -d '' file; do
    files+=("${file#"$gameHome/game/"}=$file")
    originalFiles+=("$file")
  done < <(find "$gameHome/game" -type f \( -iname "*.mp3" -o -iname "*.ogg" -o -iname "*.wav" \) -print0)
  if [[ ${#files[@]} -gt 0 ]]; then
    echo "Packing audio in $gameHome/game to $rpaFile"
    rpatool -c "$rpaFile"
    printf '%s\0' "${files[@]}" | xargs -0 rpatool -a "$rpaFile"
    printf '%s\0' "${originalFiles[@]}" | xargs -0 rm
  fi
}

renpyPackScripts() {
  local gameHome="$1"

  rpaFile="$gameHome/game/scripts.rpa"
  files=()
  originalFiles=()
  while IFS= read -r -d '' file; do
    files+=("${file#"$gameHome/game/"}=$file")
    originalFiles+=("$file")
  done < <(find "$gameHome/game" -type f \( -iname "*.rpyc" -o -iname "*.rpymc" \) -print0)
  if [[ ${#files[@]} -gt 0 ]]; then
    echo "Packing scripts in $gameHome/game to $rpaFile"
    rpatool -c "$rpaFile"
    printf '%s\0' "${files[@]}" | xargs -0 rpatool -a "$rpaFile"
    printf '%s\0' "${originalFiles[@]}" | xargs -0 rm
  fi
}

renpyPackFonts() {
  local gameHome="$1"

  rpaFile="$gameHome/game/fonts.rpa"
  files=()
  originalFiles=()
  while IFS= read -r -d '' file; do
    files+=("${file#"$gameHome/game/"}=$file")
    originalFiles+=("$file")
  done < <(find "$gameHome/game" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0)
  if [[ ${#files[@]} -gt 0 ]]; then
    echo "Packing fonts in $gameHome/game to $rpaFile"
    rpatool -c "$rpaFile"
    printf '%s\0' "${files[@]}" | xargs -0 rpatool -a "$rpaFile"
    printf '%s\0' "${originalFiles[@]}" | xargs -0 rm
  fi
}

renpyPackVideos() {
  local gameHome="$1"

  rpaFile="$gameHome/game/videos.rpa"
  files=()
  originalFiles=()
  while IFS= read -r -d '' file; do
    files+=("${file#"$gameHome/game/"}=$file")
    originalFiles+=("$file")
  done < <(find "$gameHome/game" -type f \( -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mpg" -o -iname "*.mpeg" \) -print0)
  if [[ ${#files[@]} -gt 0 ]]; then
    echo "Packing videos in $gameHome/game to $rpaFile"
    rpatool -c "$rpaFile"
    printf '%s\0' "${files[@]}" | xargs -0 rpatool -a "$rpaFile"
    printf '%s\0' "${originalFiles[@]}" | xargs -0 rm
  fi
}

renpyPack() {
  local gameHome="$1"
  if [[ -z "${dontRenpyPackImages-}" ]]; then
    renpyPackImages "$gameHome"
  fi
  if [[ -z "${dontRenpyPackAudio-}" ]]; then
    renpyPackAudio "$gameHome"
  fi
  if [[ -z "${dontRenpyPackScripts-}" ]]; then
    renpyPackScripts "$gameHome"
  fi
  if [[ -z "${dontRenpyPackFonts-}" ]]; then
    renpyPackFonts "$gameHome"
  fi
  if [[ -z "${dontRenpyPackVideos-}" ]]; then
    renpyPackVideos "$gameHome"
  fi
}

renpyPackHook() {
  [ -z "${renpyPackHookHasRun-}" ] || return
  renpyPackHookHasRun=1

  echo Executing renpyPackPhase
  runHook preRenpyPack

  if [[ -z "${renpyGameHomes-}" ]]; then
    renpyGameHomes=()
    for targetDir in "$prefix/share" "$prefix/opt"; do
      if [[ ! -d "$targetDir" ]]; then
        continue
      fi
      while IFS= read -r -d '' gameHome; do
        renpyGameHomes+=("$gameHome")
        # This is also how Ren'Py launcher finds projects: https://github.com/renpy/renpy/blob/8.5.2.26010301/launcher/game/project.rpy#L656-L658
      done < <(find "$targetDir" -mindepth 1 -type d -name game -printf '%h\0')
    done
  fi

  for gameHome in "${renpyGameHomes[@]}"; do
    renpyPack "$gameHome"
  done

  runHook postRenpyPack
  echo Finished renpyPackPhase
}

if [[ -z "${dontRenpyPack-}" ]]; then
  echo "Using renpyPackHook"
  postFixup+=(renpyPackHook)
fi
