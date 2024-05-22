{
  lib,
  stdenvNoCC,
  fetchgdrive,
  unzip,
}:

{
  hib-lov = stdenvNoCC.mkDerivation rec {
    pname = "Hib-Lov";
    version = "2020-10-17";

    src = fetchgdrive {
      id = "17DUaRG_qj_qgIZ5EuHOflaDCobO0pWlv";
      hash = "sha256-AV9nGPtmbTUr8dH3xTXSfSLu6iehdhRgL02YKIRVZeQ=";
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
    version = "2021-05-10";

    src = fetchgdrive {
      id = "1JWpkJxdnfqBrFc9Hd_FxndNDLlGM-dj0";
      hash = "sha256-BAPUvt+xQD/LV9NljCE7lke2syFSRAdAe++JZn/orSU=";
      name = "OV-Kamch-${lib.replaceStrings [ "-" ] [ "" ] version}-1.01.zip";
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
      hash = "sha256-C7+KmG8SQwm/q9J2ksgonzOUXPF2JPcvwVKWYbE2axA=";
      name = "OV-Kodar-${lib.replaceStrings [ "-" ] [ "" ] version}-1.01.zip";
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
