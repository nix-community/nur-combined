# to update:
# - first, figure the rev for `koreader-base`:
#   - inside `koreader` repo:
#     - `git submodule status base`
#     - or `git log base`
# - inside `koreader-base` repo:
#   - `git diff old-rev..new-rev thirdparty`
#
# koreader's native build process
# 1. git clone each dependency lib into base/thirdparty/$lib
# 2. git checkout a specific rev into base/thirdparty/$lib/build/$platform
# 3. invoke cmake in the checkout dir (including `make install` equivalent), which seems to not write outside the dir
# 4. manually copy the "installed" files in that checkout to some other place for koreader to use
#    - see: koreader/base/Makefile.third
# ...
# koreader and all its deps are installed to $out/lib/koreader
# - i.e. it vendors its runtime deps
#
# a good way to substitute nixpkgs deps in place of KOReader's vendored deps is to
# inject them into base/Makefile.third, via makeFlags.
# failing that, we can patch the source of each vendored library into base/thirdparty/*/CMakeLists.txt
# and KOReader will build them from-source perfectly, but that's more involved on our end.
#
# TODO:
# - don't vendor fonts
{
  lib,
  autoPatchelfHook,
  autoconf,
  automake,
  buildPackages,
  cmake,
  fetchFromGitHub,
  fetchFromGitLab,
  fetchurl,
  gettext,
  git,
  libtool,
  luajit,
  makeBinaryWrapper,
  pkg-config,
  stdenv,
  symlinkJoin,

# third-party dependencies which KOReader would ordinarily vendor
  curl,
  czmq,
  djvulibre,
  dropbear,
  freetype,
  fribidi,
#   gettext,
  giflib,
  glib,
  gnutar,
  harfbuzz,
  libiconvReal,
  libjpeg_turbo,
  libpng,
  libunibreak,
  libwebp,
  nanosvg,
  openssl,
  openssh,
  sdcv,
  SDL2,  # koreader doesn't actually vendor this, just expects it'll magically be available
  sqlite,
  utf8proc,
  zlib,
  zeromq4,
  zstd,
  zsync,
}:
let
  sourcesFor = pins: rec {
    koreader = fetchFromGitHub {
      owner = "koreader";
      repo = "koreader";
      name = "koreader";  # needed because `srcs = ` in the outer derivation is a list
      fetchSubmodules = true;
      rev = "v${pins.version}";
      inherit (pins.koreader) hash;
    };

    fbink-src-ko = fetchFromGitHub {
      owner = "NiLuJe";
      repo = "FBInk";
      name = "fbink";  # where to unpack this in `srcs`
      inherit (pins.fbink) rev hash;
    };

    kobo-usbms-src-ko = fetchFromGitHub {
      owner = "koreader";
      repo = "KoboUSBMS";
      name = "kobo-usbms";  # where to unpack this in `srcs`
      inherit (pins.kobo-usbms) rev hash;
    };

    leptonica-src-ko = fetchFromGitHub {
      # k2pdf needs leptonica src, because it actually patches it and builds it itself:
      # - `cp -f $(LEPTONICA_MOD)/dewarp2.c $(LEPTONICA_DIR)/src/dewarp2.c`
      # -  i.e. cp -f /build/koreader/base/thirdparty/libk2pdfopt/build/aarch64-unknown-linux-gnu/libk2pdfopt-prefix/src/libk2pdfopt/leptonica_mod/dewarp2.c ...
      # k2pdf uses an old leptonica -- like 2015-2017-ish (1.74.1).
      # seems it can be at least partially updated, by replacing `numaGetMedianVariation` with `numaGetMedianDevFromMedian` (drop-in replacement)
      # and replacing references to `liblept.so` with `libleptonica.so`,
      # but eventually this requires patching the tesseract Makefiles. could get intense, idk.
      owner = "DanBloomberg";
      repo = "leptonica";
      name = "leptonica";  # where to unpack this in `srcs`
      inherit (pins.leptonica) rev hash;
    };

    libk2pdfopt-src-ko = fetchFromGitHub {
      owner = "koreader";
      repo = "libk2pdfopt";
      name = "libk2pdfopt";  # where to unpack this in `srcs`
      inherit (pins.libk2pdfopt) rev hash;
    };

    lodepng-src-ko = fetchFromGitHub {
      owner = "lvandeve";
      repo = "lodepng";
      name = "lodepng";  # where to unpack this in `srcs`
      inherit (pins.lodepng) rev hash;
    };

    lunasvg-src-ko = fetchFromGitHub {
      owner = "sammycage";
      repo = "lunasvg";
      name = "lunasvg";  # where to unpack this in `srcs`
      inherit (pins.lunasvg) rev hash;
    };

    minizip-src-ko = fetchFromGitHub {
      # this is actually just a very old version (2015) of `minizip-ng`
      owner = "nmoinvaz";
      repo = "minizip";
      name = "minizip";  # where to unpack this in `srcs`
      inherit (pins.minizip) rev hash;
    };

    mupdf-src-ko = fetchFromGitHub {
      owner = "ArtifexSoftware";
      repo = "mupdf";
      name = "mupdf";  # where to unpack this in `srcs`
      fetchSubmodules = true;  # specifically for jbig2dec, mujs, openjpeg
      inherit (pins.mupdf) rev hash;
    };

    nanosvg-headers-ko = symlinkJoin {
      # koreader's heavily-patched mupdf is dependent on a koreader-specific `stb_image_write` extension to nanosvg.
      # nanosvg is used as a header-only library, so just patch that extension straight into the src.
      name = "nanosvg-headers-ko";
      paths = [
        "${nanosvg.src}/src"
        "${koreader}/base/thirdparty/nanosvg"
      ];
    };

    popen-noshell-src-ko = fetchFromGitHub {
      owner = "famzah";
      repo = "popen-noshell";
      name = "popen-noshell";
      inherit (pins.popen-noshell) rev hash;
    };

    tesseract-src-ko = fetchFromGitHub {
      # TODO: try using nixpkgs' tesseract.src (i doubt it will work)
      owner = "tesseract-ocr";
      repo = "tesseract";
      name = "tesseract";
      inherit (pins.tesseract) rev hash;
    };

    turbo-src-ko = fetchFromGitHub {
      owner = "kernelsauce";
      repo = "turbo";
      name = "turbo";
      inherit (pins.turbo) rev hash;
    };
  };

  thirdparty = [
    curl
    czmq
    djvulibre
    dropbear
    freetype
    fribidi
    gettext
    giflib
    glib
    gnutar
    harfbuzz
    libiconvReal
    libjpeg_turbo
    libpng
    libunibreak
    libwebp
    openssl
    openssh
    sdcv
    SDL2
    sqlite
    utf8proc
    zlib
    zeromq4
    zstd
    zsync
  ];

  overlayedLuaPkgs = luaPkgs: let
    ps = with ps; {
      luajson = buildLuarocksPackage rec {
        # needed by KOReader's lua-Spore
        pname = "luajson";
        version = "1.3.4-1";
        src = fetchFromGitHub {
          owner = "harningt";
          repo = "luajson";
          # rev = "1.3.4";
          # 1.3.4 (released 2017) has some incompatible bugs with lpeg library.
          # see: <https://github.com/harningt/luajson/commit/6ecaf9bea8b121a9ffca5a470a2080298557b55d>
          rev = "6ecaf9bea8b121a9ffca5a470a2080298557b55d";
          hash = "sha256-56G0NqIpavKHMQWUxy+Bp7G4ZKrQwUZ2C5e7GJxUJeg=";
        };
        knownRockspec = (fetchurl {
          url = "mirror://luarocks/${pname}-${version}.rockspec";
          hash = "sha256-+S4gfa6QaOMmOCDX8TxBq3kFWlbaEeiSMxCfefYakv0=";
        }).outPath;
        propagatedBuildInputs = [ lpeg ];
      };
      htmlparser = buildLuarocksPackage rec {
        pname = "htmlparser";  #< name of the rockspec, not the repo
        version = "0.3.9-1";
        src = fetchFromGitHub {
          owner = "msva";
          repo = "lua-htmlparser";
          # the rockspec was added to the repo *after* v0.3.9 was tagged
          rev = "5ce9a775a345cf458c0388d7288e246bb1b82bff";
          hash = "sha256-aSTLSfqz/MIDFVRwtBlDNBUhPb7KqOl32/Y62Hdec1s=";
        };
        knownRockspec = "${src}/rockspecs/${pname}-${version}.rockspec";
      };
      lua-spore = buildLuarocksPackage rec {
        pname = "lua-spore";  #< name of the rockspec, not the repo
        version = "0.3.3-1";
        src = fetchFromGitLab {
          domain = "framagit.org";
          owner = "fperrad";
          repo = "lua-Spore";
          rev = "0.3.3";
          hash = "sha256-wb7ykJsndoq0DazHpfXieUcBBptowYqD/eTTN/EK/6g=";
        };
        knownRockspec = "${src}/rockspec/${pname}-${version}.rockspec";
        propagatedBuildInputs = [
          luajson
          luasocket
        ];
        # don't ship lua-Spore binaries: they drag in a whole copy of cmake
        postInstall = ''
          rm -rf "$out/bin"
        '';
      };
    } // luaPkgs;
  in ps;

  crossTargets = {
    # koreader-base Makefile targets to use when compiling for the given host platform
    # only used when cross compiling
    aarch64 = "debian-arm64";
  };
  target = if stdenv.buildPlatform == stdenv.hostPlatform then
    "debian"
  else
    crossTargets."${stdenv.hostPlatform.parsed.cpu.name}";

  getContrib = pkg: stdenv.mkDerivation {
    inherit (pkg) name src;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir "$out"
      cp -R ./contrib/ "$out/contrib"
    '';
  };

  lib' = lib;
  fhsLib = pkg: { lib ? true, include ? true, flatLib ? false, flatInclude ? false, contrib ? false }: symlinkJoin {
    inherit (pkg) name;
    paths = (lib'.optionals lib [
      "${lib'.getLib pkg}"
    ]) ++ (lib'.optionals include [
      "${lib'.getDev pkg}"
    ]) ++ (lib'.optionals flatLib [
      "${lib'.getLib pkg}/lib"
    ]) ++ (lib'.optionals flatInclude [
      "${lib'.getDev pkg}/include"
    ]) ++ (lib'.optionals contrib [
      "${getContrib pkg}"
    ]);
  };

  # mostly for k2pdf, which expects lib/ and include/ for each dep to live side-by-side
  libAndDev = pkg: fhsLib pkg { lib = true; include = true; };
in
stdenv.mkDerivation (finalAttrs: with finalAttrs; let
  pins = lib.importJSON ./versions.json;
  sources = sourcesFor pins;

  # XXX: for some inscrutable reason, `enable52Compat` is *partially* broken, only when cross compiling.
  # `table.unpack` is non-nil, but `table.pack` is nil.
  # the normal path is for `enable52Compat` to set `env.NIX_CFLAGS_COMPILE = "-DLUAJIT_ENABLE_LUA52COMPAT";`
  # which in turn sets `#define LJ_52 1`, and gates functions like `table.pack`, `table.unpack`.
  # instead, koreader just removes the `#if LJ_52` gates. doing the same in nixpkgs seems to work.
  # luajit52 = luajit.override { enable52Compat = true; self = luajit52; };
  luajit52 = (luajit.override { self = luajit52; }).overrideAttrs (super: {
    patches = (super.patches or []) ++ [
      "${sources.koreader}/base/thirdparty/luajit/koreader-luajit-enable-table_pack.patch"
    ];
  });

  luaEnv = luajit52.withPackages (ps: with (overlayedLuaPkgs ps); [
    luajson
    htmlparser
    lua-spore
    lpeg
    luasec
    luasocket
    rapidjson
  ]);

  rockspecFor = luaPkgName: let
    pkg = (overlayedLuaPkgs luaEnv.pkgs)."${luaPkgName}";
  in
    "${luaEnv}/${pkg.rocksSubdir}/${luaPkgName}/${pkg.rockspecVersion}/${luaPkgName}-${pkg.rockspecVersion}.rockspec";

  # these probably have more dirs than they really need.
  djvulibreAll = fhsLib djvulibre { lib=true; include=true; flatInclude=true; };
  opensslAll = fhsLib openssl { lib=false; include=true; flatLib=true; };
  utf8procAll = fhsLib utf8proc { lib=true; include=false; flatInclude=true; };
  # KOreader uses ZLIB_DIR as:
  # - -L${ZLIB_DIR}
  # - -I${ZLIB_DIR}
  # - -I${ZLIB_DIR}/include
  zlibAll = fhsLib zlib { lib=false; include=true; flatLib=true; flatInclude=true; contrib=true; };

  # values to provide to koreader/base/Makefile.defs.
  # should be ok to put this in `makeFlags` array, but i can't get that to work!
  makefileDefs = with sources; ''
    CURL_LIB="${lib.getLib curl}/lib/libcurl.so" \
    CURL_DIR="${lib.getDev curl}" \
    CZMQ_LIB="${lib.getLib czmq}/lib/libczmq.so" \
    CZMQ_DIR="${lib.getDev czmq}" \
    DJVULIBRE_LIB="${lib.getLib djvulibre}/lib/libdjvulibre.so" \
    DJVULIBRE_LIB_LINK_FLAG="-L ${lib.getLib djvulibre}/lib -l:libdjvulibre.so" \
    DJVULIBRE_DIR="${djvulibreAll}" \
    FBINK_DIR="$NIX_BUILD_TOP/fbink" \
    FREETYPE_LIB="${lib.getLib freetype}/lib/libfreetype.so" \
    FREETYPE_LIB_LINK_FLAG="-L ${lib.getLib freetype}/lib -l:libfreetype.so" \
    FREETYPE_DIR="${lib.getDev freetype}" \
    FRIBIDI_LIB="${lib.getLib fribidi}/lib/libfribidi.so" \
    FRIBIDI_LIB_LINK_FLAG="-L ${lib.getLib fribidi}/lib -l:libfribidi.so" \
    FRIBIDI_DIR="${lib.getDev fribidi}" \
    GETTEXT_DIR="${lib.getDev gettext}" \
    LIBGETTEXT="${lib.getLib gettext}/lib/preloadable_libintl.so" \
    GIF_LIB="${lib.getLib giflib}/lib/libgif.so" \
    GIF_DIR="${lib.getDev giflib}" \
    GLIB="${lib.getLib glib}/lib/libglib-2.0.so" \
    GLIB_DIR="${lib.getDev glib}" \
    HARFBUZZ_LIB="${lib.getLib harfbuzz}/lib/libharfbuzz.so" \
    HARFBUZZ_LIB_LINK_FLAG="-L ${lib.getLib harfbuzz}/lib -l:libharfbuzz.so" \
    HARFBUZZ_DIR="${lib.getDev harfbuzz}" \
    JPEG_LIB="${lib.getLib libjpeg_turbo}/lib/libjpeg.so" \
    JPEG_LIB_LINK_FLAG="-L ${lib.getLib libjpeg_turbo}/lib -l:libjpeg.so" \
    JPEG_DIR="${lib.getDev libjpeg_turbo}" \
    TURBOJPEG_LIB="${lib.getLib libjpeg_turbo}/lib/libturbojpeg.so" \
    K2PDFOPT_DIR="$NIX_BUILD_TOP/libk2pdfopt" \
    KOBO_USBMS_DIR="$NIX_BUILD_TOP/kobo-usbms" \
    LEPTONICA_DIR="$NIX_BUILD_TOP/leptonica" \
    LIBICONV="${lib.getLib libiconvReal}/lib/libiconv.so" \
    LIBICONV_DIR="${lib.getDev libiconvReal}" \
    LIBUNIBREAK_LIB="${lib.getLib libunibreak}/lib/libunibreak.so" \
    LIBUNIBREAK_DIR="${libAndDev libunibreak}" \
    LIBUNIBREAK_LIB_LINK_FLAG="-L ${lib.getLib libunibreak}/lib -l:libunibreak.so" \
    LIBWEBP_LIB="${lib.getLib libwebp}/lib/libwebp.so" \
    LIBWEBPDEMUX_LIB="${lib.getLib libwebp}/lib/libwebpdemux.so" \
    LIBWEBPSHARPYUV_LIB="${lib.getLib libwebp}/lib/libwebpsharpyuv.so" \
    LIBWEBP_DIR="${lib.getDev libwebp}" \
    LODEPNG_DIR="$NIX_BUILD_TOP/lodepng" \
    LPEG_ROCK="${rockspecFor "lpeg"}" \
    LUNASVG_DIR="$NIX_BUILD_TOP/lunasvg" \
    LUAJIT="${luaEnv}/bin/luajit" \
    LUAJIT_JIT="${luaEnv}/share/lua/5.1/jit" \
    LUAJIT_LIB="${lib.getLib luaEnv}/lib/libluajit-5.1.so" \
    LUASEC="${luaEnv}/share/lua/5.1/ssl/" \
    LUASOCKET="${luaEnv}/share/lua/5.1/socket/" \
    LUA_HTMLPARSER_ROCK="${rockspecFor "htmlparser"}" \
    LUA_INCDIR="${lib.getDev luaEnv}/include" \
    LUA_LIBDIR="${lib.getLib luaEnv}/lib/libluajit-5.1.so" \
    LUA_RAPIDJSON_ROCK="${rockspecFor "rapidjson"}" \
    LUA_SPORE_ROCK="${rockspecFor "lua-spore"}" \
    MINIZIP_DIR="$NIX_BUILD_TOP/minizip" \
    MUPDF_DIR="$NIX_BUILD_TOP/mupdf" \
    NANOSVG_HEADERS="${nanosvg-headers-ko}" \
    NANOSVG_INCLUDE_DIR="${nanosvg-headers-ko}" \
    OPENSSL_LIB="${lib.getLib openssl}/lib/libssl.so" \
    OPENSSL_DIR="${opensslAll}" \
    SSL_LIB="${lib.getLib openssl}/lib/libssl.so.3" \
    CRYPTO_LIB="${lib.getLib openssl}/lib/libcrypto.so" \
    PNG_LIB="${lib.getLib libpng}/lib/libpng.so" \
    PNG_DIR="${libAndDev libpng}" \
    POPEN_NOSHELL_DIR="$NIX_BUILD_TOP/popen-noshell" \
    SQLITE_LIB="${lib.getLib sqlite}/lib/libsqlite3.so" \
    SQLITE_DIR="${lib.getDev sqlite}" \
    TESSERACT_DIR="$NIX_BUILD_TOP/tesseract" \
    TURBO_DIR="$NIX_BUILD_TOP/turbo" \
    UTF8PROC_LIB="${lib.getLib utf8proc}/lib/libutf8proc.so" \
    UTF8PROC_DIR="${utf8procAll}" \
    ZLIB="${lib.getLib zlib}/lib/libz.so" \
    ZLIB_DIR="${zlibAll}" \
    ZLIB_STATIC="${zlib.static}/lib/libz.a" \
    ZMQ_LIB="${lib.getLib zeromq4}/lib/libzmq.so" \
    ZMQ_DIR="${lib.getDev zeromq4}" \
    ZSTD_LIB="${lib.getLib zstd}/lib/libzstd.so" \
    ZSTD_DIR="${lib.getDev zstd}" \
    ZSTD_DESTDIR="${lib.getDev zstd}" \
  '';

  # DO_STRIP=0 else it'll try to strip our externally built libraries, and error because those live in the nix store.
  # PARALLEL_LOAD=1 else `ninja` does weird things (it's something parallelism related).
  makeFlags = ''
    TARGET=${target} DEBIAN=1 SHELL=sh VERBOSE=1 \
      PARALLEL_LOAD=1 \
      DO_STRIP=0 \
      ${makefileDefs} \
  '';

  symlinkThirdpartyBins = outdir: ''
    ln -sf ${lib.getExe' dropbear "dropbear"}         ${outdir}/dropbear
    ln -sf ${lib.getExe gnutar}                       ${outdir}/tar
    ln -sf ${lib.getBin openssh}/libexec/sftp-server  ${outdir}/sftp-server
    ln -sf ${lib.getExe sdcv}                         ${outdir}/sdcv
    ln -sf ${lib.getExe' zsync "zsync"}               ${outdir}/zsync2
  '';
in {
  pname = "koreader-from-src";
  inherit (pins) version;
  srcs = [
    sources.koreader
    sources.fbink-src-ko
    sources.kobo-usbms-src-ko
    sources.leptonica-src-ko
    sources.libk2pdfopt-src-ko
    sources.lodepng-src-ko
    sources.lunasvg-src-ko
    sources.minizip-src-ko
    sources.mupdf-src-ko
    sources.popen-noshell-src-ko
    sources.tesseract-src-ko
    sources.turbo-src-ko
  ];

  patches = [
    # ./debug.patch  #< not needed to build, just helps debug packaging issues
    ./rss-no-interrupt-on-image-failure.patch  # just a preference
  ];

  sourceRoot = "koreader";

  nativeBuildInputs = [
    buildPackages.stdenv.cc
    autoconf  # autotools is used by some thirdparty libraries
    automake
    autoPatchelfHook  # used by us, in fixupPhase, to ensure substituted thirdparty deps can be loaded at runtime
    cmake  # for koreader/base submodule
    git
    libtool
    makeBinaryWrapper
    pkg-config
  ];
  buildInputs = [
    luaEnv  #< specifically for lua.h
  ];

  postPatch = ''
    # patch for newer openssl
    substituteInPlace base/ffi/crypto.lua \
      --replace-fail 'ffi.load("libs/libcrypto.so.1.1")' 'ffi.load("libcrypto.so")'

    # dlopen libraries by name only, allowing them to be found via LD_LIBRARY_PATH
    # instead of just via $out/libs. this is required whenever we direct KOreader to use system libs instead of its vendored libs.
    for f in $(shopt -s globstar; ls **/*.lua) ; do
      substituteInPlace "$f" \
        --replace-quiet 'ffi.load("libs/' 'ffi.load("'
    done

    # don't force-rebuild third-party components, else we can't replace them with our own
    substituteInPlace base/Makefile.third \
      --replace-fail '	-rm ' '	# -rm'

    # make some sources writable, particularly so koreader can apply its patches (by default only the `sourceRoot` is writable)
    chmod -R u+w "$NIX_BUILD_TOP"/{fbink,kobo-usbms,leptonica,libk2pdfopt,lodepng,lunasvg,minizip,mupdf,popen-noshell,tesseract,turbo}
    # koreader builds these deps itself: we mock out the download stage, and it does the rest
    for dep in fbink kobo-usbms libk2pdfopt lodepng lunasvg minizip mupdf popen-noshell turbo; do
      # sed -i 's/DOWNLOAD_COMMAND .*/DOWNLOAD_COMMAND ""/' "base/thirdparty/$dep/CMakeLists.txt"
      sed -i "s:DOWNLOAD_COMMAND .*:DOWNLOAD_COMMAND rm -fd $dep $dep-build \\&\\& ln -s $NIX_BUILD_TOP/$dep $dep \\&\\& ln -s $NIX_BUILD_TOP/$dep $dep-build :" "base/thirdparty/$dep/CMakeLists.txt"
    done

    # lots of places in Makefile.third (incorrectly) assume lib paths are relative to CURDIR,
    # so link /nix into CURDIR to allow them to work anyway
    ln -s /nix base/nix
  '';

  dontConfigure = true;
  buildPhase = ''
    # outDir should match OUTPUT_DIR in koreader-base
    outDir="$NIX_BUILD_TOP/koreader/base/build/${stdenv.hostPlatform.config}"
    mkdir -p "$outDir"
    ${symlinkThirdpartyBins "$outDir"}

    make ${makeFlags}
  '';

  env = lib.optionalAttrs (stdenv.buildPlatform != stdenv.hostPlatform) {
    CHOST = stdenv.hostPlatform.config;
  };

  installPhase = ''
    # XXX: build without INSTALL_DIR="$out" as make arg because that conflicts with vars used by third-party libs.
    # instead, `make` and then manually install koreader to $out ourselves.
    # TODO: might be safe to specify `INSTALL_DIR` here as an env var instead, though?
    make debianupdate ${makeFlags}

    mv koreader-${target}-${stdenv.hostPlatform.config}/debian/usr $out

    # XXX: nixpkgs' `koreader` adds glib and gtk3-x11 to LD_LIBRARY_PATH as well.
    wrapProgram $out/bin/koreader --prefix LD_LIBRARY_PATH : ${
      (lib.makeLibraryPath thirdparty) + ":$out/lib/koreader/libs"
    }
  '';

  preFixup = ''
    # koreader installation copies the thirdparty binaries like tar, sdcv, which we injected earlier.
    # but we specifically want these to live in the nix store and be symlinked into koreader instead.
    # TODO: this might symlink binaries which koreader doesn't actually use...
    #       i should either only overwrite the binaries which DO exist at this point,
    #       or find some other way to inject them (i can maybe just put them on KOreader's PATH?).
    ${symlinkThirdpartyBins "$out/lib/koreader"}
    ${lib.concatStringsSep "\n" (builtins.map (dep: ''
        if [ -e "${lib.getLib dep}/lib" ]; then
          addAutoPatchelfSearchPath "${lib.getLib dep}/lib"
        fi
      '') thirdparty)
    }
  '';

  passthru = {
    # exposed for debugging
    inherit luajit52 luaEnv mupdf-src-ko nanosvg-headers-ko rockspecFor;
    inherit (overlayedLuaPkgs luaEnv.pkgs)
      luajson
      htmlparser
      lua-spore
    ;
    updateScript = [ ./update ];
    updateWithSuper = false;  # XXX: `update` doesn't update everything -- just the toplevel version/hash -- so disable unless i start using the package more
  };

  meta = with lib; {
    homepage = "https://github.com/koreader/koreader";
    description =
      "An ebook reader application supporting PDF, DjVu, EPUB, FB2 and many more formats, running on Cervantes, Kindle, Kobo, PocketBook and Android devices";
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ colinsane ];
  };
})
