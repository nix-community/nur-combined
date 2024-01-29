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

  mvnHash = "sha256-HZE3hoBOwL4A2GBpf4wjgWvx+ZN05WtgE+4S3uIYXDo=";

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
