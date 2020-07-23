{ stdenv, fetchfromgh, undmg, sources }:
let
  pname = "Openorienteering-Mapper";
  version = "0.9.3";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "OpenOrienteering";
    repo = "mapper";
    version = "v${version}";
    name = "OpenOrienteering-Mapper-${version}-macOS.dmg";
    sha256 = "18fpspa7sjl6xig12g7zm6106wzllj2g1p0ls3h5x3az2rl4ww12";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/Mapper.app
    cp -R . $out/Applications/Mapper.app
  '';

  meta = with stdenv.lib; {
    inherit (sources.mapper) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
