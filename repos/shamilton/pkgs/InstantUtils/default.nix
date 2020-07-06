{ lib
, stdenv
, fetchFromGitHub
, st
, rofi
, InstantDotfiles
, neofetch
, firefox
, nitrogen
, InstantConf
, acpi
, pciutils
, InstantTHEMES
, dunst
, InstantShell
}:
stdenv.mkDerivation rec {

  pname = "InstantUtils";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantOS";
    rev = "master";
    sha256 = "11d2hjjmamwxhicsxi9pdi9rds82hqf5hljbicclw1y745fygkx8";
  };

  postPatch = ''
    substituteInPlace programs/instantstartmenu \
      --replace "st -e" "${st}/bin/st -e" \
      --replace "st &" "${st}/bin/st &" \
      --replace "neofetch" "${neofetch}/bin/neofetch" \
      --replace "firefox" "${firefox}/bin/firefox"
    substituteInPlace programs/appmenu \
      --replace "#!/usr/bin/dash" "#!/bin/sh" \
      --replace "/usr/share/instantdotfiles/rofi/appmenu.rasi" "tmp_placeholder" \
      --replace rofi "${rofi}/bin/rofi" \
      --replace "tmp_placeholder" "${InstantDotfiles}/share/instantdotfiles/rofi/appmenu.rasi"
    substituteInPlace programs/ifeh \
      --replace "nitrogen" "${nitrogen}/bin/nitrogen"
    substituteInPlace autostart.sh \
      --replace "iconf" "${InstantConf}/bin/iconf" \
      --replace "instantthemes" "${InstantTHEMES}/bin/instantthemes" \
      --replace "dunst" "${dunst}/bin/dunst" \
      --replace "instantshell" "${InstantShell}/bin/instantshell" \
      --replace "instantdotfiles" "${InstantDotfiles}/bin/instantdotfiles"
    substituteInPlace userinstall.sh \
      --replace "acpi" "${acpi}/bin/acpi" \
      --replace "lspci" "${pciutils}/bin/lspci"
  '';
  
  installPhase = ''
    install -Dm 555 autostart.sh $out/bin/instantautostart
    install -Dm 554 status.sh $out/bin/instantstatus
    install -Dm 555 monitor.sh $out/bin/instantmonitor
    install -Dm 555 instantutils.sh $out/bin/instantutils
    install -Dm 555 userinstall.sh $out/bin/userinstall.sh

    install -Dm 555 programs/appmenu $out/bin/appmenu
    install -Dm 555 programs/checkinternet $out/bin/checkinternet
    install -Dm 555 programs/instantstartmenu $out/bin/instantstartmenu
    install -Dm 555 programs/instantshutdown $out/bin/instantshutdown
    install -Dm 555 programs/ifeh $out/bin/ifeh

    install -Dm 644 desktop/instantlock.desktop $out/share/applications/instantlock.desktop
    install -Dm 644 desktop/instantshutdown.desktop $out/share/applications/instantshutdown.desktop
    install -Dm 644 desktop/st-luke.desktop $out/share/applications/st-luke.desktop
  '';

  propagatedBuildInputs = [ st InstantDotfiles neofetch firefox nitrogen InstantConf acpi InstantTHEMES dunst InstantShell ];

  meta = with lib; {
    description = "InstantOS Utils";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
