{ stdenv, fetchfromgh, undmg, sources }:

stdenv.mkDerivation rec {
  pname = "Openorienteering-Mapper";
  version = "20201026.1";

  src = fetchfromgh {
    owner = "OpenOrienteering";
    repo = "mapper";
    version = "master-v${version}";
    name = "OpenOrienteering-Mapper-master_v${version}-macOS.dmg";
    sha256 = "19z4bip7x2jzrr4q5qammwkarq81ymqnhf8l93r6hms0sln1gafn";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Mapper.app";

  installPhase = ''
    mkdir -p $out/Applications/Mapper.app
    cp -R . $out/Applications/Mapper.app
  '';

  meta = with stdenv.lib; {
    inherit (sources.mapper) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
