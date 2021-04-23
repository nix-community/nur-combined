{ lib, stdenv, fetchfromgh, sdkVersion ? "10.13" }:

assert lib.assertOneOf "sdkVersion" sdkVersion [ "10.13" "10.14" "10.15" "11.0.1" ];

stdenv.mkDerivation rec {
  pname = "qmapshack-bin";
  version = "1.15.2";

  src = fetchfromgh {
    owner = "Maproom";
    repo = "qmapshack";
    version = "V_${version}";
    name =
      if sdkVersion == "10.13"
      then "QMapShack-MacOSX.${sdkVersion}_${version}.tar.gz"
      else "QMapShack-MacOSX.${sdkVersion}_${version}_2.tar.gz";
    sha256 = {
      "10.13" = "1b9q0jq6v60wbd5kh2nvd19cv07rxkqcc4lk6378m1d8afvacaax";
      "10.14" = "0w6w0vqsqxhicw2kb4wc2bw6g13f0a3h600zjjbz6kl2zanwh0nm";
      "10.15" = "0f23i7yk82xlcn89s9z5apsggxgwcdw5wnrv3dls11vrz1dvf3l2";
      "11.0.1" = "19p8gd0n7nx89fbn74s13my431cxqj0caazjl9z4hc2pjkq7prjd";
    }.${sdkVersion};
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "Consumer grade GIS software";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
