{ lib, coreutils, makeWrapper, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "osc777";
  version = "0.1.0";

  src = ./osc777;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/osc777
    chmod a+x $out/bin/osc777
  '';

  wrapperPath = lib.makeBinPath [
    coreutils
  ];

  fixupPhase = ''
    patchShebangs $out/bin/osc777
    wrapProgram $out/bin/osc777 --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = ''
      A script to send notifications using the OSC777 escape sequence
    '';
    homepage = "https://git.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    mainProgram = "osc777";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.linux;
  };
}
