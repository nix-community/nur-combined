{
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "libgconf-2-shim";
  version = "0.1.0";

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    $CC -shared -fPIC -Wl,-soname,libgconf-2.so.4 -o libgconf-2.so.4 ${./gconf-shim.c}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 libgconf-2.so.4 -t $out/lib

    runHook postInstall
  '';

  meta = {
    description = "Stand-in for the GConf client library, which reports that no setting is configured";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
  };
}
