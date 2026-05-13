{
  stdenvNoCC,
  lib,
  fetchurl,
}:

let
  version = "202605122254";
  geoipHash = "1rp29yw3qpix1hhpmnhwbmwzzc9cyqdrgzwrxjbcxsi9iy1v9aca";
  geositeHash = "1p75k3w4cfc4z6i6lgrzmgnz03jmlwz3pbrkffkrpr28zcawqf7p";

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
