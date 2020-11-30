{ stdenv, fetchfromgh, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "klogg-bin";
  version = "20.4";

  src = fetchfromgh {
    owner = "variar";
    repo = "klogg";
    version = "v${version}";
    name = "klogg-${version}.0-r589-OSX.dmg";
    sha256 = "1z4jl43iny218wid5s8i11l16db6hfnynkh7hrdna81abd9gfq9n";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "klogg.app";

  installPhase = ''
    mkdir -p $out/Applications/klogg.app
    cp -r . $out/Applications/klogg.app
  '';

  meta = with stdenv.lib; {
    inherit (sources.klogg) description homepage;
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
