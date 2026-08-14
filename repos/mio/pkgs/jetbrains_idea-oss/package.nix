{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  callPackage,
  jetbrains,
  kotlin,
  jdk25,
  path,
}:

let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    filter
    hasSuffix
    ;

  version = "2026.2.1";
  buildNumber = "262.9437.185";

  # compose-compiler-plugin-for-ide 2.4.20-ij262-34 needs IR APIs from this
  # Kotlin-for-IDE snapshot (e.g. IrDeclarationsKt.isSingleFieldValueClass).
  kotlinDistVersion = "2.4.20-ij262-34";
  kotlinIdeOldVersion = "2.3.20";

  kotlinDist = stdenvNoCC.mkDerivation {
    pname = "kotlin-dist-for-ide";
    version = kotlinDistVersion;

    src = fetchurl {
      url = "https://cache-redirector.jetbrains.com/intellij-dependencies/org/jetbrains/kotlin/kotlin-dist-for-ide/${kotlinDistVersion}/kotlin-dist-for-ide-${kotlinDistVersion}.jar";
      hash = "sha256-gzTs22ps2Em9Sp0l85EMjuFrLz5AuxXCxXB5JQMcROI=";
    };

    nativeBuildInputs = [ unzip ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      unzip -q $src -d $out
      runHook postInstall
    '';
  };

  # Recreate the kotlin override used by nixpkgs' JPS builder so we can
  # substitute its store path with substituteInPlace --replace-fail.
  kotlinNixpkgs = kotlin.overrideAttrs (oldAttrs: {
    version = "2.2.20";
    src = fetchurl {
      url = oldAttrs.src.url;
      hash = "sha256-gfAmTJBztcu9s/+EGM8sXawHaHn8FW+hpkYvWlrMRCA=";
    };
  });

  # JPS builder from nixpkgs (idea-oss still uses this on unstable; Bazel is not merged yet).
  # 2026.2 needs JDK 25; the builder still looks up jetbrains.jdk-no-jcef-21.
  mkJetBrainsSource = callPackage "${path}/pkgs/applications/editors/jetbrains/source/build.nix" {
    jetbrains = jetbrains // {
      jdk-no-jcef-21 = jdk25;
    };
  };

  jpsBootstrapJavaFlags = [
    "--add-exports java.base/sun.nio.ch=ALL-UNNAMED"
    "--add-exports java.base/jdk.internal.ref=ALL-UNNAMED"
    "--add-opens java.base/jdk.internal.ref=ALL-UNNAMED"
    "--add-opens java.base/java.util=ALL-UNNAMED"
    "--add-opens java.base/java.lang=ALL-UNNAMED"
    "--add-opens java.base/sun.nio.ch=ALL-UNNAMED"
  ];

  bumpKotlinIdeArtifacts = ''
    for artefact in kotlin-dist-for-ide kotlin-jps-plugin-classpath kotlin-jps-plugin-tests-for-ide; do
      find . -type f -name '*.xml' -exec sed -i \
        -e "s|''${artefact}:${kotlinIdeOldVersion}|''${artefact}:${kotlinDistVersion}|g" \
        -e "s|''${artefact}/${kotlinIdeOldVersion}|''${artefact}/${kotlinDistVersion}|g" \
        -e "s|''${artefact}-${kotlinIdeOldVersion}|''${artefact}-${kotlinDistVersion}|g" \
        {} +
    done
  '';

  patchJpsBootstrap =
    drv:
    drv.overrideAttrs (oldJps: {
      patches = (oldJps.patches or [ ]) ++ [ ./jps-bootstrap.patch ];

      postPatch = ''
        substituteInPlace src/main/java/org/jetbrains/jpsBootstrap/KotlinCompiler.kt \
          --replace-fail 'KOTLIN_PATH_HERE' '${kotlinDist}'
        ${bumpKotlinIdeArtifacts}
      '';

      # Flags must be JVM options (before the main class), not wrapper args.
      postFixup = (oldJps.postFixup or "") + ''
        substituteInPlace $out/bin/jps-bootstrap \
          --replace-fail '-cp ' '${concatStringsSep " " jpsBootstrapJavaFlags} -cp '
      '';
    });

  src =
    (mkJetBrainsSource {
      inherit version buildNumber;
      buildType = "idea";
      ideaHash = "sha256-iwT2QqmLtsbNyQgoBY26pfxXVEzjSnQ99Ort63a9GXo=";
      androidHash = "sha256-poTjTGR10Ne8VKDWApgu+XcCFMLiAacSFYpIp1tsgbk=";
      jpsHash = "sha256-nxjoLBpiHYzeYwgjbCSSjTFQTFOtBJTqz1VkmPzXijs=";
      restarterHash = "sha256-acCmC58URd6p9uKZrm0qWgdZkqu9yqCs23v8qgxV2Ag=";
      mvnDeps = ./idea_maven_artefacts.json;
      kotlin-jps-plugin = {
        version = kotlinDistVersion;
        hash = "sha256-o5R0gSzaSOkK4omBxNf9AsnD6bOsASS416fbqqOAPmE=";
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
        patches = filter (p: !hasSuffix "no-download.patch" (toString p)) old.patches ++ [
          ./no-download-2026.2.patch
        ];

        nativeBuildInputs = map (
          input:
          if input != null && (input.pname or "") == "jps-bootstrap" then patchJpsBootstrap input else input
        ) old.nativeBuildInputs;

        postPatch = (old.postPatch or "") + ''
          substituteInPlace \
            platform/build-scripts/src/org/jetbrains/intellij/build/kotlin/KotlinCompilerDependencyDownloader.kt \
            --replace-fail '${kotlinNixpkgs}' '${kotlinDist}'

          export COMPOSE_COMPILER_PLUGIN="$repo/.m2/repository/org/jetbrains/kotlin/compose-compiler-plugin-for-ide/${kotlinDistVersion}/compose-compiler-plugin-for-ide-${kotlinDistVersion}.jar"
          export KOTLIN_IDE_NEW=${escapeShellArg kotlinDistVersion}
          ${bumpKotlinIdeArtifacts}
          # source (not bash) so stdenv's substituteInPlace is in scope
          (
            set -euo pipefail
            source ${./fix-kotlin-compile.sh}
          )
        '';

        configurePhase = ''
          runHook preConfigure

          cp -r "$repo"/.m2 ../.m2
          chmod -R +w ../.m2

          export JPS_BOOTSTRAP_COMMUNITY_HOME="$PWD"
          jps-bootstrap \
            -Dbuild.number=${buildNumber} \
            -Djps.kotlin.home=${kotlinDist} \
            -Dintellij.build.target.os=linux \
            -Dintellij.build.target.arch=x64 \
            -Dintellij.build.skip.build.steps=mac_artifacts,mac_dmg,mac_sit,windows_exe_installer,windows_sign,repair_utility_bundle_step,sources_archive \
            -Dintellij.build.unix.snaps=false \
            --java-argfile-target=java_argfile \
            "$PWD" \
            intellij.idea.community.build \
            OpenSourceCommunityInstallersBuildTarget

          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          java -Djps.kotlin.home=${kotlinDist} "@java_argfile"
          runHook postBuild
        '';
      });

in
jetbrains.idea-oss.overrideAttrs (old: {
  inherit src;
  inherit (src)
    version
    buildNumber
    libdbm
    fsnotifier
    ;
  # nixpkgs marks the older idea-oss as vulnerable; this is a newer source build.
  meta = (old.meta or { }) // {
    knownVulnerabilities = [ ];
  };
})
