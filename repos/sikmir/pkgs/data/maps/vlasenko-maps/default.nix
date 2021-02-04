{ lib, stdenvNoCC, fetchgdrive, unzip }:

{
  hib-lov = stdenvNoCC.mkDerivation rec {
    pname = "Hib-Lov";
    version = "2020-10-17";

    src = fetchgdrive {
      id = "17DUaRG_qj_qgIZ5EuHOflaDCobO0pWlv";
      sha256 = "1dmc02jg6pgqz05s61qwym4dgwx1qb43j0capzsaiyzbq9m4z99d";
      name = "OV-Hib-Lov-${lib.replaceStrings [ "-" ] [ "" ] version}-1.03.zip";
    };

    sourceRoot = ".";

    nativeBuildInputs = [ unzip ];

    installPhase = "install -Dm644 *.img -t $out";

    preferLocalBuild = true;

    meta = with lib; {
      description = "OV Хибины и Ловозерские тундры";
      homepage = "https://vk.com/vlasenko_maps";
      license = licenses.free;
      maintainers = [ maintainers.sikmir ];
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  kamch = stdenvNoCC.mkDerivation rec {
    pname = "Kamch";
    version = "2020-11-09";

    src = fetchgdrive {
      id = "1JWpkJxdnfqBrFc9Hd_FxndNDLlGM-dj0";
      sha256 = "11xkrs6b3ld0bx6xl56azbs9p2ai8pmjx0wmd5i0aacv884nh4aj";
      name = "OV-Kamch-${lib.replaceStrings [ "-" ] [ "" ] version}-1.05.zip";
    };

    sourceRoot = ".";

    nativeBuildInputs = [ unzip ];

    installPhase = "install -Dm644 *.img -t $out";

    preferLocalBuild = true;

    meta = with lib; {
      description = "OV Ключевская-Толбачик";
      homepage = "https://vk.com/vlasenko_maps";
      license = licenses.free;
      maintainers = [ maintainers.sikmir ];
      platforms = platforms.all;
      skip.ci = true;
    };
  };
}