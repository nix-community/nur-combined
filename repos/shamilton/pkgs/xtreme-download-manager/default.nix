{ pkgs
, lib
, fetchFromGitHub
, stdenv
, jdk11
, makeWrapper
, maven
, mvn2nix
}:

let
  mavenRepository =
   mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
  source = fetchFromGitHub {
    owner = "subhra74";
    repo = "xdm";
    rev = "7.2.11";
    sha256 = "1p2mzaaig7fxk3gsk7r5shl1hijfz6bjlhmkqxgipywr1q1f67fb"; 
  };
in stdenv.mkDerivation rec {
  pname = "xtreme-download-manager";
  version = "7.2.11";
  name = "${pname}-${version}";
  src = source;

  postUnpack = ''
    mv source/app .
    rm -rf source/*
    mv app/* source
  '';

  buildInputs = [ jdk11 maven makeWrapper ];
  buildPhase = ''
    echo "Building with maven repository ${mavenRepository}"
    mvn package --offline -Dmaven.repo.local=${mavenRepository}
    runHook postBuild
  '';

  postBuild = ''
    mv target/xdman.jar target/${name}.jar
  '';

  installPhase = ''
    # create the bin directory
    mkdir -p $out/bin

    # create a symbolic link for the lib directory
    ln -s ${mavenRepository} $out/lib

    # copy out the JAR
    # Maven already setup the classpath to use m2 repository layout
    # with the prefix of lib/
    cp target/${name}.jar $out/

    # create a wrapper that will automatically set the classpath
    # this should be the paths from the dependency derivation
    makeWrapper ${jdk11}/bin/java $out/bin/${pname} \
          --add-flags "-jar $out/${name}.jar"
  '';

  meta = with lib; {
    description = "Powerful download accelerator and video downloader ";
    homepage = "https://subhra74.github.io/xdm/";
    license = licenses.gpl2;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
    broken = true;
  };
}
