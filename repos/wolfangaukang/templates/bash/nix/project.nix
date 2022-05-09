{ stdenv, lib, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "project";
  version = "0.1.0";

  src = lib.cleanSource ../.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [];

  dontBuild = true;
  dontConfigure = true;

  postPatch = ''
    patchShebangs project
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 project -t $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Says \"Hello, human\"";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = platforms.linux;
  };
}
