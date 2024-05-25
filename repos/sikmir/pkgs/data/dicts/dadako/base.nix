{
  lib,
  srcOnly,
  fetchzip,
  unzip,
  pname,
  version,
  filename,
  hash,
  description,
}:

srcOnly {
  inherit pname version;

  src = fetchzip {
    url = "http://dadako.narod.ru/GoldenDict/${filename}";
    inherit hash;
    stripRoot = false;
  };

  meta = {
    inherit description;
    homepage = "http://dadako.narod.ru/paperpoe.htm";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
