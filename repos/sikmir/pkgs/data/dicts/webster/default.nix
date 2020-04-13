{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "webster";
  version = "2.4.2";

  src = fetchurl {
    url = "http://download.huzheng.org/bigdict/stardict-Webster_s_Unabridged_3-${version}.tar.bz2";
    sha256 = "1gj33px44d4ywhnxv7x5hxvh43f8m7skwmhvc62ld0c50blrqi7a";
  };

  installPhase = ''
    install -dm755 "$out/share/goldendict/dictionaries/${pname}"
    cp -a . "$out/share/goldendict/dictionaries/${pname}"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Webster's Third New International Dictionary, Unabridged (En-En)";
    homepage = "http://download.huzheng.org/bigdict/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
