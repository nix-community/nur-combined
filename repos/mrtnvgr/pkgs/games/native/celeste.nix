{ lib
, stdenvNoCC
, fetchzip
, autoPatchelfHook
, mono
, gcc
, SDL2
, fna3d
, libGL
, libGLU
, libX11
, makeWrapper
}:
let
  srcbin = if stdenvNoCC.isi686 then "Celeste.bin.x86" else "Celeste.bin.x86_64";
  libraries = lib.makeLibraryPath [ SDL2 fna3d libGL libGLU libX11 ];
in stdenvNoCC.mkDerivation rec {
  pname = "celeste";
  version = "1.4.0.0";

  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/cdozus7xj2l9w0ks2uz95/celeste-linux-1.4.0.0.zip?rlkey=dcnnej2tpcq3h8qw9xoa57gwf&dl=1";
    hash = "sha256-5hDV/grDvE6K0D0oevnJhNW5w3rJKj/hpcJG7FpiRlw=";
    extension = "zip";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ gcc.cc.lib ];

  installPhase = ''
    runHook preInstall

    rm -rf lib*

    mkdir -p $out/lib/celeste
    cp -r * $out/lib/celeste/

    mkdir -p $out/bin
    makeWrapper $out/lib/celeste/${srcbin} $out/bin/celeste --set LD_LIBRARY_PATH ${libraries}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A PICO-8 platformer about climbing a mountain, made in four days";
    homepage = "https://mattmakesgames.itch.io/celeste";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = pname;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };

  preferLocalBuild = true;
}
