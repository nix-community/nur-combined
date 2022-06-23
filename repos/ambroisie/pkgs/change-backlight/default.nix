{ lib, brightnessctl, libnotify, makeWrapper, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "change-backlight";
  version = "0.1.0";

  src = ./change-backlight;

  buildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/change-backlight
    chmod a+x $out/bin/change-backlight
  '';

  wrapperPath = lib.makeBinPath [
    brightnessctl
    libnotify
  ];

  fixupPhase = ''
    patchShebangs $out/bin/change-backlight
    wrapProgram $out/bin/change-backlight --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = ''
      A script to change a screen's brightness and notify about it
    '';
    homepage = "https://gitea.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ ambroisie ];
  };
}
