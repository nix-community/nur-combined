{
  sources,

  stdenv,
  lib,

  curl,
  gtk3,
  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.sgdboop) pname src;
  version = lib.removePrefix "v" sources.sgdboop.version;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl
    gtk3
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/applications}
    cp SGDBoop $out/bin/SGDBoop
    ln -s $out/bin/SGDBoop $out/bin/sgdboop
    cp res/linux/com.steamgriddb.SGDBoop.desktop $out/share/applications

    runHook postInstall
  '';

  meta = {
    description = "Program used for applying custom artwork to Steam, using SteamGridDB";
    homepage = "https://www.steamgriddb.com/boop";
    license = lib.licenses.zlib;
    platforms = lib.platforms.linux;
    mainProgram = "SGDBoop";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
