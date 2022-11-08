{ stdenv, lib, maven, buildMaven, callPackage, fetchFromGitHub }:
let repository = (buildMaven ./project-info.json).repo;
in stdenv.mkDerivation rec {
  pname = "harbor";
  version = "1.6.4-b1";

  src = fetchFromGitHub {
    owner = "nkomarn";
    repo = pname;
    rev = version;
    sha256 = "xUu5f9FfLRkZIQslNVZuQH89eQhuzrBxmO2+GkMW538=";
    };

  buildInputs = [ maven ];

  buildPhase = ''
    echo "Using repository ${repository}"
    mvn --offline -Dmaven.repo.local=${repository} package;
  '';

  installPhase = ''
    install -Dm644 target/Harbor-*.jar $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/nkomarn/Harbor";
    description =
      "Harbor is a plugin that redefines sleep within your Spigot server!";
    license = licenses.mit;
    # maintainers = with maintainers; [ zeratax ];
  };
}
