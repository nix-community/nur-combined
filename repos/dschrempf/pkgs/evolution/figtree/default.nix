{ stdenv,
  lib,
  fetchFromGitHub,
  ant,
  jdk8,
  jre8,
  makeWrapper }:

stdenv.mkDerivation rec {
  pname = "figtree";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "rambaut";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "1fymmyqwvvyyh7kpi7mhjx763s1gp3zskfnlv8j6fh7kmbqnyb5g";
  };

  nativeBuildInputs = [ ant jdk8 makeWrapper ];

  propagatedBuildInputs = [ jre8 ];

  buildPhase = ''
    export LANG="en_US.UTF-8"
    export ANT_OPTS="-Dfile.encoding=utf-8"
    export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
    ant linux_unix_Release
  '';

  installPhase = ''
    # Library.
    mkdir -p $out/lib
    cp dist/figtree.jar $out/lib/

    # Binary.
    mkdir -p $out/bin
    makeWrapper ${jre8}/bin/java $out/bin/figtree --add-flags "-jar $out/lib/figtree.jar"
  '';

  meta = with lib; {
    description = "Graphical viewer of phylogenetic trees";
    license = null;
    homepage = "https://github.com/rambaut/figtree";
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.all;
  };
}
