{ stdenv, fetchurl, pname, version, filename, sha256, description }:

stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    url = "http://download.huzheng.org/bigdict/${filename}";
    inherit sha256;
  };

  installPhase = ''
    install -dm755 "$out/share/goldendict/dictionaries/${pname}"
    cp -a . "$out/share/goldendict/dictionaries/${pname}"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    inherit description;
    homepage = "http://download.huzheng.org/bigdict/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
