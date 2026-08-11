# TODO pin jdk version? current: jdk.version = 19.0.2+7
# the build can break with future versions of jdk

{ stdenv
, lib
, fetchFromGitHub
, jdk
, mvn2nix
, maven
, makeWrapper
}:

let
  mavenRepository =
    mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
in

stdenv.mkDerivation rec {

  pname = "mwdumper";
  version = "1.25";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "wikimedia";
    repo = "mediawiki-tools-mwdumper";
    rev = "09fe6ae20de9ee99e8acfff3f1c32a793997367b";
    sha256 = "sha256-I5sXLWBchQoaIFh5Bc0GlWSs9ShJOAMa70zgw6k/aVA=";
  };

  patches = [
    ./0001-add-maven-resources-plugin-3.3.0.patch
    ./0002-update-source-and-target-version.patch
    ./0003-update-all-dependencies.patch
  ];

  nativeBuildInputs = [
    jdk
    maven
    makeWrapper
  ];

  buildPhase = ''
    echo "Building with maven repository ${mavenRepository}"
    mvn package --offline -Dmaven.repo.local=${mavenRepository}
  '';

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${mavenRepository} $out/lib
    cp target/${name}.jar $out/
    makeWrapper ${jdk}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/${name}.jar"

    mkdir -p $out/share/doc
    cp README $out/share/doc/${pname}.txt
    cp ${./docs/mwdumper.html} $out/share/doc/${pname}.html

    mkdir -p $out/share/man/man1
    cp ${./docs/mwdumper.man} $out/share/man/man1/${pname}.1
  '';

  meta = with lib; {
    homepage = "https://github.com/wikimedia/mediawiki-tools-mwdumper";
    description = "tool for extracting sets of pages from a MediaWiki dump file";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
