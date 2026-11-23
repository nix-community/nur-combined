# Ely Office: offline desktop apps in Rust and GPUI.
#
# The seven apps and the two workers are built from the pinned upstream
# source, and ElyPDF/ElyMark's MuPDF engine (1.28.5 plus the upstream patch
# series under ./patches) is built here too.
#
# ElyDoc, ElyTable and ElyShow load a patched LibreOffice 26.2.6.3 LOK kernel
# (139 patches, --enable-mergelibs). On aarch64-darwin ./libreoffice.nix builds
# it from the pinned LibreOffice/core commit, the same tree and flags as
# upstream's scripts/build-libreoffice.sh. On x86_64-linux the matching kernel
# is unpacked from the release's combined Arch package instead. Kernels are
# installed as $out/lib/elyoffice/libreoffice and linked from
# $out/bin/libreoffice, where the apps look for them.
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  pkg-config,
  openssl,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  zstd,
  sqlite,
  _7zz,
  cpio,
  gzip,
  git,
  git-lfs,
  zlib,
  krb5,
  dbus,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
  libGL,
  fontconfig,
  freetype,
  nix-update,
  python3,
  nix,
  writeShellApplication,
  nixpkgs_pkgs,
  buildKernelFromSource ? true,
}:

let
  version = "0.1.17";

  src = fetchFromGitHub {
    owner = "ELY-Open-Source";
    repo = "ElyOffice";
    tag = "v${version}";
    hash = "sha256-JS/4QqBx+G9QRtS1K7yahoG17WrI3CzBZ1jTKF5boPw=";
  };

  # ely-pdf-worker's build script links a static libcrypto beside MuPDF's own
  # static archives.
  opensslStatic = openssl.override { static = true; };

  # MuPDF with the upstream patch series applied: the worker compiles its C
  # shim against these headers and links the archives built from this tree.
  mupdfSrc = stdenv.mkDerivation {
    pname = "elyoffice-mupdf-source";
    version = "1.28.5";

    src = fetchurl {
      url = "https://mupdf.com/downloads/archive/mupdf-1.28.5-source.tar.gz";
      hash = "sha256-mKXBDNogw5ks33b/ayoRScMr15zHltP3AyMLEYW36TQ=";
    };

    patches = lib.sort (a: b: toString a < toString b) (lib.filesystem.listFilesRecursive ./patches);

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R . $out/
      runHook postInstall
    '';
  };

  # Mirrors scripts/build-mupdf.sh: bundled third parties (including Tesseract
  # and Leptonica), system OpenSSL, no X11 or curl, and the extra PKCS#7
  # archive the worker links.
  mupdf = stdenv.mkDerivation {
    pname = "elyoffice-mupdf";
    version = "1.28.5";

    src = mupdfSrc;

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ opensslStatic ];

    enableParallelBuilding = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p $out
      make -j$NIX_BUILD_CORES \
        build=release \
        HAVE_X11=no \
        HAVE_GLUT=no \
        HAVE_CURL=no \
        HAVE_LIBCRYPTO=yes \
        tesseract=yes \
        USE_SYSTEM_TESSERACT=no \
        USE_SYSTEM_LEPTONICA=no \
        OUT=$out \
        ${lib.optionalString stdenv.hostPlatform.isLinux "LIB_CFLAGS=-fPIC"} \
        libs $out/libmupdf-pkcs7.a
      runHook postBuild
    '';

    installPhase = "true";

    meta = {
      description = "MuPDF 1.28.5 with Ely's patches, as ElyPDF and ElyMark link it";
      license = lib.licenses.agpl3Plus;
    };
  };

  # macOS builds the kernel from source (./libreoffice.nix); Linux takes the one
  # released in the combined Arch package. Either way the apps see the
  # Frameworks/Resources pair.
  kernel =
    if stdenv.hostPlatform.isDarwin && buildKernelFromSource then
      nixpkgs_pkgs.callPackage ./libreoffice.nix {
        elyofficeSrc = src;
      }
    else if stdenv.hostPlatform.isDarwin then
      stdenv.mkDerivation {
        pname = "elyoffice-kernel";
        inherit version;

        src = fetchurl {
          url = "https://github.com/ELY-Open-Source/ElyOffice/releases/download/v${version}/ElyOffice-${version}-arm64.pkg";
          hash = "sha256-wkcf365qDPMy7eOybZSFwr3C3oHFM7e5LGRDkiWDUPg=";
        };

        nativeBuildInputs = [
          _7zz
          cpio
          gzip
        ];

        dontUnpack = true;
        dontFixup = true;
        dontPatchELF = true;
        dontAutoPatchelf = true;

        installPhase = ''
          runHook preInstall

          # LibreOffice's macOS bundle layout: it reads its ini files from
          # Contents/Resources when the kernel sits in Contents/Frameworks,
          # names it derives from the directory itself. upstream bundles those
          # two trees, and nothing else, as the kernel.pkg component payload.
          mkdir -p "$TMPDIR/pkg" "$out/lib/elyoffice/libreoffice/Contents"
          7zz x -y -o"$TMPDIR/pkg" "$src" 'kernel.pkg/Payload' > /dev/null
          gzip -dc "$TMPDIR/pkg/kernel.pkg/Payload" \
            | (cd "$out/lib/elyoffice/libreoffice/Contents" && cpio -id --no-absolute-filenames)
          # 7-Zip materialises the signed files' xattrs as "name:com.apple.*".
          find "$out" -name '*:com.apple.*' -delete

          runHook postInstall
        '';

        meta = {
          description = "LibreOffice 26.2.6.3 LOK kernel from the ElyOffice release";
          license = lib.licenses.mpl20;
          platforms = [ "aarch64-darwin" ];
        };
      }
    else
      stdenv.mkDerivation {
        pname = "elyoffice-kernel";
        inherit version;

        src = fetchurl {
          url = "https://github.com/ELY-Open-Source/ElyOffice/releases/download/v${version}/ely-office-${version}-1-x86_64.pkg.tar.zst";
          hash = "sha256-i3rSqiXeswUIZSn/olpgp6jcDYcLA6qek9f6oMwYb+I=";
        };

        nativeBuildInputs = [ zstd ];

        dontUnpack = true;
        dontFixup = true;
        dontPatchELF = true;
        dontAutoPatchelf = true;

        installPhase = ''
          runHook preInstall

          mkdir unpack
          zstd -dc "$src" | tar -x -C unpack --no-same-owner
          mkdir -p $out/lib/elyoffice
          cp -a unpack/opt/ely-office/libreoffice \
            $out/lib/elyoffice/libreoffice

          runHook postInstall
        '';

        meta = {
          description = "LibreOffice 26.2.6.3 LOK kernel from the ElyOffice release";
          license = lib.licenses.mpl20;
          platforms = [ "x86_64-linux" ];
        };
      };

  # The same tessdata_fast revision and files as scripts/fetch-tessdata.sh.
  tessdata = {
    eng = fetchurl {
      url = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/87416418657359cb625c412a48b6e1d6d41c29bd/eng.traineddata";
      hash = "sha256-fUMivSp3SXJIeWg/w5EstULxmQbIO8waUhMlVkJxcLI=";
    };
    chi_sim = fetchurl {
      url = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/87416418657359cb625c412a48b6e1d6d41c29bd/chi_sim.traineddata";
      hash = "sha256-pfy28NseHW2FIvOdtOhI8FmEZpFy5YTo12trMUHh9zA=";
    };
    chi_tra = fetchurl {
      url = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/87416418657359cb625c412a48b6e1d6d41c29bd/chi_tra.traineddata";
      hash = "sha256-UpxbV5fWSxJgZc1V8rtMf9exV5B5gJGx/yWZQagpMws=";
    };
  };

  apps = {
    ely-doc = {
      name = "ElyDoc";
      comment = "Word processing (DOCX, ODT)";
      categories = [
        "Office"
        "WordProcessor"
      ];
    };
    ely-table = {
      name = "ElyTable";
      comment = "Spreadsheets (XLSX, ODS, CSV)";
      categories = [
        "Office"
        "Spreadsheet"
      ];
    };
    ely-show = {
      name = "ElyShow";
      comment = "Presentations (PPTX, ODP)";
      categories = [
        "Office"
        "Presentation"
      ];
    };
    ely-pdf = {
      name = "ElyPDF";
      comment = "PDF reading and editing, OCR, signatures";
      categories = [
        "Office"
        "Viewer"
      ];
    };
    ely-mail = {
      name = "ElyMail";
      comment = "Mail over IMAP, POP3 and SMTP";
      categories = [
        "Network"
        "Email"
      ];
    };
    ely-tree = {
      name = "ElyTree";
      comment = "Git client";
      categories = [
        "Development"
        "RevisionControl"
      ];
    };
    ely-mark = {
      name = "ElyMark";
      comment = "Markdown editor";
      categories = [
        "Utility"
        "TextEditor"
      ];
    };
  };

  # The kernel is built against AlmaLinux 8 (glibc 2.28) with bundled
  # libraries; these are the system libraries its package declares.
  kernelLibs = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    sqlite
    zlib
    krb5
    dbus
    libxcb
    libxkbcommon
    wayland
    vulkan-loader
    libGL
    fontconfig
    freetype
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elyoffice";
  inherit version src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = lib.genAttrs [
      "ely-account-0.2.0"
      "ely-agent-0.2.0"
      "ely-calendar-0.2.0"
      "ely-canvas-0.2.0"
      "ely-charts-0.2.0"
      "ely-chat-0.2.0"
      "ely-collab-0.2.0"
      "ely-core-0.3.0"
      "ely-dashboard-0.2.0"
      "ely-debug-0.2.0"
      "ely-desktop-0.2.0"
      "ely-devtools-0.2.0"
      "ely-documents-0.2.0"
      "ely-editor-0.2.0"
      "ely-files-0.2.0"
      "ely-finance-0.2.0"
      "ely-generative-0.2.0"
      "ely-git-0.2.0"
      "ely-gpui-component-0.2.0"
      "ely-interaction-0.2.0"
      "ely-mail-0.2.0"
      "ely-maps-0.2.0"
      "ely-media-0.2.0"
      "ely-messaging-0.2.0"
      "ely-misc-0.2.0"
      "ely-onboarding-0.2.0"
      "ely-project-0.2.0"
      "ely-rendering-0.2.0"
      "ely-settings-0.2.0"
      "ely-terminal-0.2.0"
      "ely-tooling-0.2.0"
    ] (_: "sha256-2Atq3d6NfObbISw6sxrV+EDpmt9tdPL1P95NpLbO9v8=");
  };

  # The worker's build script includes engines/mupdf-src/include, which
  # scripts/build-mupdf.sh would populate from reference/mupdf plus patches.
  postPatch = ''
    mkdir -p engines
    ln -s ${mupdfSrc} engines/mupdf-src
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    # rustc lists libc before the worker's static MuPDF and OpenSSL
    # archives, so their atexit reference needs libc once more after them.
    substituteInPlace crates/ely-pdf-worker/build.rs \
      --replace-fail 'println!("cargo:rustc-link-arg-bin={bin}={cxx}");' \
      'println!("cargo:rustc-link-arg-bin={bin}={cxx}"); println!("cargo:rustc-link-arg-bin={bin}=-lc");'
  '';

  env.ELY_MUPDF_DIR = "${mupdf}";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ];

  buildInputs = [
    opensslStatic
    sqlite
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dbus
    fontconfig
    freetype
    libxcb
    libxkbcommon
    wayland
    vulkan-loader
    libGL
  ];

  # The suite's tests need the engines, a GUI and network.
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share"

    # cargo builds under target/<rust-target>/release here.
    release=$(dirname "$(find target -type f -name ely-doc -perm -u+x -print -quit)")

    for app in ${lib.escapeShellArgs (builtins.attrNames apps)}; do
      install -Dm755 "$release/$app" "$out/bin/$app"
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        install -Dm444 "${src}/assets/icons/$app.png" \
          "$out/share/icons/hicolor/512x512/apps/$app.png"
      ''}
    done

    install -Dm755 "$release/ely-lok-worker" "$out/bin/ely-lok-worker"
    install -Dm755 "$release/ely-pdf-worker" "$out/bin/ely-pdf-worker"

    # ElyPDF reads pictures with Tesseract; the app finds this beside itself.
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        lang: data: ''install -Dm644 "${data}" "$out/bin/tessdata/${lang}.traineddata"''
      ) tessdata
    )}

    # ElyTree carries Git; every app looks for it in bin/git.
    mkdir -p "$out/bin/git"
    ln -s "${git}/bin/git" "$out/bin/git/git"
    ln -s "${git-lfs}/bin/git-lfs" "$out/bin/git/git-lfs"

    # The apps look for the kernel beside themselves; the wrapper names it on
    # macOS, where LibreOffice keeps Contents/Resources/ beside Frameworks/.
    mkdir -p "$out/lib/elyoffice"
    ln -s "${kernel}/lib/elyoffice/libreoffice" "$out/lib/elyoffice/libreoffice"
    ln -s ../lib/elyoffice/libreoffice "$out/bin/libreoffice"

    install -Dm644 "${src}/LICENSE" "$out/share/licenses/elyoffice/LICENSE"
    install -Dm644 "${mupdfSrc}/COPYING" "$out/share/licenses/elyoffice/MuPDF-COPYING"

    for app in ${lib.escapeShellArgs (builtins.attrNames apps)}; do
      lok=()
      case "$app" in
        ely-doc | ely-table | ely-show)
          lok=(--set-default ELY_LOK_DIR "$out/lib/elyoffice/libreoffice/${
            if stdenv.hostPlatform.isDarwin then
              if buildKernelFromSource then "Frameworks" else "Contents/Frameworks"
            else
              "program"
          }")
          ;;
      esac
      wrapProgram "$out/bin/$app" \
        ${lib.optionalString stdenv.hostPlatform.isLinux ''
          --prefix LD_LIBRARY_PATH : "$out/lib/elyoffice/libreoffice/program:${kernelLibs}" \
        ''} \
        "''${lok[@]}" \
        --prefix PATH : ${
          lib.makeBinPath [
            git
            git-lfs
          ]
        }
    done

    runHook postInstall
  '';

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux (
    lib.mapAttrsToList (
      app: info:
      makeDesktopItem {
        name = app;
        desktopName = info.name;
        comment = info.comment;
        exec = app;
        icon = app;
        categories = info.categories;
        startupWMClass = info.name;
      }
    ) apps
  );

  passthru = {
    inherit kernel mupdf mupdfSrc;
    updateScript = writeShellApplication {
      name = "update-elyoffice";
      runtimeInputs = [
        nix
        nix-update
        python3
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="elyoffice"
        exec ${./update.sh} "$@"
      '';
    };
  };

  meta = {
    description = "Offline office suite: documents, sheets, slides, PDF, mail, Git and Markdown";
    longDescription = ''
      Ely Office's seven apps (ElyDoc, ElyTable, ElyShow, ElyPDF, ElyMail,
      ElyTree, ElyMark) are built from the pinned upstream source. ElyPDF and
      ElyMark link MuPDF 1.28.5 built here with Ely's patches, and the PDF
      worker links a static OpenSSL. ElyDoc, ElyTable and ElyShow load the
      LibreOffice 26.2.6.3 kernel. On aarch64-darwin it is built from the
      pinned LibreOffice/core commit with Ely's patches (see
      ./libreoffice.nix); elsewhere it comes from the matching upstream
      release.
    '';
    homepage = "https://github.com/ELY-Open-Source/ElyOffice";
    changelog = "https://github.com/ELY-Open-Source/ElyOffice/releases/tag/v${version}";
    license = with lib.licenses; [
      mit
      agpl3Plus
      mpl20
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "ely-doc";
  };
})
