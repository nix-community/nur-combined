{ lib
, writeShellScriptBin

  # Dependencies
, gopass
, zenity
}:

let
  inherit (lib) getExe;
in
writeShellScriptBin "gopass-await" ''
  ${getExe gopass} show "$@" 2> >( \
    ${getExe zenity} --progress --auto-close --no-cancel --pulsate \
      --title 'Please tap the hardware key' \
      --text "gopass show $*" \
      >&2 \
  )
''
