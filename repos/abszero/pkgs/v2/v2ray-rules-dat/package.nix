{
  stdenvNoCC,
  lib,
  fetchurl,
}:

let
  version = "202512302215";
  geoipHash = "032ga71whvkkkqjf5yq1zmmagswi1i0r8c4lmlnkd1y6464l7jgr";
  geositeHash = "0bvg7ivnp9yy2sbyhkcich82d1w3362yk1jp8vqlpwly19cdd9sn";

  repo = "https://github.com/Loyalsoldier/v2ray-rules-dat";
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

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Enhanced edition of V2Ray rules dat files";
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
