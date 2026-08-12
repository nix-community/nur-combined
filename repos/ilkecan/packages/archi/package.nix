{
  lib,
  at-spi2-core,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  fetchFromGitHub,
  glib,
  gtk3,
  jdk21,
  libsecret,
  makeDesktopItem,
  makeWrapper,
  maven,
  nix-update-script,
  stripJavaArchivesHook,
  testers,
  unzip,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

maven.buildMavenPackage (finalAttrs: {
  pname = "archi";
  version = "5.9.0";

  src = fetchFromGitHub {
    owner = "archimatetool";
    repo = "archi";
    tag = "release_${finalAttrs.version}";
    hash = "sha256-d8fpxZhp1hVbjzVGjitc7WKiD8nijMv+1/ZlUOYzmbE=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  mvnJdk = jdk21;

  mvnParameters = lib.escapeShellArgs [
    "-Pproduct"
    "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z"
  ];

  mvnHash = "sha256-UuJgqHPrmSKETySUc21S3UVXIvg5Z2yqmmP6ewbdlwQ=";

  # The Tycho/p2 dependency resolution performed while fetching mvnDeps is not
  # reproducible out of the box:
  # - buildMavenPackage's default installPhase deletes $out/.m2/.meta but
  #   Tycho's offline resolver needs .meta/p2-artifacts.properties to know
  #   which p2 artifacts are already present in the local repo. So .meta is
  #   backed up in preInstall and restored in postInstall.
  # - .meta/p2-artifacts.properties lists resolved p2 artifacts in hash-map
  #   order, which differs from build to build. It is sorted for
  #   reproducibility.
  # - Tycho's local HTTP transport cache for p2 repositories records the HTTP
  #   response "date" header and its own local fetch timestamp on every fetch.
  #   These two volatile fields are stripped and the remaining fields are
  #   stable. The files themselves are kept rather than deleted, because Tycho
  #   only treats a URL as cached when its *.headers file is present.
  mvnFetchExtraArgs = {
    preInstall = ''
      metaBackup=$(mktemp -d)
      cp -a $out/.m2/.meta "$metaBackup/meta"
    '';

    postInstall = ''
      cp -a "$metaBackup/meta" $out/.m2/.meta

      sort -o $out/.m2/.meta/p2-artifacts.properties $out/.m2/.meta/p2-artifacts.properties

      find $out/.m2/.cache -type f -name '*.headers' \
        -exec sed -i -e '/^date=/d' -e '/^FILE-LAST_UPDATED=/d' {} +
    '';
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    stripJavaArchivesHook
    unzip
    wrapGAppsHook3
  ];

  buildInputs = [
    at-spi2-core
    cairo
    glib
    gtk3
  ];

  # These are dlopen'd rather than being DT_NEEDED entries, so autoPatchelfHook
  # cannot infer them.
  appendRunpaths = [
    "${lib.getLib libsecret}/lib" # reached through JNA by Equinox's keyring provider
    "${lib.getLib webkitgtk_4_1}/lib" # dlopen'd by libswt-webkit-gtk for the browser widget
  ];

  # Upstream's tests would need extra work to run at all and still fail in the
  # build environment.
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec

    # Upstream declares icon.xpm as the Linux launcher icon in archi.product
    # but these PNGs are the same artwork at different sizes, which suits the
    # hicolor theme better than a single size XPM.
    for icon in com.archimatetool.editor/img/app-*.png; do
      name=''${icon##*/app-}; name=''${name%.png} # 16, or 16@2x
      size=''${name%%@*}                          # 16
      scale=''${name#"$size"}                     # empty, or @2x
      install -Dm444 "$icon" \
        "$out/share/icons/hicolor/''${size}x''${size}''${scale%x}/apps/archi.png"
    done

    install -Dm444 ${./mime-info.xml} $out/share/mime/packages/archi.xml

    pushd com.archimatetool.editor.product/target/products/com.archimatetool.editor.product/linux/gtk/x86_64/Archi

    # Copy everything except what is not needed:
    # - icon.xpm, superseded by the PNGs installed above
    # - artifacts.xml, p2's index for provisioning and self-update
    cp -r . $out/libexec
    rm $out/libexec/{artifacts.xml,icon.xpm}
    chmod 755 $out/libexec/Archi

    # SWT would otherwise unpack its JNI natives at runtime, bypassing
    # autoPatchelfHook. Unpack them here and point swt.library.path at them
    # instead. The glx and awt natives are excluded because Archi uses neither.
    mkdir -p $out/lib/swt
    unzip -q -o -d $out/lib/swt plugins/org.eclipse.swt.gtk.linux.x86_64_*.jar '*.so' \
      -x '*-glx-*' '*-awt-*'
    substituteInPlace $out/libexec/Archi.ini \
      --replace-fail '-vmargs' "-vmargs
    -Dswt.library.path=$out/lib/swt"

    # Simulate the upstream release layout, where the launcher finds a JVM
    # beside itself, so the wrapper does not have to put a JDK on PATH.
    ln -s ${jdk21.home} $out/libexec/jre

    popd

    runHook postInstall
  '';

  # Wrap manually to keep the hook from also wrapping $out/libexec/Archi, which
  # breaks Eclipse's argv[0]-derived lookup of Archi.ini.
  dontWrapGApps = true;

  preFixup = ''
    makeWrapper $out/libexec/Archi $out/bin/archi "''${gappsWrapperArgs[@]}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "Archi";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %f";
      icon = "archi";
      categories = [ "Development" ];
      startupWMClass = "Archi";
      mimeTypes = [ "application/x-archimate" ];
    })
  ];

  passthru = {
    tests.archi = testers.runNixOSTest {
      imports = [ ./test.nix ];

      _module.args = {
        archi = finalAttrs.finalPackage;
      };
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "release_(.*)"
      ];
    };
  };

  meta = {
    description = "ArchiMate modelling tool";
    homepage = "https://www.archimatetool.com/";
    changelog = "https://github.com/archimatetool/archi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    # Archi itself is built from source but Tycho resolves the Eclipse platform
    # it is assembled onto from a p2 repository, which ships prebuilt bundles
    # and prebuilt SWT/Equinox JNI libraries.
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
      binaryNativeCode
    ];
    mainProgram = "archi";
    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = [ "x86_64-linux" ];
  };
})
