{ stdenv, fetchurl, undmg, xar, cpio }:
let
  pname = "basecamp";
  version = "4.8.10";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://download.garmin.com/software/BaseCampforMac_${stdenv.lib.replaceStrings [ "." ] [ "" ] version}.dmg";
    sha256 = "09jrbix42a6aqv8vd4hcrvhfnj9y7l17xm7hdyc6p1nmb859y5ri";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg xar cpio ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications

    xar -xf Install\ BaseCamp.pkg

    for p in BaseCamp MapInstall MapManager; do
      zcat garmin$p.pkg/Payload | cpio -i
      cp -r Garmin\ $p.app $out/Applications
    done
  '';

  meta = with stdenv.lib; {
    description = "BaseCamp lets you plan outdoor activities, organize your data and share your adventures with others";
    homepage = "https://www.garmin.com/en-US/software/basecamp/";
    changelog = "https://www8.garmin.com/support/download_details.jsp?id=4449";
    license = licenses.unfree;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
