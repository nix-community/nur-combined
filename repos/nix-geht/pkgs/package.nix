{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  jdk,
  jre,
  unzip,
  copyDesktopItems,
  makeDesktopItem,
  libtool,
  p11-kit,
  pcsclite,
  runtimeShell,
}:

let
  # Native half of the bundled opensc-java.jar (the PKCS11Provider script
  # API). Upstream only ships prebuilt x86 binaries, but they are built from
  # this tree (its prebuilt libraries are byte-identical to the shipped
  # ones), so build it from source for every platform instead.
  opensc-java = fetchFromGitHub {
    owner = "CardContact";
    repo = "opensc-java";
    rev = "5d84d1c3aeb15260c0bdb45e789bf1c50b26fb47";
    hash = "sha256-rYfqCPK2KsR4zV1bDDfkCYCtAuiDhaKF6UFspyOHzHY=";
  };

  # PKCS11Provider does System.loadLibrary("opensc-PKCS11-" + os.arch), so
  # the JNI library name must carry the JVM's spelling of the architecture.
  # That is the CPU name, except for the legacy spellings below. Derived from
  # hostPlatform because asking the build-time java would yield the build
  # platform's arch under cross compilation.
  jvmArch =
    {
      x86_64-linux = "amd64";
      i686-linux = "i386";
      armv6l-linux = "arm";
      armv7l-linux = "arm";
      powerpc64le-linux = "ppc64le";
    }
    .${stdenv.hostPlatform.system} or stdenv.hostPlatform.parsed.cpu.name;

  pcscLibrary =
    if stdenv.hostPlatform.isDarwin then
      "/System/Library/Frameworks/PCSC.framework/PCSC"
    else
      "${lib.getLib pcsclite}/lib/libpcsclite.so.1";

  # The JNI bridge resolves module names without a directory component via
  # libltdl, which searches LTDL_LIBRARY_PATH. Point it at p11-kit so
  # new PKCS11Provider("p11-kit-proxy.so") (".dylib" on Darwin) reaches every
  # PKCS#11 module registered with p11-kit (/etc/pkcs11/modules,
  # ~/.config/pkcs11/modules).
  pkcs11Setup = ''
    export LTDL_LIBRARY_PATH="''${LTDL_LIBRARY_PATH:+$LTDL_LIBRARY_PATH:}${lib.getLib p11-kit}/lib"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "scsh3";
  version = "3.18.77";

  src = fetchurl {
    url = "https://www.openscdp.org/download/scsh3/scsh-${finalAttrs.version}.zip";
    hash = "sha256-HloGW3iIpmCgiJVtEQzlU56Ft2zzw/AutX5NMQS88oA=";
  };

  sourceRoot = "scsh-${finalAttrs.version}";

  nativeBuildInputs = [
    jdk
    unzip
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
  ];

  # libltdl, used by the PKCS#11 JNI library to load PKCS#11 modules
  buildInputs = [ (lib.getLib libtool) ];

  strictDeps = true;

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    # Build the custom loader.
    cp ${./DefaultConfigurationLoader.java} DefaultConfigurationLoader.java
    javac --release 17 -classpath lib/ocf-core.jar -d classes \
      DefaultConfigurationLoader.java

    # Build the PKCS#11 JNI library.
    $CC -O2 -fPIC -shared \
      -I ${opensc-java}/jni/src/jniP11 \
      -I ${opensc-java}/jni/src/jnix \
      -I ${lib.getDev libtool}/include \
      -I ${jdk}/include \
      -I ${jdk}/include/${if stdenv.hostPlatform.isDarwin then "darwin" else "linux"} \
      ${opensc-java}/jni/src/jniP11/*.c \
      ${opensc-java}/jni/src/jnix/jnix.c \
      -lltdl \
      -o libopensc-PKCS11-${jvmArch}${stdenv.hostPlatform.extensions.sharedLibrary}

    runHook postBuild
  '';

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "scsh3gui";
      exec = "scsh3gui";
      icon = "scsh3";
      desktopName = "Smart Card Shell 3";
      genericName = "Smart Card Shell";
      comment = "Scripting environment for smart card development";
      categories = [ "Development" ];
      keywords = [
        "smartcard"
        "smart card"
        "PKCS11"
        "HSM"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/scsh3/lib $out/bin
    cp -r config.js opencard.properties doc icons keymanager scsh tools $out/share/scsh3/
    cp -r classes/org $out/share/scsh3/
    cp lib/*.jar $out/share/scsh3/lib/
    cp libopensc-PKCS11-* $out/share/scsh3/lib/

    makeJavaWrapper() {
      substitute ${./wrapper.sh} "$out/bin/$1" \
        --subst-var out \
        --subst-var-by runtimeShell ${runtimeShell} \
        --subst-var-by java ${lib.getExe' jre "java"} \
        --subst-var-by pcscLibrary ${lib.escapeShellArg pcscLibrary} \
        --subst-var-by pkcs11Setup ${lib.escapeShellArg pkcs11Setup} \
        --subst-var-by mainClass "$2" \
        --subst-var-by extraSetup "$3"
      chmod +x "$out/bin/$1"
    }

    makeJavaWrapper scsh3    de.cardcontact.scdp.engine.CommandProcessor ""
    makeJavaWrapper scsh3gui de.cardcontact.scdp.scsh3.GUIShell ""
    # Unlike the other entry points, ScriptRunner ignores scsh3.exepath and
    # expects to run from the installation directory, resolving the script
    # arguments against scdp.workspace (like the upstream launcher does).
    makeJavaWrapper scsh3-scriptrunner de.cardcontact.scdp.engine.ScriptRunner \
      "set -- \"-Dscdp.workspace=\$PWD\" \"\$@\"
    cd $out/share/scsh3"

    install -Dm644 icons/CardContactLauncher.png \
      $out/share/icons/hicolor/256x256/apps/scsh3.png

    runHook postInstall
  '';

  meta = {
    description = "Interactive JavaScript environment for smart card development";
    longDescription = ''
      The Smart Card Shell 3 from the OpenSCDP project is a Rhino-based
      JavaScript command shell, GUI and script runner for developing,
      testing and personalizing smart cards, with support for ISO 7816,
      GlobalPlatform, PKCS#11 and the SmartCard-HSM.

      Card readers are accessed via PC/SC. Scripts load PKCS#11 modules by
      path; modules registered with p11-kit are additionally reachable by
      name through its proxy module, e.g.
      new PKCS11Provider("p11-kit-proxy.so") ("p11-kit-proxy.dylib" on
      Darwin).

      The OpenCard Framework
      configuration can be customized per key by placing an
      opencard.properties file in the home directory (as
      ~/.opencard.properties) or the current directory; packaged defaults
      fill in any key not defined there. A template with all defaults is
      installed as share/scsh3/opencard.properties.
    '';
    homepage = "https://www.openscdp.org/scsh3/";
    downloadPage = "https://www.openscdp.org/scsh3/download.html";
    changelog = "https://www.openscdp.org/scsh3/changes.html";
    # gpl2Only: the shell itself; lgpl21Plus: the OpenSC-Java JNI library
    license = with lib.licenses; [
      gpl2Only
      lgpl21Plus
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ vifino ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "scsh3";
  };
})
