{ stdenv, fetchfromgh, undmg, sources }:
let
  pname = "Openorienteering-Mapper";
  version = "0.9.4";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "OpenOrienteering";
    repo = "mapper";
    version = "v${version}";
    name = "OpenOrienteering-Mapper-${version}-macOS.dmg";
    sha256 = "18khck9jghk6sdyg5r8i9yg6sb29dq560zq82icj8blrf4jj0aba";
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
