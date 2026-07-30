{
  pkgs,
  jetbrains,
}:

let
  newVersion = "2026.2";
  newBuildNumber = "262.8665.259";

  # kotlin-dist-for-ide-2.4.20-dev-6724 matches the dev snapshot that compose-compiler-plugin
  # 2.4.20-dev-6724 was compiled against (needs IrDeclarationsKt.isSingleFieldValueClass(IrClass, boolean)).
  kotlin-dist-outer = pkgs.stdenvNoCC.mkDerivation {
    name = "kotlin-dist-for-ide-2.4.20-dev-6724";
    src = pkgs.fetchurl {
      url = "https://cache-redirector.jetbrains.com/intellij-dependencies/org/jetbrains/kotlin/kotlin-dist-for-ide/2.4.20-dev-6724/kotlin-dist-for-ide-2.4.20-dev-6724.jar";
      hash = "sha256-QnkSCkv5t65M0GApDj3zDQd29bKTlfD2ingDV8jLL8c=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      unzip -q $src -d $out
    '';
  };

  mkJetBrainsSource =
    pkgs.callPackage "${pkgs.path}/pkgs/applications/editors/jetbrains/source/build.nix"
      {
        jetbrains = jetbrains // {
          jdk-no-jcef-21 = pkgs.jdk25;
        };
      };

  newSrc =
    (mkJetBrainsSource {
      version = newVersion;
      buildNumber = newBuildNumber;
      buildType = "idea";
      ideaHash = "sha256-i089/IBb0vY0nwjt8Q7nqmxqGoypsKFTVW6Oo0bPy64=";
      androidHash = "sha256-xqEuO/GEZC9cbba4jcMxi3rlx8N4JL1/PPPZqVz0GSw=";
      jpsHash = "sha256-nxjoLBpiHYzeYwgjbCSSjTFQTFOtBJTqz1VkmPzXijs=";
      restarterHash = "sha256-acCmC58URd6p9uKZrm0qWgdZkqu9yqCs23v8qgxV2Ag=";
      mvnDeps = ./idea_maven_artefacts.json;
      kotlin-jps-plugin = {
        version = "2.4.20-dev-6724";
        hash = "sha256-7M4XMCjXCgRiOLiIG3JUSmZzei+sbo8crzLejvxYX7w=";
      };
      repositories = [
        "repo1.maven.org/maven2"
        "packages.jetbrains.team/maven/p/ij/intellij-dependencies"
        "dl.google.com/dl/android/maven2"
        "download.jetbrains.com/teamcity-repository"
        "packages.jetbrains.team/maven/p/grazi/grazie-platform-public"
        "packages.jetbrains.team/maven/p/kpm/public"
        "packages.jetbrains.team/maven/p/ki/maven"
        "maven.pkg.jetbrains.space/public/p/compose/dev"
        "packages.jetbrains.team/maven/p/amper/amper"
        "packages.jetbrains.team/maven/p/kt/bootstrap"
      ];
    }).overrideAttrs
      (old: {
        patches =
          pkgs.lib.filter (p: !pkgs.lib.hasSuffix "no-download.patch" (builtins.toString p)) old.patches
          ++ [
            ./no-download-2026.2.patch
            ./jps-compilation-runner.patch
          ];

        nativeBuildInputs = pkgs.lib.forEach old.nativeBuildInputs (
          input:
          if input != null && (input.pname or "") == "jps-bootstrap" then
            let
              kotlin-dist = pkgs.stdenvNoCC.mkDerivation {
                name = "kotlin-dist-for-ide-2.4.20-dev-6724";
                src = pkgs.fetchurl {
                  url = "https://cache-redirector.jetbrains.com/intellij-dependencies/org/jetbrains/kotlin/kotlin-dist-for-ide/2.4.20-dev-6724/kotlin-dist-for-ide-2.4.20-dev-6724.jar";
                  hash = "sha256-QnkSCkv5t65M0GApDj3zDQd29bKTlfD2ingDV8jLL8c=";
                };
                nativeBuildInputs = [ pkgs.unzip ];
                dontUnpack = true;
                installPhase = ''
                  mkdir -p $out
                  unzip -q $src -d $out
                '';
              };
            in
            input.overrideAttrs (oldJps: {
              patches = (oldJps.patches or [ ]) ++ [ ./jps-bootstrap.patch ];
              postPatch = ''
                sed -i 's|KOTLIN_PATH_HERE|${kotlin-dist}|' src/main/java/org/jetbrains/jpsBootstrap/KotlinCompiler.kt

                find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide:2.3.20/kotlin-dist-for-ide:2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide\/2.3.20/kotlin-dist-for-ide\/2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide-2.3.20/kotlin-dist-for-ide-2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-classpath:2.3.20/kotlin-jps-plugin-classpath:2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-classpath\/2.3.20/kotlin-jps-plugin-classpath\/2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-classpath-2.3.20/kotlin-jps-plugin-classpath-2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-tests-for-ide:2.3.20/kotlin-jps-plugin-tests-for-ide:2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-tests-for-ide\/2.3.20/kotlin-jps-plugin-tests-for-ide\/2.4.20-dev-6724/g' {} +
                find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-tests-for-ide-2.3.20/kotlin-jps-plugin-tests-for-ide-2.4.20-dev-6724/g' {} +
              '';
              postFixup = (oldJps.postFixup or "") + ''
                sed -i 's|exec ".*/bin/java"|& --add-exports java.base/sun.nio.ch=ALL-UNNAMED --add-exports java.base/jdk.internal.ref=ALL-UNNAMED --add-opens java.base/jdk.internal.ref=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/sun.nio.ch=ALL-UNNAMED|' $out/bin/jps-bootstrap
                echo ${kotlin-dist} > $out/kotlin-dist-dependency.txt
              '';
            })
          else
            input
        );

        configurePhase =
          builtins.replaceStrings
            [ "ln -s \"$repo\"/.m2 ../.m2" ]
            [
              "cp -r \"$repo\"/.m2 ../.m2 && chmod -R +w ../.m2\n    sh ${./fix-kotlin-compile.sh} ${pkgs.kotlin}\n    "
            ]
            old.configurePhase;

        # Patch KOTLIN_PATH_HERE in the outer build's KotlinCompilerDependencyDownloader.kt:
        # old.postPatch already substituted KOTLIN_PATH_HERE → some kotlin-2.x nix path, so we
        # use a regex sed to replace that with kotlin-dist-for-ide-2.4.20-dev-6724 which matches
        # the compose-compiler-plugin-for-ide-2.4.20-dev-6724 IR API (IrDeclarationsKt etc).
        postPatch = (old.postPatch or "") + ''
          sed -i 's|/nix/store/[a-z0-9]*-kotlin-[0-9][^ "]*|${kotlin-dist-outer}|g' \
            platform/build-scripts/src/org/jetbrains/intellij/build/kotlin/KotlinCompilerDependencyDownloader.kt
        '';

        # The buildPhase has -Djps.kotlin.home=${pkgs.kotlin} hardcoded by nixpkgs build.nix.
        # The compose-compiler-plugin-for-ide-2.4.20-dev-6724 requires IR APIs from Kotlin 2.4.20-dev
        # (e.g. IrDeclarationsKt.isSingleFieldValueClass(IrClass, boolean)) that aren't in 2.2.20.
        # Redirect jps.kotlin.home to kotlin-dist-for-ide-2.4.20-dev-6724.
        preBuild = (old.preBuild or "") + ''
          if [ -f java_argfile ]; then
            sed -i 's|-Djps\.kotlin\.home=[^ ]*|-Djps.kotlin.home=${kotlin-dist-outer}|g' java_argfile
          fi
        '';
        buildPhase = builtins.replaceStrings [ "${pkgs.kotlin}" ] [ "${kotlin-dist-outer}" ] old.buildPhase;
      });

in
jetbrains.idea-oss.overrideAttrs (old: {
  src = newSrc;
  version = newSrc.version;
  buildNumber = newSrc.buildNumber;
  libdbm = newSrc.libdbm;
  fsnotifier = newSrc.fsnotifier;
  meta = (old.meta or { }) // {
    knownVulnerabilities = [ ];
  };
})
