{ lib, stdenv, fetchfromgh, undmg }:

stdenv.mkDerivation rec {
  pname = "Openorienteering-Mapper-bin";
  version = "0.9.5";

  src = fetchfromgh {
    owner = "OpenOrienteering";
    repo = "mapper";
    version = "v${version}";
    name = "OpenOrienteering-Mapper-${version}-macOS.dmg";
    sha256 = "1fy65svhrjdzp3wghz7maxwpl2ql0crw0z1qapinf8rv5xa309nr";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "OpenOrienteering Mapper is a software for creating maps for the orienteering sport";
    homepage = "https://www.openorienteering.org/apps/mapper/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
