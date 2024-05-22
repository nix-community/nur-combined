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

  meta = with lib; {
    inherit description;
    homepage = "http://download.huzheng.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
