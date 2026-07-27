{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
}:
stdenv.mkDerivation {
  inherit (sources.ircam-vamp-plugins-bin) pname version src;

  preferLocalBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vamp
    cp *.so *.cat $out/lib/vamp

    runHook postBuild
  '';

  meta = {
    description = "A package containing Vamp plug-ins developed at Ircam";
    homepage = "https://github.com/Ircam-Partiels/ircam-vamp-plugins";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
