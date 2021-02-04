{ lib, stdenv, fetchfromgh, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "Openorienteering-Mapper-bin";
  version = "20201227.4";

  src = fetchfromgh {
    owner = "OpenOrienteering";
    repo = "mapper";
    version = "master-v${version}";
    name = "OpenOrienteering-Mapper-master_v${version}-macOS.dmg";
    sha256 = "0pm1f532prb4dgqycn1lpsw1qz22bi19kcb4zmgsp3pnhgvza067";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Mapper.app";

  installPhase = ''
    mkdir -p $out/Applications/Mapper.app
    cp -r . $out/Applications/Mapper.app
  '';

  meta = with lib; {
    inherit (sources.mapper) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
