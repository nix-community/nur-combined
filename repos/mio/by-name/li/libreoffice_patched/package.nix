{
  lib,
  stdenv,
  libreoffice,
  autoconf,
  automake,
  bash,
  bison,
  cmake,
  coreutils,
  curl,
  file,
  flex,
  fontforge,
  gawk,
  gettext,
  git,
  gnused,
  gperf,
  fetchurl,
  libtool,
  m4,
  meson,
  nasm,
  nix,
  ninja,
  nixfmt,
  perl,
  perlPackages,
  pkg-config,
  pkgconf,
  python3,
  python3Packages,
  unzip,
  which,
  writeShellApplication,
  zip,
}:

let
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;
  openSymbol = fetchurl {
    url = "https://dev-www.libreoffice.org/extern/f543e6e2d7275557a839a164941c0a86e5f2c3f2a0042bfc434c88c6dde9e140-opens___.ttf";
    hash = "sha256-9UPm4tcnVVeoOaFklBwKhuXyw/KgBCv8Q0yIxt3p4UA=";
  };
  dictionaries = fetchurl {
    url = "https://download.documentfoundation.org/libreoffice/src/26.8.3/libreoffice-dictionaries-26.8.3.1.tar.xz";
    hash = "sha256-YmUqn/IdwE92BCxyA01pINubBU1WtPpyFR0DHaqpIWQ=";
  };
in
# nixpkgs ships the desktop LibreOffice as a prebuilt Darwin app and only
# supports its source expression on Linux.  Keep nixpkgs' source, help,
# translations, and complete set of pinned external tarballs, then use the
# supported macOS source-build flow and install the app it produces.
libreoffice.unwrapped.overrideAttrs (old: {
  pname = "libreoffice_patched";

  nativeBuildInputs = [
    autoconf
    automake
    bash
    bison
    cmake
    coreutils
    file
    flex
    fontforge
    gawk
    gettext
    git
    gnused
    gperf
    libtool
    m4
    meson
    nasm
    ninja
    perl
    perlPackages.ArchiveZip
    perlPackages.IOCompress
    pkg-config
    pkgconf
    python3
    python3Packages.afdko
    unzip
    which
    zip
  ];

  # An upstream macOS build consumes LibreOffice's bundled third-party tree.
  # The Linux system-library graph is both unnecessary and unsupported on
  # Darwin.
  buildInputs = [ ];
  patches = [ ];
  postUnpack = (old.postUnpack or "") + ''
    ln -sfv ${openSymbol} \
      "$sourceRoot/external/tarballs/f543e6e2d7275557a839a164941c0a86e5f2c3f2a0042bfc434c88c6dde9e140-opens___.ttf"

    mkdir -p "$sourceRoot/dictionaries"
    tar -xf ${dictionaries} --strip-components=2 -C "$sourceRoot/dictionaries"
  '';
  postPatch = "";
  env = { };
  dontUseCmakeConfigure = true;
  dontUseMesonConfigure = true;
  dontUseNinjaBuild = true;

  sandboxProfile = xcodeSandbox.withMetalToolchain;

  preConfigure = ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
    export HOME=$TMPDIR

    # LibreOffice uses Xcode's compiler and SDK on macOS.  Nix also provides
    # the build tools, but its compiler flags and SDK must not leak into the
    # upstream build.
    unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX \
      CC CXX OBJC OBJCXX LD

    # Use the bundled libraries pinned by nixpkgs rather than host libraries.
    export PKG_CONFIG_LIBDIR=/var/empty
    export PKG_CONFIG_PATH=

    NOCONFIGURE=1 ./autogen.sh
  '';

  configureFlags = [
    "--with-gnu-cp=${coreutils}/bin/cp"
    "--with-lang=en-US"
    "--with-help=html"
    "--with-myspell-dicts"
    "--with-theme=colibre"
    "--with-fonts"
    "--enable-bogus-pkg-config"
    "--enable-headless"
    "--enable-release-build"
    "--enable-mergelibs=more"
    "--disable-fetch-external"
    "--without-system-fontconfig"
    "--without-system-freetype"
    "--without-java"
    "--without-junit"
    "--disable-coinmp"
    "--disable-firebird-sdbc"
    "--disable-odk"
    "--disable-online-update"
    "--without-package-format"
  ];

  enableParallelBuilding = true;
  doCheck = false;

  # LibreOffice's nested make logs are large enough to break the sandbox's
  # stdout pipe after a successful build. Capture them locally and surface the
  # useful tail only on failure.
  buildPhase = ''
    runHook preBuild

    log_file="$TMPDIR/libreoffice-build.log"
    if ! make -j"''${NIX_BUILD_CORES:-1}" \
      SHELL=${bash}/bin/bash \
      build > "$log_file" 2>&1; then
      tail -n 500 "$log_file" >&2
      exit 1
    fi
    tail -n 20 "$log_file"

    runHook postBuild
  '';

  # The app bundle contains nested signed executables and frameworks.  Nix's
  # Darwin fixup would invalidate the bundle while rewriting them.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    app=$(find instdir -maxdepth 2 -type d \
      \( -name 'LibreOffice.app' -o -name 'LibreOfficeDev.app' \) \
      -print -quit)
    if [ -z "$app" ]; then
      echo "libreoffice_patched: source build did not produce an app bundle" >&2
      find instdir -maxdepth 2 -print >&2
      exit 1
    fi

    mkdir -p "$out/Applications" "$out/bin"
    cp -a "$app" "$out/Applications/LibreOffice.app"
    chmod -R u+w "$out/Applications/LibreOffice.app"
    /usr/bin/codesign --force --deep --timestamp=none --sign - \
      "$out/Applications/LibreOffice.app"

    # LaunchServices rejects app bundles executed directly from the Nix store,
    # while the bundle executable itself runs normally.
    cat > "$out/bin/soffice" <<EOF
    #!${bash}/bin/bash
    exec "$out/Applications/LibreOffice.app/Contents/MacOS/soffice" "\$@"
    EOF
    chmod +x "$out/bin/soffice"
    ln -s soffice "$out/bin/libreoffice"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/Applications/LibreOffice.app/Contents/MacOS/soffice" \
      --headless --version >/dev/null
    runHook postInstallCheck
  '';

  requiredSystemFeatures = [ ];
  disallowedRequisites = [ ];

  passthru = (old.passthru or { }) // {
    updateScript = writeShellApplication {
      name = "update-libreoffice_patched";
      runtimeInputs = [
        curl
        gawk
        git
        nix
        nixfmt
        python3
      ];
      text = ''
        exec ${bash}/bin/bash ${./update.sh} "$@"
      '';
    };
    withJava = false;
    jdk = null;
    kdeIntegration = false;
  };

  meta = (old.meta or { }) // {
    description = "LibreOffice ${old.version} built from source on Darwin";
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "soffice";
  };
})
