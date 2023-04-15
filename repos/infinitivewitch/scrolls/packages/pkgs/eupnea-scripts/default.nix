{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  inherit (sources.eupnea-scripts) pname version src;

  installPhase = ''
    cp -r . $out
  '';

  meta = with lib; {
    homepage = "https://github.com/eupnea-linux/audio-scripts";
    description = "Audio scripts for Eupnea written in python";
    license = licenses.gpl3Plus;
  };
}
