# Basically a reimplementation in nix of https://github.com/adi1090x/polybar-themes/tree/master/polybar-3

{
  stdenv, fetchFromGitHub, writeScript,
  polybarFull, rofi, systemd,
  source-polybar-themes ? import ../source-polybar-themes.nix { inherit fetchFromGitHub; },
  wlanInterface ? "wlp2s0f0u3",
  logoutCommand ? "i3-msg exit",
  lockCommand ? "i3lock-fancy",
}:

# TODO: remove impurity on fonts
# TODO: Allow picking color scheme

let
  repo = stdenv.mkDerivation {
    name = "source-polybar-themes-3";
    src = "${source-polybar-themes}";

    patchPhase = ''
      cd polybar-3

      # Fix font issues
      substituteInPlace config-top.ini --replace "Misc Termsyn" "Termsyn"
      substituteInPlace config-bottom.ini --replace "Misc Termsyn" "Termsyn"
      substituteInPlace config-top.ini --replace "Wuncon Siji" "Siji"
      substituteInPlace config-bottom.ini --replace "Wuncon Siji" "Siji"

      # Change config-{top,bottom}.ini to point towards correct files
      substituteInPlace config-top.ini --replace "~/.config/polybar" "$out/polybar-3"
      substituteInPlace config-bottom.ini --replace "~/.config/polybar" "$out/polybar-3"

      # Change user_modules.ini to point towards correct scripts
      substituteInPlace user_modules.ini --replace "~/.config/polybar" "$out/polybar-3"

      # Change network interface
      substituteInPlace modules.ini --replace wlp3s0 ${wlanInterface}

      # Change scripts to not rely on /bin/bash
      patchShebangs scripts

      cd scripts

      # Patch rofi
      substituteInPlace windows --replace rofi ${rofi}/bin/rofi
      substituteInPlace launcher --replace rofi ${rofi}/bin/rofi
      substituteInPlace launcher-alt --replace rofi ${rofi}/bin/rofi
      substituteInPlace launcher-full --replace rofi ${rofi}/bin/rofi
      substituteInPlace powermenu --replace rofi ${rofi}/bin/rofi
      substituteInPlace powermenu-alt --replace rofi ${rofi}/bin/rofi

      # Patch powermenus
      substituteInPlace powermenu \
        --replace systemctl ${systemd}/bin/systemctl \
        --replace "openbox --exit" "${logoutCommand}" \
        --replace i3lock-fancy "${lockCommand}"
      substituteInPlace powermenu-alt \
        --replace systemctl ${systemd}/bin/systemctl \
        --replace "openbox --exit" "${logoutCommand}" \
        --replace i3lock-fancy "${lockCommand}"

      cd ../..
    '';
    installPhase = ''
      mkdir $out
      # Only copy polybar-3 directory because we don't use the rest
      cp -r polybar-3 $out
    '';
  };
in writeScript "polybar-3" ''
  #unset PATH

  ${polybarFull}/bin/polybar top -c ${repo}/polybar-3/config-top.ini
  ${polybarFull}/bin/polybar bottom -c ${repo}/polybar-3/config-bottom.ini
''

