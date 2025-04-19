{
  sources,
  lib,
  stdenv,
  autoPatchelfHook,
  dpkg,
}:
let
  source =
    if stdenv.isx86_64 then
      sources.fr24feed-amd64
    else if stdenv.isi686 then
      sources.fr24feed-i386
    else if stdenv.isAarch32 then
      sources.fr24feed-armhf
    else if stdenv.isAarch64 then
      sources.fr24feed-arm64
    else
      throw "Unsupported architecture";
in
stdenv.mkDerivation rec {
  inherit (source) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg -x $src .

    runHook postUnpack
  '';

  postPatch = ''
    substituteInPlace usr/bin/fr24feed-signup-adsb \
      --replace-fail "/usr/bin/fr24feed" "$out/bin/fr24feed"
    substituteInPlace usr/bin/fr24feed-signup-uat \
      --replace-fail "/usr/bin/fr24feed" "$out/bin/fr24feed"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    install -Dm755 usr/bin/fr24feed $out/bin/fr24feed
    install -Dm755 usr/bin/fr24feed-signup-adsb $out/bin/fr24feed-signup-adsb
    install -Dm755 usr/bin/fr24feed-signup-uat $out/bin/fr24feed-signup-uat
    install -Dm644 etc/fr24feed.ini $out/etc/fr24feed.ini

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Flightradar24 Decoder & Feeder lets you effortlessly share ADS-B data with Flightradar24";
    homepage = "https://www.flightradar24.com/share-your-data";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "fr24feed";
  };
}
