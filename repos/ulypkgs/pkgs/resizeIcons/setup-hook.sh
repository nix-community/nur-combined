resizeIcons() {
  [ -z "${resizeIconsHasRun-}" ] || return
  resizeIconsHasRun=1

  echo Executing resizeIconsPhase
  runHook preResizeIcons

  if [[ -z "${iconSizes-}" ]]; then
    iconSizes=(16 32 48 64 128 256 512)
  fi

  while IFS= read -r -d '' sourcePath; do
    if [[ $sourcePath =~ ([0-9]+)x[0-9]+/apps/(.+)\.png$ ]]; then
      sourceSize="${BASH_REMATCH[1]}"
      iconName="${BASH_REMATCH[2]}"
      for targetSize in "${iconSizes[@]}"; do
        if (( targetSize < sourceSize )); then
          targetPath="$out/share/icons/hicolor/${targetSize}x$targetSize/apps/$iconName.png"
          mkdir -p "$(dirname "$targetPath")"
          echo "resizeIcons: $iconName $sourceSize -> $targetSize"
          magick "$sourcePath" -resize "${targetSize}x$targetSize" "$targetPath"
        fi
      done
    fi
  done < <(find "$out/share/icons/hicolor" -path "*/apps/*.png" -print0)

  runHook postResizeIcons
  echo Finished resizeIconsPhase
}

if [[ -z "${dontResizeIcons-}" ]]; then
  postInstallHooks+=(resizeIcons)
fi
