# Basically a reimplementation in nix of https://github.com/adi1090x/polybar-themes/tree/master/polybar-1

{
  stdenv, fetchFromGitHub, writeScript,
  polybarFull, rofi, systemd,
  source-polybar-themes ? import ../source-polybar-themes.nix { inherit fetchFromGitHub; },
}:

# TODO: remove impurity on fonts
# TODO: Allow picking color scheme

let
  repo = stdenv.mkDerivation {
    name = "source-polybar-themes-1";
    src = "${source-polybar-themes}";

    patchPhase = ''
      # Change config.ini to point towards correct scripts
      substituteInPlace polybar-1/config.ini --replace "\$HOME/.config/polybar" "$out/polybar-1"

      # Change scripts to not rely on /bin/bash
      patchShebangs polybar-1/scripts

      # Patch scripts/menu
      substituteInPlace polybar-1/scripts/menu --replace "rofi" ${rofi}/bin/rofi

      # Patch scripts/menu_full
      substituteInPlace polybar-1/scripts/menu_full --replace "rofi" ${rofi}/bin/rofi

      # Patch scripts/menu_full
      substituteInPlace polybar-1/scripts/sysmenu \
        --replace "rofi" ${rofi}/bin/rofi \
        --replace "systemctl" ${systemd}/bin/systemctl
        #--replace "i3lock"
        #--replace "openbox --exit"
    '';
    installPhase = ''
      mkdir $out
      # Only copy polybar-1 directory because we don't use the rest
      cp -r polybar-1 $out
    '';
  };
in writeScript "polybar-1" ''
  #unset PATH

  ${polybarFull}/bin/polybar main -c ${repo}/polybar-1/config.ini &
''

