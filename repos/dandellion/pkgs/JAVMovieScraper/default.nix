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

  patches = [ ./disable_spotless.patch ./respectXDG.patch ];

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
}




