{ stdenv, buildPackages, fetchFromGitHub, makeDesktopItem, makeWrapper
, writeText
, jdk, jre, swt
}:

let
  pname = "ipscan";
  desktopName = "Angry IP Scanner";
  version = "3.5.5";
  meta = with stdenv.lib; {
    description = "Fast and friendly network scanner";
    longDescription = ''
      Angry IP Scanner is a cross-platform network scanner written in Java.
      It can scan IP-based networks in any range, scan ports, and resolve
      other information.
      The program provides an easy to use GUI interface and is very
      extensible, see ${homepage} for more information.
    '';
    homepage = https://angryip.org;
    license = with licenses; gpl2;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };

  src = fetchFromGitHub {
    owner = "angryip";
    repo = "ipscan";
    rev = version;
    sha256 = "19w896qk34mgzpm022da79jzmp9mhxv560syhf14dx2pcqndsy61";
  };

  # Only cache the deps; don't build (from
  # https://stackoverflow.com/questions/21814652/how-to-download-dependencies-in-gradle/38528497 )
  gradleDepsInit = writeText "init.gradle" ''
    gradle.projectsEvaluated {
      rootProject {
        task fetchDeps {
          configurations.compileClasspath.files
          configurations.annotationProcessor.files
          configurations.runtimeClasspath.files
          configurations.testCompileClasspath.files
          configurations.testRuntimeClasspath.files
          logger.lifecycle 'Fetched all dependencies.'
        }
      }
    }
  '';

  # fake build to pre-download deps into fixed-output derivation
  deps = stdenv.mkDerivation {
    pname = "${pname}-deps";
    inherit version;

    inherit src;

    nativeBuildInputs = [
      buildPackages.gradle
      buildPackages.perl
    ];

    buildPhase = ''
      export GRADLE_USER_HOME=$TMPDIR/gradle-user-home;
      gradle --no-daemon --init-script ${gradleDepsInit} fetchDeps
    '';

    # Mavenize dependency paths
    # e.g. org.codehaus.groovy/groovy/2.4.0/{hash}/groovy-2.4.0.jar ->
    #   org/codehaus/groovy/groovy/2.4.0/groovy-2.4.0.jar
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f \
          -regex '.*\.\(jar\|pom\)' \
        | perl -pe \
      's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$#'\
      ' ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "05v5xjz2h7n1sk0996q7xp0y7q4h6q0afj1m7ifkds4jlpz0zll5";
  };

  hostPkgDeps = {
    x86_64-darwin = rec { platform = "mac";
      jars = "[]"; libs = "[]"; };
    x86_64-linux = rec { platform = "linux64";
      jars = "[]"; libs = "'ext/rocksaw/lib/${platform}/librocksaw.so'"; };
    i686-linux = rec { platform = "linux";
      jars = "[]"; libs = "'ext/rocksaw/lib/${platform}/librocksaw.so'"; };
  }.${stdenv.hostPlatform.system} or (throw
    "unsupported system ${stdenv.hostPlatform.system}");

  # Point to our local deps repo and make a Nix-ish JAR build work
  gradleInit = writeText "init.gradle" ''
    logger.lifecycle 'Replacing Maven repositories with ${deps}...'

    gradle.projectsLoaded {
      rootProject.allprojects {
        buildscript {
          repositories {
            clear()
            maven { url '${deps}' }
          }
        }
        repositories {
          clear()
          maven { url '${deps}' }
        }
      }
    }
    gradle.projectsEvaluated {
      rootProject {
        packageTask('nix', ${hostPkgDeps.jars}, ${hostPkgDeps.libs}) {
        }
        tasks.withType(AbstractArchiveTask) {
          preserveFileTimestamps = false
          reproducibleFileOrder = true
        }
      }
    }
  '';

  desktopItem = makeDesktopItem {
    inherit desktopName;
    categories = "Application;Network;Internet;";
    comment = meta.description;
    exec = "ipscan";
    genericName = "Network scanner";
    icon = "ipscan";
    name = pname;
  };
in stdenv.mkDerivation {
  inherit pname version;

  inherit src;

  nativeBuildInputs = [
    buildPackages.canonicalize-jars-hook
    buildPackages.gradle
    buildPackages.makeWrapper
  ];
  buildInputs = [ jdk ];

  patches = [
    ./rt-jar-detection.patch
  ];

  LANG = "${if stdenv.isDarwin then "en_US" else "C"}.UTF-8";

  # TODO package Java Native Access (JNA) in Nixpkgs & ln -sf in here
  postPatch = ''
    echo "rootProject.name = 'ipscan'" > settings.gradle
    ln -s ${swt}/jars/swt.jar lib/swt-nix.jar
  '';

  buildPhase = ''
    export GRADLE_USER_HOME=$(mktemp -d)
    gradle --offline --no-daemon --info --init-script ${gradleInit} nix
  '';

  installPhase = ''
    mkdir -p $out/share/{${pname},pixmaps}

    cp build/libs/ipscan-nix-${version}.jar $out/share/${pname}/ipscan.jar
    cp resources/images/icon128.png $out/share/pixmaps/ipscan.png

    makeWrapper ${jre}/bin/java $out/bin/ipscan \
      --add-flags \
        "-Djava.library.path=${swt}/lib -jar $out/share/${pname}/ipscan.jar"

    ${desktopItem.buildCommand}
  '';

  inherit meta;
}
