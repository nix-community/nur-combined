{
  stdenvNoCC,
  lib,
  fetchurl,
}:

let
  version = "202605012242";
  geoipHash = "0ghck7bap8nqxc76ljc3h5r1vzd4dj59k5zh2hj2axshq0d03106";
  geositeHash = "1c444q2f9rsvk78s7q10jabh1zzwygza9r9dckprcfw0ns5kra6b";

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
