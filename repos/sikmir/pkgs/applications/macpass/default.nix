{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "MacPass";
  version = "0.7.12";

  src = fetchurl {
    url = "https://github.com/MacPass/MacPass/releases/download/${version}/${pname}-${version}.zip";
    sha256 = "1gikixbrz1pvyjspp62msdmhjdy1rfkx8jhy7rajjr8bzm8pzpmc";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/Applications
    ${unzip}/bin/unzip $src -d $out/Applications
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "A native OS X KeePass client";
    homepage = "https://macpassapp.org/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.darwin;
    skip.ci = true;
  };
}
