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

  # deps-only Maven repository (fixed-output)
  mavenRepo = stdenv.mkDerivation {
    name = "${pname}-maven-repo-${version}";
    inherit src;

    nativeBuildInputs = [ leiningen maven ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-4nrFBrtVYbkjWw5McUH5QXtaWuJkh4Xj7tugGQrkzl0=";

    dontFixup = true;

    buildPhase = ''
      export HOME=$TMPDIR
      export LEIN_HOME=$HOME/.lein
      export LC_ALL=C
      export TZ=UTC

      # generate pom.xml from Lein project
      lein pom

      # fetch deps + plugins (NO mvn package here)
      mvn -f pom.xml \
        -Dmaven.repo.local=$out \
        -DskipTests \
        dependency:go-offline
    '';

    installPhase = ''
      find $out -type f \
        -name \*.lastUpdated -o \
        -name resolver-status.properties -o \
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
    export LC_ALL=C
    export TZ=UTC

    mkdir -p $HOME/.m2
    ln -s ${mavenRepo} $HOME/.m2/repository

    lein -o uberjar

    echo "target contents:"
    ls -la target
  '';

  installPhase = ''
    mkdir -p $out/share/${pname} $out/bin

    jar="$(find target -maxdepth 1 -type f -name '*standalone.jar' | head -n1)"
    if [ -z "$jar" ]; then
      echo "ERROR: lein uberjar did not produce *standalone.jar"
      ls -la target || true
      exit 1
    fi

    cp -v "$jar" $out/share/${pname}/${pname}.jar

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

