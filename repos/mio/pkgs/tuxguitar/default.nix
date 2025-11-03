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

  # Maven needs to be run from the subdirectory but with access to parent POMs
  mvnParameters = "-e -f desktop/build-scripts/tuxguitar-linux-swt/pom.xml -P native-modules";

  # Install SWT into Maven repository during dependency fetching
  # Need to specify the local repository path so the dependency fetch can find it
  # Also need to provide build inputs for compiling JNI modules
  mvnFetchExtraArgs = {
    buildInputs = [
      alsa-lib.dev
      jack2.dev
      fluidsynth.dev
      lilv.dev
      suil
      pkg-config
      qt5.qtbase.dev
    ];
    dontWrapQtApps = true;
    preBuild = ''
      mvn install:install-file \
        -Dfile=${swt}/jars/swt.jar \
        -DgroupId=org.eclipse.swt \
        -DartifactId=org.eclipse.swt.gtk.linux \
        -Dpackaging=jar \
        -Dversion=4.36 \
        -Dmaven.repo.local=$out/.m2
    '';
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    jdk
    pkg-config
  ];

  buildInputs = [
    swt
    alsa-lib
    jack2
    fluidsynth
    libpulseaudio
    lilv
    suil
    qt5.qtbase
  ];

  dontWrapQtApps = true;

  dontWrapGApps = true;

  # Install SWT to local maven repository after deps are setup but before building
  afterDepsSetup = ''
    mvn install:install-file \
      -Dfile=${swt}/jars/swt.jar \
      -DgroupId=org.eclipse.swt \
      -DartifactId=org.eclipse.swt.gtk.linux \
      -Dpackaging=jar \
      -Dversion=4.36 \
      -Dmaven.repo.local=$mvnDeps/.m2
  '';

  installPhase = ''
    runHook preInstall

    # Find the built tuxguitar directory (it's in the subdirectory where we ran maven)
    cd desktop/build-scripts/tuxguitar-linux-swt/target
    TUXGUITAR_DIR=$(ls -d tuxguitar-* | head -n 1)

    mkdir -p $out/bin
    cp -r $TUXGUITAR_DIR/dist $out/
    cp -r $TUXGUITAR_DIR/lib $out/
    cp -r $TUXGUITAR_DIR/share $out/
    cp $TUXGUITAR_DIR/tuxguitar.sh $out/bin/tuxguitar

    ln -s $out/dist $out/bin/dist
    ln -s $out/lib $out/bin/lib
    ln -s $out/share $out/bin/share

    runHook postInstall
  '';

  postFixup = ''
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
    platforms = lib.platforms.linux;
    mainProgram = "tuxguitar";
  };
}
