{ lib, maven, fetchFromGitHub }:

maven.buildMavenPackage rec {
  pname = "harbor";
  version = "1.6.4-b1";

  src = fetchFromGitHub {
    owner = "nkomarn";
    repo = pname;
    rev = version;
    sha256 = "sha256-xUu5f9FfLRkZIQslNVZuQH89eQhuzrBxmO2+GkMW538=";
  };

  patches = [ ./enforce-versions.patch ];

  mvnHash = "sha256-bjfyBH2GYwGxsUTn2Qv468UH1g/JGsJ1jMvJIcnQ31c";

  installPhase = ''
    install -Dm644 target/Harbor-*.jar $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/nkomarn/Harbor";
    description =
      "Harbor is a plugin that redefines sleep within your Spigot server!";
    license = licenses.mit;
    maintainers = with maintainers; [ zeratax ];
  };
}
