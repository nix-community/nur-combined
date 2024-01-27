{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, alsa-lib
}:

stdenv.mkDerivation rec {
  pname = "amcdx-video-patcher-cli";
  version = "v0.6.7";

  src = fetchurl {
    url = "https://github.com/da8eat/VideoEditorInstaller/raw/master/${version}/AMCDXVideoPatcherCLI.tar.gz";
    sha256 = "sha256-UInK9SCXk+AGi4XMlxwuPiPLvAeV5UxNkPM0iapWKWs=";
  };

  dontConfigure = true;
  dontBuild = true;

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
  ];

  installPhase = ''
    install -m755 -D AMCDXVideoPatcherCLI $out/bin/AMCDXVideoPatcherCLI
  '';

  meta = with lib; {
    description = "AMCDX Video Patcher CLI.";
    homepage = "https://mogurenko.com";
    license = licenses.unfree;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.linux;
    downloadPage = "https://github.com/da8eat/VideoEditorInstaller";
  };
}
