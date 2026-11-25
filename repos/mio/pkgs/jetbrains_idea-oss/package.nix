{
  applyPatches,
  callPackage,
  fetchurl,
  fsnotifier,
  jetbrains,
  lib,
  maven,
  path,
  stdenv,
  stdenvNoCC,
  unzip,
  zlib,
}:

let
  isDarwin = stdenv.hostPlatform.isDarwin;

  # The 2026.3 tree pins Kotlin 2.4.21-RC in .idea/kotlinc.xml and is developed
  # against JBR 25.
  kotlinVersion = "2.4.21-RC";
  jcefBuild = "263-b16";
  jcefArch = if stdenv.hostPlatform.isAarch64 then "aarch64" else "x64";

  # JetBrains publishes the JCEF and JBR archives per OS; the IDE build normally
  # downloads them, the patches point it at these copies instead.
  jcefOs = if isDarwin then "osx" else "linux";

  # The source tree refers to this jar through the $KOTLIN_COMPOSE_COMPILER_PLUGIN$ macro.
  # The JPS build uses kotlin-dist-for-ide, so the non-embeddable plugin is required
  # (the -embeddable jar wants the relocated kotlin-compiler-embeddable classes).
  composeCompilerPlugin = fetchurl {
    url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-compose-compiler-plugin/${kotlinVersion}/kotlin-compose-compiler-plugin-${kotlinVersion}.jar";
    hash = "sha256-VzMlspgfPIwMxptbrM74yAlsRlWr9XomzBEOyhg9x6o=";
  };

  # Upstream's compiler distribution for this release, so the compiler matches
  # the kotlin-jps-plugin-classpath jar recorded in source_args.json.
  kotlinDist = stdenvNoCC.mkDerivation {
    pname = "kotlin-dist-for-ide";
    version = kotlinVersion;
    src = fetchurl {
      url = "https://packages.jetbrains.team/maven/p/ij/intellij-dependencies/org/jetbrains/kotlin/kotlin-dist-for-ide/${kotlinVersion}/kotlin-dist-for-ide-${kotlinVersion}.jar";
      hash = "sha256-+Bpd3wanezqYCCxvEi39RWgLfH31Y1VPb+DcUC/zV2A=";
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

  # The JCEF plugin binaries are normally downloaded while building the distribution.
  jcefArchive = fetchurl {
    url = "https://cache-redirector.jetbrains.com/intellij-jbr/jcef-${jcefOs}-${jcefArch}-${jcefBuild}.tar.gz";
    hash =
      if isDarwin then
        {
          aarch64 = "sha256-KuL6IFCTSH4ZZCFUuMyvWrZsT6gfV0RDL6hcIN4iK5s=";
        }
        .${jcefArch}
      else
        {
          x64 = "sha256-rMmW7P+kPXcux5YpTek6a1UmszR4wPdswWq1+RdHTJ0=";
          aarch64 = "sha256-s2vJRKRZDagNm4dWqqnlH6Fux4oBo77dOmsFtclp7Zs=";
        }
        .${jcefArch};
  };

  # Native helpers that 2026.3 adds to the distribution are normally downloaded
  # while packaging (versions from build/dependencies.properties).
  restarterArchive = fetchurl {
    url = "https://cache-redirector.jetbrains.com/intellij-dependencies/org/jetbrains/intellij/deps/restarter/243.6005/restarter-243.6005.tar.gz";
    hash = "sha256-PW27NRcB5xupXEfHcgsYadfxKxmWcotBySNm8qKgx2g=";
  };

  libwebpArchive = fetchurl {
    url = "https://cache-redirector.jetbrains.com/intellij-dependencies/org/jetbrains/intellij/deps/libwebp/1.6.0/libwebp-1.6.0.tar.gz";
    hash = "sha256-Sl2P7EY4rgelbo0AkphlDQfNBsXd29Bt6Dwo1cYvaKU=";
  };

  libGhosttyVtArchive = fetchurl {
    url = "https://packages.jetbrains.team/files/p/ij/intellij-build-dependencies/libghostty-vt/libghostty-vt-0.1.0-tip+3a3047f6b.8.zip.zst";
    hash = "sha256-a1HgeiFLEU+HJMSrDt4uMaqJ8DdyOKt2ouJQZLvh2jk=";
  };

  # On Darwin the IDE is packaged as an application bundle that carries its own
  # JBR, so the build needs a macOS JBR archive instead of the Linux-only
  # nixpkgs JetBrains JDK.
  jbrArchive = fetchurl {
    url = "https://cache-redirector.jetbrains.com/intellij-jbr/jbr_jcef-25.0.4.1-osx-${jcefArch}-b635.79.tar.gz";
    hash = "sha256-EAwIIpmr6yOYfaKlOxdWSvuFi2Qux/l9DUKreBhu5nA=";
  };

  # The build compiles against the JetBrains Runtime (the UI code subclasses
  # sun.swing.text.GlyphViewAccessor, which only the JBR has), so it needs the
  # macOS JBR SDK rather than the Linux-only nixpkgs JetBrains JDK. `bin` keeps
  # `ant` (jps-bootstrap repository) working.
  buildJdk = stdenvNoCC.mkDerivation {
    pname = "intellij-build-jbrsdk";
    version = "25.0.2-b410.29";
    src = fetchurl {
      url = "https://cache-redirector.jetbrains.com/intellij-jbr/jbrsdk-25.0.2-osx-${jcefArch}-b410.29.tar.gz";
      hash = "sha256-nznsyBBqF3/C62r31C8GFZERIRhLFAi+ZhMKyI6NcbM=";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      tar -xzf $src --strip-components=1 -C $out
      ln -s $out/Contents/Home/bin $out/bin
      runHook postInstall
    '';
  };

  # The pinned nixpkgs' source builder only grew the toolchain/patch parameters
  # used below in NixOS/nixpkgs#592379, which is not merged yet; apply that
  # delta here and drop it once the flake's nixpkgs pin has it.
  jetbrainsSource = applyPatches {
    name = "jetbrains-builders";
    src = "${path}/pkgs/applications/editors/jetbrains";
    patches = [ ./patches/source-build-params.patch ];
  };

  mkJetBrainsSource = callPackage "${jetbrainsSource}/source/build.nix" { };

  src = mkJetBrainsSource (
    lib.importJSON ./source_args.json
    // {
      kotlinHome = kotlinDist;
      mvnDeps = ./idea_maven_artefacts.json;
      noDownloadPatch = ./patches/no-download-2026.3.patch;
      sbomPatch = ./patches/disable-sbom-generation-2026.3.patch;
      jacksonPatch = ./patches/bump-jackson-core-in-source-2026.3.patch;
      extraPatches = [
        ./patches/jps-compilation-2026.3.patch
        # 2026.3 dropped project-jdk-name from .idea/misc.xml, but build-scripts
        # still register the project SDK as jbr-25.
        ./patches/misc-project-jdk.patch
        # The JPS build does not load the 'expects' compiler plugin, so
        # linkToActual() calls stay unlinked and fail when the build tools
        # evaluate them.
        ./patches/multiplatform-java-version.patch
        # JPS hands Java sources to the Kotlin compiler; the Kotlin 2.4 java
        # source analysis then cannot see a file's second top-level type, so
        # move the package-private helper types Kotlin uses into own files.
        ./patches/split-inlay-interfaces.patch
        ./patches/split-java-helper-types.patch
        # The JPS build does not run the 'expects' compiler plugin, so bind the
        # linkToActual() shims to their JVM implementations instead.
        ./patches/fleet-shims-jvm-2026.3.patch
        # Likewise the rpc compiler plugin is not loaded, so the generated
        # RemoteApiDescriptor classes do not exist; stub them out.
        ./patches/fleet-rpc-descriptor-2026.3.patch
        # The restarter, libwebp and libghostty-vt archives are normally
        # downloaded while building the distribution; use store copies instead.
        ./patches/stage-native-binaries-2026.3.patch
      ]
      ++ lib.optionals isDarwin [
        # The xplat launcher and the bundled JBR are downloaded while packaging.
        ./patches/mac-launcher-2026.3.patch
        ./patches/bundled-runtime-2026.3.patch
      ];
      jpsBootstrapPatches = [ ./patches/jps-bootstrap-2026.3.patch ];
      jpsBootstrapJavaFlags = [
        "--add-exports=java.base/sun.nio.ch=ALL-UNNAMED"
        "--add-exports=java.base/jdk.internal.ref=ALL-UNNAMED"
        "--add-opens=java.base/jdk.internal.ref=ALL-UNNAMED"
        "--add-opens=java.base/java.util=ALL-UNNAMED"
        "--add-opens=java.base/java.lang=ALL-UNNAMED"
        "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED"
      ];
      # Upstream compiles with -Werror; the Kotlin build used here still emits
      # warnings on a few upstream call sites, so do not fail on them.
      extraPostPatch = ''
        find . -name '*.iml' -exec sed -i 's/ -Werror//g' {} +

        # IntelliJ's test modules use internal Kotlin APIs from unrelated
        # modules, which this JPS setup does not expose; build production only.
        sed -i '/setTypeId("java-test")/d' \
          platform/build-scripts/src/org/jetbrains/intellij/build/impl/JpsCompilationRunner.kt

        # build.nix's compose substitution is anchored to end of line, but the
        # macro sits inside <arg>...</arg>; replace it wherever it appears.
        find . -name '*.iml' -exec sed -i 's|\$KOTLIN_COMPOSE_COMPILER_PLUGIN\$|'"${composeCompilerPlugin}"'|g' {} +

        # kotlin-dist-for-ide emits type annotations that make javac resolve
        # library APIs through the module classpath, so export the library
        # modules that upstream JPS only makes visible to direct dependents.
        find . -name '*.iml' -exec sed -i -E 's|(<orderEntry type="module" module-name="intellij\.libraries\.[^"]*") />|\1 exported="" />|g' {} +
        substituteInPlace platform/external-system-impl/intellij.platform.externalSystem.impl.iml \
          --replace-fail '<orderEntry type="module" module-name="intellij.platform.ide.core" />' \
          '<orderEntry type="module" module-name="intellij.platform.ide.core" exported="" />'
        substituteInPlace java/compiler/impl/intellij.java.compiler.impl.iml \
          --replace-fail '<orderEntry type="module" module-name="intellij.platform.buildView" />' \
          '<orderEntry type="module" module-name="intellij.platform.buildView" exported="" />'
        substituteInPlace fleet/multiplatform.shims/fleet.multiplatform.shims.iml \
          --replace-fail '<orderEntry type="module" module-name="fleet.util.multiplatform" scope="PROVIDED" />' \
          '<orderEntry type="module" module-name="fleet.util.multiplatform" />'

        # Point the build-script downloaders at the prefetched native archives.
        substituteInPlace platform/build-scripts/src/org/jetbrains/intellij/build/NativeBinaryDownloader.kt \
          --replace-fail '"RESTARTER_ARCHIVE_HERE"' '"${restarterArchive}"' \
          --replace-fail '"LIBWEBP_ARCHIVE_HERE"' '"${libwebpArchive}"'
        substituteInPlace platform/build-scripts/downloader/src/org/jetbrains/intellij/build/dependencies/TerminalLibGhosttyVtDownloader.kt \
          --replace-fail '"LIBGHOSTTY_VT_ARCHIVE_HERE"' '"${libGhosttyVtArchive}"'
      '';
      copyM2Repo = true;
      composeCompilerPlugin = composeCompilerPlugin;
      jcefArchive = jcefArchive;
    }
    // lib.optionalAttrs isDarwin {
      # The Linux-only nixpkgs JetBrains JDK is replaced by the JDK above for the
      # build and by the macOS JBR above for the bundled runtime.
      jbr = buildJdk;
      jbrHome = "${buildJdk}";
      jbrJava = "${buildJdk}/Contents/Home/bin/java";
      bundledRuntime = jbrArchive;
      targetOs = "mac";
      targetArch = jcefArch;
      # .dmg/.sit need macOS signing and hdiutil; the .zip is the distribution.
      buildStepsToSkip = "mac_dmg,mac_sit,windows_exe_installer,windows_sign,repair_utility_bundle_step,sources_archive";
      # The nix build cannot build the Linux helpers for a macOS distribution.
      stageLinuxNativeBinaries = false;
      # macOS ignores $HOME for user.home and hands the JVMs a user.home they
      # cannot write; the copied Maven repository lives next to the source tree.
      jvmUserHome = "$NIX_BUILD_TOP";
    }
    // lib.optionalAttrs (!isDarwin) {
      jbr = jetbrains.jdk-no-jcef;
    }
  );
in
jetbrains.mkJetBrainsProduct (
  {
    inherit src;
    inherit (src)
      version
      buildNumber
      ;
    # this is jetbrains-libdbm but using the sources from the IDE build.
    jetbrains-libdbm = if isDarwin then null else src.libdbm;
    # The JDK is bundled on Darwin; the Linux builder needs its fsnotifier and libdbm.
    fsnotifier = if isDarwin then null else fsnotifier;

    pname = "intellij-idea-oss";
    wmClass = "jetbrains-idea";
    product = "IntelliJ IDEA Open Source";
    productShort = "IDEA";

    meta = {
      homepage = "https://www.jetbrains.com/idea/";
      changelog = "https://www.jetbrains.com/idea/whatsnew/";
      description = "Free Java, Kotlin, Groovy and Scala IDE from JetBrains (built from source)";
      longDescription = ''
        IDE for Java SE, Groovy & Scala development Powerful environment for building Google Android apps Integration with JUnit, TestNG, popular SCMs, Ant & Maven.
        Also known as IntelliJ.
      '';
      maintainers = with lib.maintainers; [
        gytis-ivaskevicius
        tymscar
      ];
      teams = [ lib.teams.jetbrains ];
      license = lib.licenses.asl20;
      sourceProvenance = [ lib.sourceTypes.fromSource ];
    };
  }
  // lib.optionalAttrs isDarwin {
    # The macOS base builder expects the unpacked distribution (a single
    # `*.app` bundle) at the top of the build directory.
    unpackPhase = ''
      runHook preUnpack
      cp -Tr ${src} .
      runHook postUnpack
    '';
  }
  // lib.optionalAttrs (!isDarwin) {
    jdk = if lib.meta.availableOn stdenv.hostPlatform jetbrains.jdk then jetbrains.jdk else null;
    extraLdPath = [ zlib ];
    extraWrapperArgs = [
      ''--set M2_HOME "${maven}/maven"''
      ''--set M2 "${maven}/maven/bin"''
    ];
  }
)
