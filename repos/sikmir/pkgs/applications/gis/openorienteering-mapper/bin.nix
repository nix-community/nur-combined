{ stdenv, fetchfromgh, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "Openorienteering-Mapper-bin";
  version = "20201220.7";

  src = fetchfromgh {
    owner = "OpenOrienteering";
    repo = "mapper";
    version = "master-v${version}";
    name = "OpenOrienteering-Mapper-master_v${version}-macOS.dmg";
    sha256 = "1ndh9pq51ga09p31pl7ysd9y6y7w714i2q3rhqz2hjnaq4lgvz5m";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Mapper.app";

  installPhase = ''
    mkdir -p $out/Applications/Mapper.app
    cp -r . $out/Applications/Mapper.app
  '';

  meta = with stdenv.lib; {
    inherit (sources.mapper) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
