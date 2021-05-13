{ stdenv, maven, callPackage, fetchFromGitHub }:
let repository = callPackage ./build-maven-repository.nix { };
# let
#   mvn2nix = import
#     (fetchTarball "https://github.com/fzakaria/mvn2nix/archive/master.tar.gz")
#     { };
#   repository =
#    mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
in stdenv.mkDerivation rec {
  pname = "harbor";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "nkomarn";
    repo = pname;
    rev = version;
    sha256 = "1zh0cdbyzh6d4b4cg72bm30l6nbf0djb6lxrqcf8r3c29zi5yhyb";
    };

  buildInputs = [ maven ];

  buildPhase = ''
    echo "Using repository ${repository}"
    mvn --offline -Dmaven.repo.local=${repository} package;
  '';

  installPhase = ''
    ls target/
    install -Dm644 target/Harbor-${version}.jar $out/share/${pname}.jar
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/nkomarn/Harbor";
    description =
      "Harbor is a plugin that redefines sleep within your Spigot server!";
    license = licenses.mit;
    # maintainers = with maintainers; [ zeratax ];
  };
}
