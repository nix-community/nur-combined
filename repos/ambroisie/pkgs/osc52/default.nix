{ lib, coreutils, makeWrapper, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "osc52";
  version = "0.1.0";

  src = ./osc52;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/osc52
    chmod a+x $out/bin/osc52
  '';

  wrapperPath = lib.makeBinPath [
    coreutils
  ];

  fixupPhase = ''
    patchShebangs $out/bin/osc52
    wrapProgram $out/bin/osc52 --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = ''
      A script to copy strings using the OSC52 escape sequence
    '';
    homepage = "https://git.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ ambroisie ];
  };
}
