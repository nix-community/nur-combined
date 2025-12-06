{
  sources,
  version,
  lib,
  stdenvNoCC,
  unzip,
  findutils,
}:
stdenvNoCC.mkDerivation (_final: {
  inherit (sources) pname src;
  inherit version;

  nativeBuildInputs = [
    unzip
    findutils
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/TrionesType/zhuque";
    description = "Open-source Chinese Fangsong font";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };
})
