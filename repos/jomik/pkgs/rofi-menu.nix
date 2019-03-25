{ pkgs, lib, ... }:
name: menu:

with lib;
pkgs.writeShellScriptBin name ''
  launcher="${pkgs.rofi}/bin/rofi -dmenu -i -hide-scrollbar"
  options="${concatMapStringsSep "\\n" head menu}"

  if [[ $? -ne 0 ]]; then
    exit 0
  fi

  choice=$(echo -e $options | $launcher -p ${name} -lines ${toString (length menu)})
  case $choice in
    ${concatMapStringsSep "\n"
      (e: ''${head e})
      ${optionalString (last e) ''
        confirmed=$(echo -e "Yes\nNo" | $launcher -lines 2 -p "''${choice}?" -selected-row 1)
        if [[ $? -ne 0 || "''${confirmed}" == "No" ]]; then
          exit 0
        fi
      ''}
      ${elemAt e 1}
    ;;'')
  menu}
  esac
''
