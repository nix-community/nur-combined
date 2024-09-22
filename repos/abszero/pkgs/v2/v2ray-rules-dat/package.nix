{
  stdenvNoCC,
  lib,
  fetchurl,
}:

let
  version = "2024-09-22-01-16";
  geoipHash = "14pb0n242bjwc9x5b84l8lcqf02a3kj5mzaf91vi18l9fiy9ixac";
  geositeHash = "0839m98nwwih3xb3slx3kfkd4d9fdnhdqrlakzx5shlli7444pz9";

  repo = "https://github.com/techprober/v2ray-rules-dat";
  geoip = fetchurl {
    url = "${repo}/releases/download/${version}/geoip.dat";
    sha256 = geoipHash;
  };
  geosite = fetchurl {
    url = "${repo}/releases/download/${version}/geosite.dat";
    sha256 = geositeHash;
  };
in

stdenvNoCC.mkDerivation {
  pname = "v2ray-rules-dat";
  inherit version;

  srcs = [
    geoip
    geosite
  ];

  outputs = [
    "out"
    "geoip"
    "geosite"
  ];

  unpackPhase = ''
    mkdir -p source
    cd source
    for src in $srcs; do
      cp $src $(stripHash $src)
    done
  '';

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    install -Dm444 -t "$geoip/share/v2ray" geoip.dat
    install -Dm444 -t "$geosite/share/v2ray" geosite.dat

    runHook postInstall
  '';

  dontFixup = true;

  meta = with lib; {
    description = "Enhanced edition of V2Ray rules dat files (techprober's fork)";
    homepage = repo;
    downloadPage = "${repo}/releases";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ weathercold ];
    outputsToInstall = [
      "geoip"
      "geosite"
    ];
    platforms = platforms.all;
  };
}
