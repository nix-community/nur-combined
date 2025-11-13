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

  meta = with lib; {
    homepage = "https://github.com/TrionesType/zhuque";
    description = "Open-source Chinese Fangsong font";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ ccicnce113424 ];
  };
})
