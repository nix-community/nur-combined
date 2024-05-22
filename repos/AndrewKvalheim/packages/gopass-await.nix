{ writeShellScriptBin

  # Dependencies
, gopass
, zenity
}:

writeShellScriptBin "gopass-await" ''
  ${gopass}/bin/gopass show "$@" 2> >( \
    ${zenity}/bin/zenity --progress --auto-close --no-cancel --pulsate \
      --title 'Please tap the hardware key' \
      --text "gopass show $*" \
      >&2 \
  )
''
