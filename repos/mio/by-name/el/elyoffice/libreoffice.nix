# The LibreOffice LOK kernel ElyDoc, ElyTable and ElyShow load, built from the
# pinned LibreOffice/core commit with the patch series under
# ${elyofficeSrc}/patches/libreoffice.
#
# Upstream's scripts/build-libreoffice.sh builds this on macOS with Homebrew
# tools, letting LibreOffice download its bundled dependencies while it builds.
# The Nix sandbox has neither Homebrew nor network, so this expression mirrors
# the script's Darwin branch: the external tarballs listed in
# packaging/lo-tarballs.tsv are prefetched, the dictionaries submodule is
# pinned, and the release-build configure options are passed verbatim.
{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  bison,
  flex,
  gperf,
  pkg-config,
  pkgconf,
  python3,
  perl,
  zip,
  unzip,
  which,
  gnused,
  gnumake,
  gettext,
  m4,
  libtool,
  git,
  file,
  gawk,
  nasm,
  cmake,
  meson,
  ninja,
  curl,
  cacert,
  coreutils,
  elyofficeSrc,
}:

let
  pin = "8221e31b3ac356a1623c672912a3d2b492f7e3d1";
  dictionariesPin = "9925407d67e752a75cff6a1b2d7b713b7ef0380c";

  # Xcode's tools talk to system services the default sandbox denies; see
  # shared/xcode-sandbox.nix. Homebrew is kept out of reach.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;

  # LibreOffice downloads these into external/tarballs while it builds. The
  # pinned list is generated from a configured tree by scripts/lo-tarballs.sh.
  tarballs = stdenv.mkDerivation {
    pname = "elyoffice-libreoffice-tarballs";
    version = "26.2.6.3";

    nativeBuildInputs = [
      curl
      cacert
      coreutils
    ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    outputHashMode = "recursive";
    outputHash = "sha256-+jHQ4SqEAopaaGYWFrV2li/dSJ/CcPsEPy4ImwfWaM4=";

    buildCommand = ''
      mkdir -p $out
      while IFS=$'\t' read -r name sha url; do
        [ -n "$name" ] || continue
        curl --fail --silent --show-error --location --retry 5 \
          --output "$out/$name" "$url"
        echo "$sha  $out/$name" | sha256sum --check --status
      done < ${elyofficeSrc}/packaging/lo-tarballs.tsv
    '';
  };

  dictionaries = fetchurl {
    name = "libreoffice-dictionaries-${dictionariesPin}.tar.gz";
    url = "https://codeload.github.com/LibreOffice/dictionaries/tar.gz/${dictionariesPin}";
    hash = "sha256-VYf5f78ZGqYzpL9sriG8jOn/kta66ai2FF+4Ven+2FU=";
  };
in
stdenv.mkDerivation {
  pname = "elyoffice-libreoffice";
  version = "26.2.6.3";

  src = fetchurl {
    name = "libreoffice-core-${pin}.tar.gz";
    url = "https://codeload.github.com/LibreOffice/core/tar.gz/${pin}";
    hash = "sha256-eET8S9IUFHqyGQEvV/JFijjVRNyMChVK+VaILXJK+JA=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    gperf
    pkg-config
    pkgconf
    python3
    perl
    zip
    unzip
    which
    gnused
    gnumake
    gettext
    m4
    libtool
    git
    file
    gawk
    nasm
    cmake
    meson
    ninja
    coreutils
  ];

  sandboxProfile = xcodeSandbox.base;

  # kernel.sh signs every framework and hashes the result; fixup would rewrite
  # both.
  dontFixup = true;

  postPatch = ''
    # The GitHub tarball has no .git, so Makefile.in reads the version from
    # sources.ver instead of asking git.
    echo 'lo_sources_ver=26.2.6.3' > sources.ver

    # With no .git, make's get-submodules target would download these source
    # tarballs; the pinned trees are already in place, so mark them as present.
    mkdir -p src/libreoffice-dictionaries-26.2.6.3 \
      src/libreoffice-help-26.2.6.3 \
      src/libreoffice-translations-26.2.6.3

    mkdir -p dictionaries
    tar -xzf ${dictionaries} --strip-components=1 -C dictionaries

    for patch in ${elyofficeSrc}/patches/libreoffice/*.patch; do
      echo "applying $(basename "$patch")"
      git apply --whitespace=nowarn "$patch"
    done

    # The sandbox has no network; make fetch finds them where it expects.
    mkdir -p external/tarballs
    cp -a ${tarballs}/. external/tarballs/
    # The store copy is read-only; make fetch writes tmp/ and fetch.log here.
    chmod -R u+w external/tarballs
  '';

  configurePhase = ''
    runHook preConfigure

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    # Build tools come from Nix (GNU make 4.4, newer bison/flex); the compiler
    # is Xcode's clang, as in upstream's Darwin build. System tools such as
    # xcrun, codesign and ditto live in /usr/bin.
    export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
    export CC="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
    export CXX="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
    export HOME=$TMPDIR
    # Upstream's Darwin build hides pkg-config so LibreOffice uses its bundled
    # libraries instead of whatever happens to be installed.
    export PKG_CONFIG_LIBDIR=/var/empty
    export PKG_CONFIG_PATH=
    unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX \
      CC CXX OBJC OBJCXX LD

    ./autogen.sh \
      --enable-bogus-pkg-config \
      --enable-mergelibs \
      --enable-release-build \
      --without-java \
      --without-junit \
      --without-help \
      --disable-odk \
      --disable-online-update \
      --disable-extension-integration \
      --disable-scripting-beanshell \
      --disable-scripting-javascript \
      --disable-firebird-sdbc \
      --disable-postgresql-sdbc \
      --disable-ext-nlpsolver \
      --disable-ext-wiki-publisher \
      --disable-report-builder \
      --disable-sdremote \
      --disable-sdremote-bluetooth \
      --disable-poppler \
      --disable-lotuswordpro \
      --disable-gpgmepp \
      --disable-cups \
      --disable-evolution2 \
      --with-galleries=no \
      --with-lang= \
      --with-theme=colibre \
      --with-fonts \
      --disable-python \
      --disable-coinmp \
      --disable-lpsolve \
      --without-doxygen \
      --with-myspell-dicts \
      --with-external-tar="$PWD/external/tarballs"

    runHook postConfigure
  '';

  buildPhase = ''
        runHook preBuild
        export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
        make -j"''${NIX_BUILD_CORES:-4}"

        # Upstream prunes everything but the English dictionary and the Lightproof
        # bits before hashing the kernel; a bare make would bring them back.
        ${elyofficeSrc}/scripts/lo-extras.sh \
          "$PWD/instdir/LibreOffice.app/Contents" \
          | while IFS= read -r extra; do rm -rf "$extra"; done

        # Drop Lightproof from the English dictionary manifest too.
        python3 - "$PWD/instdir/LibreOffice.app/Contents/Resources/extensions/dict-en/META-INF/manifest.xml" <<'PY'
    import re, sys
    path = sys.argv[1]
    text = open(path, encoding="utf-8").read()
    gone = r'\s*<manifest:file-entry[^>]*?"(?:Lightproof\.components|Linguistic\.xcu|dialog/[^"]*)"[^>]*/>'
    kept = re.sub(gone, "", text, flags=re.S)
    for left in ("Lightproof", "Linguistic.xcu", "dialog/"):
        if left in kept:
            sys.exit(f"build-libreoffice.sh: {left} is still in {path}")
    open(path, "w", encoding="utf-8").write(kept)
    PY

        mkdir -p "$PWD/instdir/LibreOffice.app/Contents/Resources/registry"
        cp ${elyofficeSrc}/packaging/libreoffice/ely.xcd \
          "$PWD/instdir/LibreOffice.app/Contents/Resources/registry/"

        ${elyofficeSrc}/scripts/inert-lo.sh \
          "$PWD/instdir/LibreOffice.app"

        runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    ELY_LO_APP="$PWD/instdir/LibreOffice.app" \
      ${elyofficeSrc}/packaging/macos/kernel.sh "$out/lib/elyoffice/libreoffice"

    runHook postInstall
  '';

  meta = {
    description = "LibreOffice 26.2.6.3 LOK kernel built from source with Ely's patches";
    homepage = "https://github.com/ELY-Open-Source/ElyOffice";
    license = lib.licenses.mpl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
