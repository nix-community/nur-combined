{
  stdenvNoCC,
  lib,
  sources,
  unzip,
  jre_headless,
  makeWrapper,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.suwayomi-server) pname src;
  version =
    let
      arr = lib.splitString "-" sources.suwayomi-server.version;
      v = lib.removePrefix "v" (builtins.elemAt arr ((builtins.length arr) - 2));
      r = builtins.elemAt arr ((builtins.length arr) - 1);
    in
    "${v}-${r}";

  dontUnpack = true;

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/opt/suwayomi-server.jar

    mkdir -p $out/bin
    makeWrapper ${jre_headless}/bin/java $out/bin/suwayomi-server \
      --add-flags "-jar" \
      --add-flags "$out/opt/suwayomi-server.jar"

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "A rewrite of Tachiyomi for the Desktop";
    homepage = "https://github.com/Suwayomi/Suwayomi-Server";
    license = licenses.mpl20;
  };
}
