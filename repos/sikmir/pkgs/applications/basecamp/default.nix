{ stdenv, fetchurl, undmg, xar, cpio }:
let
  pname = "basecamp";
  version = "4.8.9";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://download.garmin.com/software/BaseCampforMac_${stdenv.lib.replaceStrings [ "." ] [ "" ] version}.dmg";
    sha256 = "1bg0hpqhs6bqg6ihvn0ffi442xzsg7ym2slqxvsg4lqsrxirkp3x";
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
    license = licenses.unfree;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
