{
  lib,
  srcOnly,
  fetchwebarchive,
  pname,
  version,
  filename,
  hash,
  description,
}:

srcOnly {
  inherit pname version;

  src = fetchwebarchive {
    url = "http://download.huzheng.org/${filename}";
    timestamp = "20230718140437";
    inherit hash;
  };

  meta = {
    inherit description;
    homepage = "http://download.huzheng.org/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
