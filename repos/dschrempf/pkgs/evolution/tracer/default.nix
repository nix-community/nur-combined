{ stdenv
, lib
, fetchFromGitHub
, ant
, jdk
, jre
, makeWrapper
}:

let
  pname = "tracer";
  version = "1.7.2";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "beast-dev";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-ZuXG2ZgwiLS+fpaH/UlF8oYgfeX8YjGyR6+uj/wfLbw=";
  };

  nativeBuildInputs = [ ant jdk makeWrapper ];

  propagatedBuildInputs = [ jre ];

  buildPhase = ''
    ant linux
  '';

  installPhase = ''
    # Library.
    mkdir -p $out/lib
    cp build/dist/tracer.jar $out/lib/

    # Binary.
    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/tracer --add-flags "-jar $out/lib/tracer.jar"
  '';

  meta = with lib; {
    description = "View and analyze traces of MCMC runs";
    license = null;
    homepage = "https://github.com/beast-dev/tracer";
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
