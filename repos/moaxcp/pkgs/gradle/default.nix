{ stdenv, fetchurl, unzip, jdk, makeWrapper }:
let
  pname = "gradle";
in rec {
  gradleGen = {version, nativeVersion, src} : stdenv.mkDerivation {
    inherit pname version nativeVersion src;

    dontBuild = true;

    buildInputs = [ unzip jdk makeWrapper ];

    installPhase = ''
      mkdir -pv $out/lib/gradle/
      cp -rv lib/ $out/lib/gradle/

      gradle_launcher_jar=$(echo $out/lib/gradle/lib/gradle-launcher-*.jar)
      test -f $gradle_launcher_jar
      makeWrapper ${jdk}/bin/java $out/bin/gradle \
        --set JAVA_HOME ${jdk} \
        --set PATH ${jdk}/bin \
        --add-flags "-classpath $gradle_launcher_jar org.gradle.launcher.GradleMain"
    '';

    fixupPhase = if (!stdenv.isLinux) then ":" else
      let arch = if stdenv.is64bit then "amd64" else "i386"; in ''
        mkdir patching
        pushd patching
        jar xf $out/lib/gradle/lib/native-platform-linux-${arch}-${nativeVersion}.jar
        patchelf --set-rpath "${stdenv.cc.cc.lib}/lib:${stdenv.cc.cc.lib}/lib64" net/rubygrapefruit/platform/linux-${arch}/libnative-platform.so
        jar cf native-platform-linux-${arch}-${nativeVersion}.jar .
        mv native-platform-linux-${arch}-${nativeVersion}.jar $out/lib/gradle/lib/
        popd

        # The scanner doesn't pick up the runtime dependency in the jar.
        # Manually add a reference where it will be found.
        mkdir $out/nix-support
        echo ${stdenv.cc.cc} > $out/nix-support/manual-runtime-dependencies
      '';

      installCheckPhase = ''
        $out/bin/gradle --version 2>&1 | grep -q "Gradle ${version}"
      '';

    meta = {
      description = "Enterprise-grade build system";
      longDescription = ''
        Gradle is a build system which offers you ease, power and freedom.
        You can choose the balance for yourself. It has powerful multi-project
        build support. It has a layer on top of Ivy that provides a
        build-by-convention integration for Ivy. It gives you always the choice
        between the flexibility of Ant and the convenience of a
        build-by-convention behavior.
      '';
      homepage = http://www.gradle.org/;
      license = stdenv.lib.licenses.asl20;
      platforms = stdenv.lib.platforms.unix;
    };
  };

  gradle-6_4 = gradleGen rec {
    version = "6.4";
    nativeVersion = "0.22-milestone-2";

    src = fetchurl {
      url = "https://services.gradle.org/distributions/gradle-${version}-bin.zip";
      sha256 = "1jdcvczlcg77klkl336553w09jxizkfjcqlzficyg1vqcfgnb25q";
    };
  };

  gradle-6_3 = gradleGen rec {
    version = "6.3";
    nativeVersion = "0.22-milestone-1";

    src = fetchurl {
      url = "https://services.gradle.org/distributions/gradle-${version}-bin.zip";
      sha256 = "0s0ppngixkkaz1h4nqzwycjcilbrc9rbc1vi6k34aiqzxzz991q3";
    };
  };

  gradle-6_2_2 = gradleGen rec {
    version = "6.2.2";
    nativeVersion = "0.21";

    src = fetchurl {
      url = "https://services.gradle.org/distributions/gradle-${version}-bin.zip";
      sha256 = "05vxzcr51v5sq3kl47xgdmpgf3cfv6s71a6p4616s9w6p4qs4sqg";
    };
  };

  gradle-5_6_4 = gradleGen rec {
    version = "5.6.4";
    nativeVersion = "0.18";

    src = fetchurl {
      url = "https://services.gradle.org/distributions/gradle-${version}-bin.zip";
      sha256 = "1f3067073041bc44554d0efe5d402a33bc3d3c93cc39ab684f308586d732a80d";
    };
  };

  gradle-4_10_3 = gradleGen rec {
    version = "4.10.3";
    nativeVersion = "0.14";

    src = fetchurl {
      url = "https://services.gradle.org/distributions/gradle-${version}-bin.zip";
      sha256 = "0vhqxnk0yj3q9jam5w4kpia70i4h0q4pjxxqwynh3qml0vrcn9l6";
    };
  };
}
