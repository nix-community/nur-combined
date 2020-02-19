{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "cambridge";
  version = "2.4.2";

  src = fetchzip {
    url = "http://download.huzheng.org/bigdict/stardict-Cambridge_Advanced_Learners_Dictionary_3th_Ed-${version}.tar.bz2";
    sha256 = "09x4dmgb49mza87f51csvmq273g5hb3d8pzbakpz0bm0qm02qcsi";
  };

  installPhase = ''
    install -dm755 "$out/share/goldendict/dictionaries/${pname}"
    cp -a . "$out/share/goldendict/dictionaries/${pname}"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Cambridge Advanced Learners Dictionary 3th Ed. (En-En)";
    homepage = "http://download.huzheng.org/bigdict/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
