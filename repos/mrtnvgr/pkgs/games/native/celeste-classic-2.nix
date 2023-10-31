{ stdenvNoCC, fetchzip, autoPatchelfHook, pkgs, lib }:

stdenvNoCC.mkDerivation {
  pname = "celeste-classic-2";
  version = "1.0";

  src = fetchzip {
    url = "https://drive.google.com/uc?export=download&id=1qQByBKCIGGu1B3G46fBDA_nigAvOJMr8";
    hash = "sha256-wlcVTm3SGXPw17K6aI6IisdAr/qijhBXZEVeAlahhq4=";
    extension = "zip";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [ SDL2 ];

  installPhase = ''
    runHook preInstall
    install -Dsm755 celeste2 $out/bin/celeste-classic-2
    install -Dm444 data.pod $out/bin/data.pod
    runHook postInstall
  '';

  meta = with lib; {
    description = "A PICO-8 platformer about hiking around a mountain, made in three days for Celeste's third anniversary";
    homepage = "https://mattmakesgames.itch.io/celeste-classic-2";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
