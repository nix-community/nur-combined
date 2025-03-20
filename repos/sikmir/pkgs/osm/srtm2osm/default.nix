{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
  mono,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srtm2osm";
  version = "1.16.5.0";

  src = fetchfromgh {
    owner = "mibe";
    repo = "Srtm2Osm";
    tag = "v${lib.versions.majorMinor finalAttrs.version}";
    hash = "sha256-wSuz/s7VEgGc3gbXcLwi3TIoW/GwUMGmTMWVWlaS2sI=";
    name = "Srtm2Osm-${finalAttrs.version}.zip";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/opt/srtm2osm
    cp -r . $out/opt/srtm2osm

    makeWrapper ${mono}/bin/mono $out/bin/srtm2osm \
      --add-flags "$out/opt/srtm2osm/Srtm2Osm.exe"
  '';

  meta = {
    description = "Srtm2Osm tool uses SRTM digital elevation model to generate elevation contours of a selected terrain";
    homepage = "https://github.com/mibe/Srtm2Osm";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "srtm2osm";
    inherit (mono.meta) platforms;
  };
})
