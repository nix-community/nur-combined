{ lib
, stdenv
, fetchFromGitHub
, maven
, leiningen
, makeWrapper
, jre
, gtk3
, glib
, gsettings-desktop-schemas
, wrapGAppsHook3
}:

let
  pname = "clooj";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "SZanko";
    repo = "clooj";
    rev = "966ed9bd0efedd97735274f3eb95b9051a9497bf";
    hash = "sha256-mMn/Qpxbr6Vcv1WA/iespxp8YkEJILobmcJ165Xah3E=";
  };

  mavenRepo = stdenv.mkDerivation {
    name = "${pname}-maven-repo-${version}";
    inherit src;

    nativeBuildInputs = [ leiningen maven ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-fwYcZ45KSGeoS2RzbNLPwd2NbCg0Jl2E7pkD65kZ9x8=";

    dontFixup = true;

    buildPhase = ''
      export HOME=$TMPDIR
      lein pom
      mvn -f pom.xml -Dmaven.repo.local=$out -DskipTests package
    '';

    installPhase = ''
      find $out -type f \
        -name \*.lastUpdated -or \
        -name resolver-status.properties -or \
        -name _remote.repositories \
        -delete
    '';
  };
in

stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ leiningen makeWrapper wrapGAppsHook3 ];
  buildInputs = [ jre gtk3 glib gsettings-desktop-schemas ];

  buildPhase = ''
    export HOME=$TMPDIR
    export LEIN_HOME=$HOME/.lein

    mkdir -p $HOME/.m2
    ln -s ${mavenRepo} $HOME/.m2/repository

    lein -o uberjar
  '';

  installPhase = ''
    mkdir -p $out/share/${pname} $out/bin
    cp target/*standalone.jar $out/share/${pname}/${pname}.jar
    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/${pname}/${pname}.jar"
  '';

  dontWrapGApps = false;

  meta = {
    description = "Clooj, a lightweight IDE for clojure";
    homepage = "https://github.com/clj-commons/clooj";
    license = lib.licenses.epl10;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "clooj";
    platforms = lib.platforms.all;
  };
}


