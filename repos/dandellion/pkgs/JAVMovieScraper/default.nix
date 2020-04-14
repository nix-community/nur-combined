{ pkgs, fetchFromGitHub, gradleGen, openjdk11}:
with pkgs;
let
  buildGradle = callPackage ./gradle-env.nix { gradleGen = gradleGen.override { java = openjdk11; }; };
in
buildGradle {
  envSpec = ./gradle-env.json;

  src = fetchFromGitHub {
    owner = "DoctorD1501";
    repo = "JAVMovieScraper";
    rev = "fcd695b2981d36aea01c9153ee2ef1c27cd42c78";
    sha256 = "0qwdzyfmscjj75jyh9mnk1rlmy12fnnsqbhvp9xdsnfhwy78x6xm";
  };

  patches = [
    ./0001-disable_spotless.patch
    ./0002-respectXDG.patch
    ./0003-disable-codacy.patch
  ];

  gradleFlags = [ "DistTar" ];

  buildInputs = [ openjdk11 ];
  
  installPhase = ''
    mkdir -p $out/bin
    tar xvf ./build/distributions/source--1.tar
    cd source--1/
    cp -r ./lib $out
    cat ./bin/source | sed 's~$JAVA_HOME~${openjdk11}~' > $out/bin/JAVMovieScraper
    chmod +x $out/bin/JAVMovieScraper
  '';

  meta = with pkgs.stdenv.lib; {
    broken = true;
    description = "A program to fetch metadata for Japanese Adult Video";
    homepage = "https://github.com/DoctorD1501/JAVMovieScraper";
    license = licenses.gpl2;
  };

}




