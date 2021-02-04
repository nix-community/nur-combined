{ lib, stdenvNoCC, fetchurl, pname, version, filename, sha256, description }:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "http://download.huzheng.org/bigdict/${filename}";
    inherit sha256;
  };

  installPhase = "cp -a . $out";

  preferLocalBuild = true;

  meta = with lib; {
    inherit description;
    homepage = "http://download.huzheng.org/bigdict/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
