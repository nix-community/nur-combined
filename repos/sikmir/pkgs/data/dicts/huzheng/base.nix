{ lib, stdenvNoCC, fetchurl, pname, version, filename, hash, description }:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "http://download.huzheng.org/${filename}";
    inherit hash;
  };

  installPhase = "cp -a . $out";

  preferLocalBuild = true;

  meta = with lib; {
    inherit description;
    homepage = "http://download.huzheng.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
