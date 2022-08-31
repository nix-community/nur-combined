{ lib, srcOnly, fetchurl, pname, version, filename, hash, description }:

srcOnly {
  inherit pname version;

  src = fetchurl {
    url = "http://download.huzheng.org/${filename}";
    inherit hash;
  };

  meta = with lib; {
    inherit description;
    homepage = "http://download.huzheng.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
