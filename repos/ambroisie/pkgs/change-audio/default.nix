{ lib, libnotify, makeWrapper, pamixer, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "change-audio";
  version = "0.3.0";

  src = ./change-audio;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/change-audio
    chmod a+x $out/bin/change-audio
  '';

  wrapperPath = lib.makeBinPath [
    libnotify
    pamixer
  ];

  fixupPhase = ''
    patchShebangs $out/bin/change-audio
    wrapProgram $out/bin/change-audio --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = ''
      A script to change the volume and notify about it
    '';
    homepage = "https://git.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    mainProgram = "change-audio";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.linux;
  };
}
