{ lib
, fetchFromGitHub
, maven
, makeWrapper
, jre
, git
, pkgs
}:

let
  # 1. fetch original source
  upstreamSrc = fetchFromGitHub {
    owner = "onthegomap";
    repo = "planetiler";
    rev = "v0.9.3";
    hash = "sha256-T/1QgorliBbXncM6wYtJcAYsMuvwmUsCh3FMFrclvc8=";
    fetchSubmodules = true;
  };

  # 2. make a *patched* copy that will go into the maven-deps derivation
  patchedSrc = pkgs.runCommand "planetiler-0.9.3-src-patched" { } ''
    cp -r ${upstreamSrc} $out
    chmod -R u+w $out

    cat > $out/skip-buildnumber.patch <<'EOF'
diff --git a/pom.xml b/pom.xml
index 1111111..2222222 100644
--- a/pom.xml
+++ b/pom.xml
@@ -248,6 +248,9 @@
         <plugin>
           <groupId>org.codehaus.mojo</groupId>
           <artifactId>buildnumber-maven-plugin</artifactId>
           <version>3.2.1</version>
+          <configuration>
+            <skip>true</skip>
+          </configuration>
           <executions>
             <execution>
               <phase>validate</phase>
EOF

    cd $out
    patch -p1 < skip-buildnumber.patch

    # just to be safe, show it's patched
    grep -n "buildnumber-maven-plugin" pom.xml
  '';
in
maven.buildMavenPackage rec {
  pname = "planetiler";
  version = "0.9.3";

  src = patchedSrc;
  
  mvnHash = lib.fakeHash;

  #mvnFlags = [
  #  # option 1: just skip the plugin completely
  #  "-Dmaven.buildNumber.skip=true"

  #  # option 2 (alternative): let it succeed even without .git
  #  "-Dmaven.buildNumber.revisionOnScmFailure=${version}"
  #];

  # edit the root POM before building
  #postPatch = ''
  #  # we add a <configuration><skip>true</skip></configuration> to that plugin
  #  substituteInPlace pom.xml \
  #    --replace "<artifactId>buildnumber-maven-plugin</artifactId>" "<artifactId>buildnumber-maven-plugin</artifactId><configuration><skip>true</skip></configuration>"
  #'';

  postPatch = ''
  # Remove the whole buildnumber plugin block
  # This assumes the snippet in the upstream pom.xml is exactly as you pasted it
  sed -i '/<artifactId>buildnumber-maven-plugin<\/artifactId>/{N;N;N;N;N;d;}' pom.xml
'';


  nativeBuildInputs = [
    makeWrapper
    git
    pkgs.keepBuildTree
  ];

  #installPhase = ''
  #  runHook preInstall

  #  mkdir -p $out/bin $out/share/planetiler
  #  install -Dm644 jd-cli/target/planetiler.jar $out/share/planetiler

  #  makeWrapper ${jre}/bin/java $out/bin/planetiler \
  #    --add-flags "-jar $out/share/jd-cli/planetiler.jar"

  #  runHook postInstall
  #'';


  meta = {
    description = "Flexible tool to build planet-scale vector tilesets from OpenStreetMap data fast";
    homepage = "https://github.com/onthegomap/planetiler";
    license = lib.licenses.asl20;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "planetiler";
    platforms = lib.platforms.all;
  };
}
