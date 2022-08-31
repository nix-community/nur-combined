{ lib, srcOnly, fetchzip, unzip, pname, version, filename, hash, description }:

srcOnly {
  inherit pname version;

  src = fetchzip {
    url = "http://dadako.narod.ru/GoldenDict/${filename}";
    inherit hash;
    stripRoot = false;
  };

  meta = with lib; {
    inherit description;
    homepage = "http://dadako.narod.ru/paperpoe.htm";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
