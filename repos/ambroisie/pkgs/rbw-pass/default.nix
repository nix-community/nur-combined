{ lib, coreutils, makeWrapper, rbw, rofi, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "rbw-pass";
  version = "0.1.0";

  src = ./rbw-pass;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod a+x $out/bin/${pname}
  '';

  wrapperPath = lib.makeBinPath [
    rbw
    coreutils
    rofi
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${pname}
    wrapProgram $out/bin/${pname} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "A simple script to query a password from rbw";
    homepage = "https://git.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    mainProgram = "rbw-pass";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.linux;
  };
}
