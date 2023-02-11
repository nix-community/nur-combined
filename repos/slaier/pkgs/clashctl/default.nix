{ lib, stdenv, sources, autoPatchelfHook, makeSetupHook }:

stdenv.mkDerivation {
  inherit (sources.clashctl) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    (makeSetupHook { } ./completions.sh)
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -m755 -D $src $out/bin/clashctl
  '';

  meta = with lib; {
    description = "CLI for interacting with clash";
    homepage = "https://github.com/George-Miao/clashctl";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
