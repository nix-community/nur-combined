{
  lib,
  stdenv,
  fetchFromGitHub,
  maven,
  swt,
  jdk,
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
}:

maven.buildMavenPackage rec {
  pname = "tuxguitar";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "helge17";
    repo = "tuxguitar";
    rev = version;
    hash = "sha256-Kk6TQ2t4exVeRyxrCqpdddJE7BfZRlW+B/lUJ+SPPd8=";
  };

  patches = [
    ./fix-lv2-include.patch
  ];

  mvnHash = "sha256-hoTXp5bRdQ5sAjVuqDE3B/7hPUODeZJ/x9lWSHPZ6ZE=";

  # Use different build scripts based on platform
  mvnParameters =
    if stdenv.hostPlatform.isDarwin then
      "-e -f desktop/build-scripts/tuxguitar-macosx-cocoa-64/pom.xml -P native-modules"
    else
      "-e -f desktop/build-scripts/tuxguitar-linux-swt/pom.xml -P native-modules";

  mvnFetchExtraArgs = {
    buildInputs =
      lib.optionals stdenv.hostPlatform.isLinux [
        alsa-lib.dev
        jack2.dev
        libpulseaudio.dev
        suil
        qt5.qtbase.dev
      ]
      ++ [
        fluidsynth.dev
        lilv.dev
        pkg-config
      ];
    dontWrapQtApps = true;
    preBuild =
      let
        swtArtifactId =
          if stdenv.hostPlatform.isDarwin then
            "org.eclipse.swt.cocoa.macosx.x86_64"
          else
            "org.eclipse.swt.gtk.linux";
      in
      ''
        mvn install:install-file \
          -Dfile=${swt}/jars/swt.jar \
          -DgroupId=org.eclipse.swt \
          -DartifactId=${swtArtifactId} \
          -Dpackaging=jar \
          -Dversion=4.36 \
          -Dmaven.repo.local=$out/.m2
      '';
  };

  nativeBuildInputs = [
    makeWrapper
    jdk
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
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
  ];

  dontWrapQtApps = true;

  dontWrapGApps = stdenv.hostPlatform.isLinux;

  afterDepsSetup =
    let
      swtArtifactId =
        if stdenv.hostPlatform.isDarwin then
          "org.eclipse.swt.cocoa.macosx.x86_64"
        else
          "org.eclipse.swt.gtk.linux";
    in
    ''
      mvn install:install-file \
        -Dfile=${swt}/jars/swt.jar \
        -DgroupId=org.eclipse.swt \
        -DartifactId=${swtArtifactId} \
        -Dpackaging=jar \
        -Dversion=4.36 \
        -Dmaven.repo.local=$mvnDeps/.m2
    '';

  installPhase =
    let
      buildDir =
        if stdenv.hostPlatform.isDarwin then
          "desktop/build-scripts/tuxguitar-macosx-cocoa-64/target"
        else
          "desktop/build-scripts/tuxguitar-linux-swt/target";
    in
    ''
      runHook preInstall

      # Find the built tuxguitar directory (it's in the subdirectory where we ran maven)
      cd ${buildDir}
      TUXGUITAR_DIR=$(ls -d tuxguitar-* | head -n 1)
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # macOS: Install as .app bundle
      mkdir -p $out/Applications
      cp -r $TUXGUITAR_DIR/tuxguitar.app $out/Applications/TuxGuitar.app

      # Create command-line wrapper
      mkdir -p $out/bin
      makeWrapper $out/Applications/TuxGuitar.app/Contents/MacOS/tuxguitar $out/bin/tuxguitar \
        --prefix PATH : ${
          lib.makeBinPath [
            jdk
            which
          ]
        }
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      # Linux: Install traditional layout
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
            jdk
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
