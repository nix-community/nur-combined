copyIcons() {
  [ -z "${copyIconsHasRun-}" ] || return
  copyIconsHasRun=1

  echo Executing copyIconsPhase
  runHook preCopyIcons

  if [[ -z "${icon:-}" && ${#icons[@]} -eq 0 ]]; then
    echo 'copyIcons: neither `icon` nor `icons` is set, skipping' >&2
    return
  fi
  if [[ -n "${icon:-}" ]]; then
    icons=("$icon" "${icons[@]}")
  fi

  mapfile -t iconNames < <(grep -h '^Icon=' "$out"/share/applications/*.desktop | cut -d= -f2 | sort -u)
  if [[ ${#iconNames[@]} -eq 0 ]]; then
    echo 'copyIcons: No icon names found in $out/share/applications/*.desktop'
    return
  fi

  for iconSrc in "${icons[@]}"; do
    mapfile -t imgInfo < <(magick identify -format '%w %m\n' "$iconSrc")
    for index in "${!imgInfo[@]}"; do
      read -r width format <<< "${imgInfo[$index]}"
      for iconName in "${iconNames[@]}"; do
        if [[ "$format" == "SVG" ]]; then
          iconDst="$out/share/icons/hicolor/scalable/apps/$iconName.svg"
        else
          iconDst="$out/share/icons/hicolor/${width}x${width}/apps/$iconName.png"
        fi
        echo "copyIcons: $iconSrc -> $iconDst"
        mkdir -p "$(dirname "$iconDst")"
        magick "$iconSrc[$index]" "$iconDst"
      done
    done
  done

  runHook postCopyIcons
  echo Finished copyIconsPhase
}

if [[ -z "${dontCopyIcons-}" ]]; then
  postInstallHooks+=(copyIcons)
fi
