{ stdenv,
  lib,
  fetchFromGitHub,
  ant,
  jdk8,
  jre8,
  makeWrapper }:

stdenv.mkDerivation rec {
  pname = "tracer";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "beast-dev";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "1p3z6z716qkfbmi7x7gcs2cnqqjrfi1dvlwn8m9r1kwbvjj2pj0r";
  };

  nativeBuildInputs = [ ant jdk8 makeWrapper ];

  propagatedBuildInputs = [ jre8 ];

  buildPhase = ''
    export LANG="en_US.UTF-8"
    export ANT_OPTS="-Dfile.encoding=utf-8"
    export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
    ant linux
  '';

  installPhase = ''
    # Library.
    mkdir -p $out/lib
    cp build/dist/tracer.jar $out/lib/

    # Binary.
    mkdir -p $out/bin
    makeWrapper ${jre8}/bin/java $out/bin/tracer --add-flags "-jar $out/lib/tracer.jar"
  '';

  meta = with lib; {
    description = "View and analyze traces of MCMC runs";
    license = null;
    homepage = "https://github.com/beast-dev/tracer";
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
