{ version, sha256, depsSha256, defaultScalaVersion, archive ? false}:
{ lib, stdenv, runCommand, fetchzip, makeWrapper, jdk, pythonPackages, coreutils
, inetutils, hadoop, procps, maven, RSupport ? true, R, buildMavenRepositoryFromLockFile, scalaVersion ? "2.12.10" }:

with lib;

let
  pname = "spark";

  src = fetchzip {
    url = if archive
      then "https://archive.apache.org/dist/${pname}/${pname}-${version}/${pname}-${version}.tgz"
      else "mirror://apache/spark/${pname}-${version}/${pname}-${version}.tgz";
    inherit sha256;
  };

  configurePhase = lib.optionalString (defaultScalaVersion != scalaVersion) ''
    ./dev/change-scala-version.sh ${lib.versions.majorMinor scalaVersion}
  '';

  prePatch = ''
    patchShebangs ./dev
    substituteInPlace pom.xml --replace "${defaultScalaVersion}" "${scalaVersion}"
  '';

  mavenFlags =
    "-Dmaven.test.skip -DskipTests -Dhadoop.version=${hadoop.version} -Pyarn -Pscala-${lib.versions.majorMinor scalaVersion} -Phadoop-provided";

  deps = buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };

  dist-bin = stdenv.mkDerivation {
    pname = "${pname}-bin";
    inherit version src configurePhase;

    patches = [ ./dont-query-maven.patch ];

    prePatch = prePatch + ''
      mkdir -p .m2
      cp -dpR ${deps}/* .m2
      chmod +w -R .m2
    '';

    postPatch = ''
      substituteInPlace ./dev/make-distribution.sh \
        --subst-var-by version ${version} \
        --subst-var-by scalaVersion ${lib.versions.majorMinor scalaVersion} \
        --subst-var-by hadoopVersion ${hadoop.version}
    '';

    buildPhase = ''
      ./dev/make-distribution.sh --mvn mvn ${mavenFlags} -Dmaven.repo.local="$PWD/.m2" --offline
    '';

    installPhase = ''
      mkdir $out
      cp -R dist/* $out/

      for n in $(find $out/bin -type f ! -name "*.*"); do
        substituteInPlace "$n" --replace dirname ${coreutils.out}/bin/dirname
      done

      for n in $(find $out/sbin/ -type f -executable); do
        substituteInPlace "$n" \
          --replace dirname ${coreutils}/bin/dirname \
          --replace hostname ${inetutils}/bin/hostname \
          --replace ps ${procps}/bin/ps
      done
    '';

    nativeBuildInputs = [ maven ];

    buildInputs = [ jdk ];
  };

in runCommand "${pname}-${version}" {
  passthru = { inherit deps dist-bin hadoop; };

  buildInputs = [ makeWrapper ];

  meta = {
    description =
      "Apache Spark is a fast and general engine for large-scale data processing";
    homepage = "http://spark.apache.org";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with maintainers; [ thoughtpolice offline kamilchm ];
    repositories.git = "git://git.apache.org/spark.git";
  };
} ''
  mkdir -p $out/bin

  for n in $(find ${dist-bin}/sbin/ -type f -executable); do
    makeWrapper "$n" "$out/bin/$(basename $n)"\
      --set JAVA_HOME ${jdk.home} \
      --set SPARK_HOME ${dist-bin} \
      --set SPARK_DIST_CLASSPATH "$(${hadoop}/bin/hadoop classpath)"
  done
''

