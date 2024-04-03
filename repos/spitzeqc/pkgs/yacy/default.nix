# https://github.com/milahu/nur-packages/blob/master/pkgs/yacy/yacy.nix
{ config
, lib
, stdenv
, fetchFromGitHub
, makeWrapper
, jre
, ant
, git
, which
, getopt
, curl
}:

stdenv.mkDerivation rec {
  pname = "yacy";
  # last stable release was in year 2016
  version = "unstable-2024-03-29";

  /*
  # local source
  src = ./src/yacy_search_server;
  buildPhase = ''
    # cleanup src, force rebuild
    rm lib/yacycore.jar
    ant clean
  '';
  */

  src = fetchFromGitHub {
    owner = "yacy";
    repo = "yacy_search_server";
    rev = "656d47c1ac9b2ad6882cb626a44c7582316a6fea";
    hash = "sha256-NNm70qu36GoEwaqNajLw+DLuEVcqleVUd5CUEcD61qY=";
  };

  # TODO fetch jar's separately
  # TODO faster. currently takes 16 minutes
  ivyCache = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    inherit src;
    nativeBuildInputs = [ jre ant ];
    buildPhase = ''
      ant resolve
    '';
    installPhase = ''
      mkdir $out
      cp -r ivy $out
      cp -r lib $out
      cp -r libt $out
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-P8awlmajxoqUuM9d16VjIyomO+GjuILckU5FPNVfj1E=";
  };

  #  echo ivyCache = ${ivyCache}
  postUnpack = ''
    (
      cd $sourceRoot
      ls -l
      cp -r ${ivyCache}/ivy .
      chmod -R +w ivy
      ln -v -s ${ivyCache}/lib/* lib/ || true
      ln -v -s ${ivyCache}/libt/* libt/ || true
      ls -l
    )
  '';

  nativeBuildInputs = [ jre ant git makeWrapper ];
  buildInputs = [ jre which getopt curl ];

  buildPhase = ''
    # emulate <target name="resolve"
    ivyResolvedPaths="$(
      echo '<path id="compile.path">'
      for f in lib/*.jar
      do
        f="$(readlink -f "$f")"
        echo '  <pathelement location="'"$f"'" />'
      done
      echo '</path>'
      echo '<path id="test.path">'
      for f in libt/*.jar
      do
        f="$(readlink -f "$f")"
        echo '  <pathelement location="'"$f"'" />'
      done
      echo '</path>'
    )"

    substituteInPlace build.xml \
      --replace '</project>' "$ivyResolvedPaths</project>"

    ( set -x; cat build.xml ) # debug

    ant -Dtarget-resolve-already-run=true compile
  '';

  # TODO checkPhase

  installPhase = ''
    mkdir -p $out/{opt,bin}
    cp -r . $out/opt/yacy

    ln -s $out/opt/yacy/startYACY.sh $out/bin/startYACY
    ln -s $out/opt/yacy/stopYACY.sh $out/bin/stopYACY
  '';

  patches = [ ./startYACY.patch ./stopYACY.patch ./checkDataFolder.patch ];

  postPatch = ''
    substituteInPlace stopYACY.sh \
      --replace bin/ $out/opt/yacy/bin/

    rm *.bat
  '';

  postFixup = ''
    wrapProgram $out/opt/yacy/startYACY.sh \
      --prefix PATH : ${lib.makeBinPath [ jre which getopt ]}
    wrapProgram $out/opt/yacy/bin/apicall.sh \
      --prefix PATH : ${lib.makeBinPath [ which curl ]}
  '';

  meta = with lib; {
    description = "Distributed Peer-to-Peer Web Search Engine and Intranet Search Appliance";
    homepage = "https://github.com/yacy/yacy_search_server";
    license = licenses.lgpl2Plus;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
