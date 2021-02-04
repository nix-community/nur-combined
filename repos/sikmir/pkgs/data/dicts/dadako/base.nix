{ lib, stdenvNoCC, fetchurl, unzip, pname, version, filename, sha256, description }:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "http://dadako.narod.ru/GoldenDict/${filename}";
    inherit sha256;
  };

  dontUnpack = true;

  installPhase = "${unzip}/bin/unzip $src -d $out";

  preferLocalBuild = true;

  meta = with lib; {
    inherit description;
    homepage = "http://dadako.narod.ru/paperpoe.htm";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
