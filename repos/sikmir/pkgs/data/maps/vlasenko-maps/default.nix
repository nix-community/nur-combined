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
    version = "2021-01-18";

    src = fetchgdrive {
      id = "1JWpkJxdnfqBrFc9Hd_FxndNDLlGM-dj0";
      sha256 = "1swvc8xzarh0nfb37w80ahsr0g14gyg3z0fp0jf4yhwwb9ima7f1";
      name = "OV-Kamch-Draft.zip";
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

  kodar = stdenvNoCC.mkDerivation rec {
    pname = "Kodar";
    version = "2021-02-15";

    src = fetchgdrive {
      id = "1CMMqgNoK92dIwxVpWQXkBR45P4dXP-o5";
      sha256 = "04pvb8yf8qs1i6m7b1qs69nxjgc483z5z80mkmd610kmkbbpvvg6";
      name = "OV-Kodar-Draft.zip";
    };

    sourceRoot = ".";

    nativeBuildInputs = [ unzip ];

    installPhase = "install -Dm644 *.img -t $out";

    preferLocalBuild = true;

    meta = with lib; {
      description = "OV Кодар";
      homepage = "https://vk.com/vlasenko_maps";
      license = licenses.free;
      maintainers = [ maintainers.sikmir ];
      platforms = platforms.all;
      skip.ci = true;
    };
  };
}
