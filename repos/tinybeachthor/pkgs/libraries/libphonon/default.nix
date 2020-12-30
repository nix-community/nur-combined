{ stdenv
, fetchzip
, autoPatchelfHook
, zlib
}:

stdenv.mkDerivation rec {
  pname = "libphonon";
  version = "2.0-beta.19";

  src = fetchzip {
    url = "https://github.com/ValveSoftware/steam-audio/releases/download/v${version}/steamaudio_api_${version}.zip";
    sha256 = "sha256-8Wx75xZW/gb/SAKAPWXMYcybGJUZqLKatlfssr54vX0=";
    name = "${pname}-${version}-source-archive";
    stripRoot = true;
    extraPostFetch = ''
      chmod go-w $out
    '';
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    zlib
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    mkdir $out
    mkdir $out/lib
    mkdir $out/include

    cp -r include/*       $out/include/
    cp -r lib/Linux/x64/* $out/lib/
  '';
  dontInstall = true;

  meta = with stdenv.lib; {
    description = "Immersive audio solutions for games and VR";
    homepage = "https://valvesoftware.github.io/steam-audio/index.html";
    platforms = with platforms; linux;
  };
}
