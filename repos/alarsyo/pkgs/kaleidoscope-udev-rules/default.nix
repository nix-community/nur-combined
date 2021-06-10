{ stdenv, lib }:

let
  pname = "kaleidoscope-udev-rules";
  version = "0.8.4";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  dontBuild = true;

  src = ./.;

  # FIXME: fetch from GitHub properly
  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    cp ./60-kaleidoscope.rules $out/lib/udev/rules.d/
  '';

  meta = with lib; {
    description = "udev rules for kaleidoscope firmware keyboards";
    homepage = "https://github.com/keyboardio/Chrysalis";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
