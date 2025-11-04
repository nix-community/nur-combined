{
  lib,
  stdenv,
  fetchFromGitHub,
  maven,
  swt,
  jdk,
  jre,
  makeWrapper,
  pkg-config,
  alsa-lib,
  jack2,
  fluidsynth,
  libpulseaudio,
  lilv,
  suil,
  qt5,
  which,
  wrapGAppsHook3,
  nixosTests,
  # Darwin frameworks - imported directly, only on Darwin
  AudioUnit ? null,
  CoreAudio ? null,
  CoreFoundation ? null,
}:

let
  pname = "tuxguitar";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "helge17";
    repo = "tuxguitar";
    rev = version;
    hash = "sha256-Kk6TQ2t4exVeRyxrCqpdddJE7BfZRlW+B/lUJ+SPPd8=";
  };

  swtArtifactId =
    if stdenv.hostPlatform.isDarwin then
      if stdenv.hostPlatform.isAarch64 then
        "org.eclipse.swt.cocoa.macosx.aarch64"
      else
        "org.eclipse.swt.cocoa.macosx.x86_64"
    else if stdenv.hostPlatform.isx86_64 then
      "org.eclipse.swt.gtk.linux.x86_64"
    else
      "org.eclipse.swt.gtk.linux.aarch64";

  buildScript =
    if stdenv.hostPlatform.isDarwin then
      "desktop/build-scripts/tuxguitar-macosx-swt-cocoa/pom.xml"
    else
      "desktop/build-scripts/tuxguitar-linux-swt/pom.xml";

  # Fetch Maven dependencies in a fixed-output derivation
  # We fetch dependencies WITHOUT the native-modules profile to keep it deterministic
  mavenDeps = stdenv.mkDerivation {
    name = "${pname}-${version}-maven-deps";
    inherit src;

    patches = [
      ./fix-lv2-include.patch
    ];

    nativeBuildInputs = [
      maven
      jdk
    ];

    buildPhase = ''
      runHook preBuild

      # Use a temporary local repository
      mkdir -p .m2/repository

      # Copy SWT jar to a fixed location to avoid path dependencies
      cp ${swt}/jars/swt.jar swt-4.36.jar

      # Install SWT jar from fixed location
      mvn install:install-file \
        -Dfile=$(pwd)/swt-4.36.jar \
        -DgroupId=org.eclipse.swt \
        -DartifactId=${swtArtifactId} \
        -Dpackaging=jar \
        -Dversion=4.36 \
        -Dmaven.repo.local=$(pwd)/.m2/repository

      # Download dependencies WITH native-modules profile to get all deps
      mvn dependency:go-offline -f ${buildScript} -P native-modules \
        -Dmaven.repo.local=$(pwd)/.m2/repository

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # Copy to output, removing timestamps and non-deterministic files
      mkdir -p $out
      cp -r .m2/repository $out/

      # Remove resolver status files that contain timestamps
      find $out/repository -name "_remote.repositories" -delete
      find $out/repository -name "*.lastUpdated" -delete
      find $out/repository -name "resolver-status.properties" -delete
      find $out/repository -type f -name "maven-metadata-*.xml" -delete

      # Reset timestamps for determinism
      find $out -exec touch -t 197001010000 {} +

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash =
      if stdenv.hostPlatform.isDarwin then
        "sha256-+KGa+D+bHN/75FBKvh6+5nTQigQh7uCxVv+3o5VoT4w="
      else
        "sha256-Pcxr3ab8kqTIs5bfcm4zGbva0evUYYiBr1vBwjWFMl4=";
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  patches = [
    ./fix-lv2-include.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    ./fix-audiounit-makefile.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    maven
    jdk
    pkg-config
    fluidsynth.dev
    lilv.dev
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
    alsa-lib.dev
    jack2.dev
    libpulseaudio.dev
    suil
    qt5.qtbase.dev
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    stdenv.cc
  ];

  buildInputs = [
    swt
    fluidsynth
    lilv
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    jack2
    libpulseaudio
    suil
    qt5.qtbase
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    AudioUnit
    CoreAudio
    CoreFoundation
  ];

  dontWrapQtApps = true;

  dontWrapGApps = stdenv.hostPlatform.isLinux;

  buildPhase = ''
    runHook preBuild

    # Build with offline mode using pre-fetched dependencies
    mvn package -e -f ${buildScript} -P native-modules \
      -o -Dmaven.test.skip=true \
      -Dmaven.repo.local=${mavenDeps}/repository

    runHook postBuild
  '';

  installPhase =
    let
      buildDir =
        if stdenv.hostPlatform.isDarwin then
          "desktop/build-scripts/tuxguitar-macosx-swt-cocoa/target"
        else
          "desktop/build-scripts/tuxguitar-linux-swt/target";
    in
    ''
      runHook preInstall

      # Find the built tuxguitar directory (it's in the subdirectory where we ran maven)
      cd ${buildDir}
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # macOS: The build creates tuxguitar-VERSION-macosx-swt-cocoa.app directly
      # This directory name already ends with .app and IS the app bundle
      mkdir -p $out/Applications
      cp -r tuxguitar-*-macosx-swt-cocoa.app $out/Applications/TuxGuitar.app

      # Fix the launch script to use the Nix JRE instead of bundled JRE
      substituteInPlace $out/Applications/TuxGuitar.app/Contents/MacOS/tuxguitar.sh \
        --replace-fail 'JAVA="./jre/bin/java"' 'JAVA="${jre}/bin/java"'

      # Ensure the main executable has execute permissions
      chmod +x $out/Applications/TuxGuitar.app/Contents/MacOS/tuxguitar.sh

      # Create command-line wrapper
      mkdir -p $out/bin
      makeWrapper $out/Applications/TuxGuitar.app/Contents/MacOS/tuxguitar.sh $out/bin/tuxguitar \
        --prefix PATH : ${
          lib.makeBinPath [
            jre
            which
          ]
        }
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      # Linux: Install traditional layout
      TUXGUITAR_DIR=$(ls -d tuxguitar-* | head -n 1)
      mkdir -p $out/bin
      cp -r $TUXGUITAR_DIR/dist $out/
      cp -r $TUXGUITAR_DIR/lib $out/
      cp -r $TUXGUITAR_DIR/share $out/
      cp $TUXGUITAR_DIR/tuxguitar.sh $out/bin/tuxguitar

      ln -s $out/dist $out/bin/dist
      ln -s $out/lib $out/bin/lib
      ln -s $out/share $out/bin/share
    ''
    + ''

      runHook postInstall
    '';

  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/tuxguitar \
        "''${gappsWrapperArgs[@]}" \
        --prefix PATH : ${
          lib.makeBinPath [
            jre
            which
          ]
        } \
        --prefix LD_LIBRARY_PATH : "$out/lib/:${
          lib.makeLibraryPath [
            swt
            alsa-lib
            jack2
            fluidsynth
            libpulseaudio
            lilv
          ]
        }" \
        --prefix CLASSPATH : "${swt}/jars/swt.jar:$out/lib/tuxguitar.jar:$out/lib/itext.jar"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # macOS: wrapper is already created in installPhase
      # Additional wrapping for DYLD_LIBRARY_PATH if needed
      wrapProgram $out/bin/tuxguitar \
        --prefix DYLD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            fluidsynth
            lilv
          ]
        }" \
        --prefix CLASSPATH : "${swt}/jars/swt.jar"
    '';

  passthru.tests = {
    nixos = nixosTests.tuxguitar;
  };

  meta = {
    description = "Multitrack guitar tablature editor";
    longDescription = ''
      TuxGuitar is a multitrack guitar tablature editor and player written
      in Java-SWT. It can open GuitarPro, PowerTab and TablEdit files.
    '';
    homepage = "https://github.com/helge17/tuxguitar";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ ardumont ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "tuxguitar";
  };
}
