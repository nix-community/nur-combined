renpyUnpackHook() {
  [ -z "${renpyUnpackHookHasRun-}" ] || return
  renpyUnpackHookHasRun=1

  echo Executing renpyUnpackPhase
  runHook preRenpyUnpack

  while IFS= read -r -d '' archive; do
    echo "Unpacking $archive"
    rpatool -x "$archive" -o "$(dirname "$archive")" "${renpyUnpackExtraArgs[@]}"
    rm "$archive"
  done < <(find -type f \( -iname '*.rpa' -o -iname '*.rpi' \) -print0)

  runHook postRenpyUnpack
  echo Finished renpyUnpackPhase
}

if [[ -z "${dontRenpyUnpack-}" ]]; then
  echo "Using renpyUnpackHook"
  postUnpack+=(renpyUnpackHook)
fi
