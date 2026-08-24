{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ircam-vamp-plugins-bin";
  version = "2.1.0";
  src = fetchzip {
    url = "https://github.com/Ircam-Partiels/ircam-vamp-plugins/releases/download/${finalAttrs.version}/Ircam-Vamp-Plugins-Linux.zip";
    sha256 = "sha256-QmW7mbtWZCr0ZAkRSfzSjiVVKIgcBLgsfbCeP+Cf2b8=";
  };

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A package containing Vamp plug-ins developed at Ircam";
    homepage = "https://github.com/Ircam-Partiels/ircam-vamp-plugins";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
