{ stdenv, jre, callPackage, makeWrapper, fetchFromGitHub }:
let
  buildGradle = callPackage ./gradle-env.nix {};
in
buildGradle rec {
  envSpec = ./gradle-env.json;
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "thefinn93";
    repo = "signald";
    rev = version;
    sha256 = "14m5041x74vawajm5hj1pa95v8q2ks4jcl4cjp8xrh1ykdj4jrvy";
  };

  # env variable used by gradle
  VERSION = version;

  gradleFlags = [ "installDist" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out
    cp -r build/install/signald/* $out
    rm $out/bin/signald.bat
    wrapProgram $out/bin/signald \
      --prefix PATH ":" ${stdenv.lib.makeBinPath [ jre ]}
  '';

  meta = with stdenv.lib; {
    description = "A daemon that facilitates communication over Signal.";
    homepage = "https://gitlab.com/thefinn93/signald";
    license = licenses.gpl3;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
