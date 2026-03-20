{
  lib,
  stdenvNoCC,
  unzip,
  source,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = builtins.replaceStrings [ "v" ] [ "" ] source.version;

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack

    unzip $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = {
    description = "Composite font of Hack and IBM Plex Sans JP";
    homepage = "https://github.com/ryota2357/PleckJP";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
