{
  lib,
  stdenv,
  fetchurl,
  undmg,
  xar,
  cpio,
}:

stdenv.mkDerivation rec {
  pname = "basecamp";
  version = "4.8.11";

  src = fetchurl {
    url = "https://download.garmin.com/software/BaseCampforMac_${
      lib.replaceStrings [ "." ] [ "" ] version
    }.dmg";
    sha256 = "1ql049xxb7021qssn55hj8f49bzhriia0yvcv5xs3vrya7ymmhgn";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [
    undmg
    xar
    cpio
  ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications

    xar -xf Install\ BaseCamp.pkg

    for p in BaseCamp MapInstall MapManager; do
      zcat garmin$p.pkg/Payload | cpio -i
      cp -r Garmin\ $p.app $out/Applications
    done
  '';

  meta = {
    description = "BaseCamp lets you plan outdoor activities, organize your data and share your adventures with others";
    homepage = "https://www.garmin.com/en-US/software/basecamp/";
    changelog = "https://www8.garmin.com/support/download_details.jsp?id=4449";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
