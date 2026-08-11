{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, jre
, ant
, git
}:

stdenv.mkDerivation rec {
  pname = "yacy";
  # last stable release was in year 2016
  version = "unstable-2022-11-22";

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
    # fix read-only applicationRoot
    # https://github.com/yacy/yacy_search_server/pull/541
    rev = "77958383cf2a5cb19eb24cda989db61d6197cbd4";
    hash = "sha256-2ny+Hn1U7X7SwgZqUDYvAAYWaczW3cxW5wlf+io0QCs=";
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
    outputHash = "sha256-UXIVnVm4jnVNOPqniXGhJcYdLIAxPDh3Ht82XTM/Xsw=";
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
    mkdir -p $out/opt
    cp -r . $out/opt/yacy
  '';

  # TODO create $out/bin/yacy
  # TODO create nixos module: services.yacy

  postFixup = ''
    wrapProgram $out/opt/yacy/startYACY.sh \
      --prefix PATH : ${lib.makeBinPath [ jre ]}
  '';

  meta = with lib; {
    description = "Distributed Peer-to-Peer Web Search Engine and Intranet Search Appliance";
    homepage = "https://github.com/yacy/yacy_search_server";
    license = licenses.lgpl2Plus;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
