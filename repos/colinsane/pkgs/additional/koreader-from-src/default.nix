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
# - package enough of KOReader's deps to remove `sources.nix`
#   - SDL2 (only used by macos??)
#   - FBINK
#   - NANOSVG  (slightly complicated; koreader needs access to its source code)
#   - SRELL
# - build crengine dep via nixpkgs `coolreader` pkg (with source patched to <https://github.com/koreader/crengine>)?
{ lib
, autoPatchelfHook
, autoconf
, automake
, buildPackages
, callPackage
, cmake
, dpkg
, fetchFromGitHub
, fetchgit
, fetchurl
, gettext
, git
, libtool
, luajit
, makeWrapper
, perl
, pkg-config
, pkgs
, python3
, ragel
, stdenv
, substituteAll
, which

# third-party dependencies which KOReader would ordinarily vendor
, symlinkJoin
, curl
, czmq
, djvulibre
, dropbear
, freetype
, fribidi
# , gettext
, giflib
, glib
, gnutar
, harfbuzz
, libiconvReal
, libjpeg_turbo
, libpng
, libunibreak
, libwebp
, openssl
, openssh
, sdcv
, SDL2  # koreader doesn't actually vendor this, just expects it'll magically be available
, sqlite
, utf8proc
, zlib
, zeromq4
, zstd
, zsync
}:
let
  sources = callPackage ./sources.nix { luajit = luajit52; };
  version = "2024.03";
  src = fetchFromGitHub {
    owner = "koreader";
    repo = "koreader";
    name = "koreader";  # needed because `srcs = ` in the outer derivation is a list
    fetchSubmodules = true;
    rev = "v${version}";
    hash = "sha256-/51pOGSAoaS0gOKlqNKruwaKY5qylzCpeNUrWyzYTpA=";
  };
  # XXX: for some inscrutable reason, `enable52Compat` is *partially* broken, only when cross compiling.
  # `table.unpack` is non-nil, but `table.pack` is nil.
  # the normal path is for `enable52Compat` to set `env.NIX_CFLAGS_COMPILE = "-DLUAJIT_ENABLE_LUA52COMPAT";`
  # which in turn sets `#define LJ_52 1`, and gates functions like `table.pack`, `table.unpack`.
  # instead, koreader just removes the `#if LJ_52` gates. doing the same in nixpkgs seems to work.
  # luajit52 = luajit.override { enable52Compat = true; self = luajit52; };
  luajit52 = (luajit.override { self = luajit52; }).overrideAttrs (super: {
    patches = (super.patches or []) ++ [
      "${src}/base/thirdparty/luajit/koreader-luajit-enable-table_pack.patch"
    ];
  });
  luaEnv = luajit52.withPackages (ps: with ps; [
    (buildLuarocksPackage {
      # needed by KOReader's lua-Spore
      pname = "luajson";
      version = "1.3.4-1";
      src = fetchgit {
        url = "https://github.com/harningt/luajson.git";
        # rev = "1.3.4";
        # 1.3.4 (released 2017) has some incompatible bugs with lpeg library.
        # see: <https://github.com/harningt/luajson/commit/6ecaf9bea8b121a9ffca5a470a2080298557b55d>
        rev = "6ecaf9bea8b121a9ffca5a470a2080298557b55d";
        hash = "sha256-56G0NqIpavKHMQWUxy+Bp7G4ZKrQwUZ2C5e7GJxUJeg=";
      };
      knownRockspec = (fetchurl {
        url = "mirror://luarocks/luajson-1.3.4-1.rockspec";
        hash = "sha256-+S4gfa6QaOMmOCDX8TxBq3kFWlbaEeiSMxCfefYakv0=";
      }).outPath;
      propagatedBuildInputs = [ lpeg ];
    })
    lpeg
    luasec
    luasocket
    rapidjson
  ]);
  rockspecFor = luaPkgName: let
    pkg = luaEnv.pkgs."${luaPkgName}";
  in
    "${luaEnv}/${pkg.rocksSubdir}/${luaPkgName}/${pkg.rockspecVersion}/${luaPkgName}-${pkg.rockspecVersion}.rockspec";
  crossTargets = {
    # koreader-base Makefile targets to use when compiling for the given host platform
    # only used when cross compiling
    aarch64 = "debian-arm64";
  };
  target = if stdenv.buildPlatform == stdenv.hostPlatform then
    "debian"
  else
    crossTargets."${stdenv.hostPlatform.parsed.cpu.name}";

  fakeBuildDep = buildPackages.writeShellScript "fake-build-ko-dep" ''
    set -x
    lib="$1"
    build_dir="$2"
    prebuilt="$3"
    mkdir -p "$build_dir/$lib-prefix/src"
    rm -rf "$build_dir/$lib-prefix/src/$lib"
    rm -rf "$build_dir/$lib-prefix/src/$lib-build"
    # the library build directory koreader uses isn't consistently named, but we can cover most cases ($lib or $lib-build).
    # we have to copy the full tree rather than just symlink because koreader/base/Makefile.third
    # is copying lib/*.so into include/.
    # seriously, wtf are they doing over there.
    cp -R "$prebuilt" "$build_dir/$lib-prefix/src/$lib"
    cp -R "$prebuilt" "$build_dir/$lib-prefix/src/$lib-build"
    # ln -s "$prebuilt" "$build_dir/$lib-prefix/src/$lib"
    # ln -s "$prebuilt" "$build_dir/$lib-prefix/src/$lib-build"
  '';

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

  # these probably have more dirs than they really need.
  djvulibreAll = fhsLib djvulibre { lib=true; include=true; flatInclude=true; };
  opensslAll = fhsLib openssl { lib=false; include=true; flatLib=true; };
  utf8procAll = fhsLib utf8proc { lib=true; include=false; flatInclude=true; };
  # KOreader uses ZLIB_DIR as:
  # - -L${ZLIB_DIR}
  # - -I${ZLIB_DIR}
  # - -I${ZLIB_DIR}/include
  zlibAll = fhsLib zlib { lib=false; include=true; flatLib=true; flatInclude=true; contrib=true; };

  libunibreak' = libunibreak.overrideAttrs (canon: {
    patches = (canon.patches or []) ++ [
      "${src}/base/thirdparty/libunibreak/add_lb_get_char_class.patch"
    ];
  });

  # values to provide to koreader/base/Makefile.defs.
  # should be ok to put this in `makeFlags` array, but i can't get that to work!
  # LUAROCKS_BINARY substitution is to support the cross-compilation case (i.e. emulate it during the build process)
  makefileDefs = ''
    CURL_LIB="${lib.getLib curl}/lib/libcurl.so" \
    CURL_DIR="${lib.getDev curl}" \
    CZMQ_LIB="${lib.getLib czmq}/lib/libczmq.so" \
    CZMQ_DIR="${lib.getDev czmq}" \
    DJVULIBRE_LIB="${lib.getLib djvulibre}/lib/libdjvulibre.so" \
    DJVULIBRE_LIB_LINK_FLAG="-L ${lib.getLib djvulibre}/lib -l:libdjvulibre.so" \
    DJVULIBRE_DIR="${djvulibreAll}" \
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
    LIBICONV="${lib.getLib libiconvReal}/lib/libiconv.so" \
    LIBICONV_DIR="${lib.getDev libiconvReal}" \
    LIBUNIBREAK_LIB="${lib.getLib libunibreak'}/lib/libunibreak.so" \
    LIBUNIBREAK_DIR="${libAndDev libunibreak'}" \
    LIBUNIBREAK_LIB_LINK_FLAG="-L ${lib.getLib libunibreak'}/lib -l:libunibreak.so" \
    LIBWEBP_LIB="${lib.getLib libwebp}/lib/libwebp.so" \
    LIBWEBPDEMUX_LIB="${lib.getLib libwebp}/lib/libwebpdemux.so" \
    LIBWEBPSHARPYUV_LIB="${lib.getLib libwebp}/lib/libwebpsharpyuv.so" \
    LIBWEBP_DIR="${lib.getDev libwebp}" \
    LPEG_ROCK="${rockspecFor "lpeg"}" \
    LUAROCKS_BINARY="${lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) (stdenv.hostPlatform.emulator buildPackages)} ${luajit52}/bin/lua ${luaEnv.pkgs.luarocks}/bin/.luarocks-wrapped" \
    LUAJIT="${luaEnv}/bin/luajit" \
    LUAJIT_JIT="${luaEnv}/share/lua/5.1/jit" \
    LUAJIT_LIB="${lib.getLib luaEnv}/lib/libluajit-5.1.so" \
    LUASEC="${luaEnv}/share/lua/5.1/ssl/" \
    LUASOCKET="${luaEnv}/share/lua/5.1/socket/" \
    LUA_INCDIR="${lib.getDev luaEnv}/include" \
    LUA_LIBDIR="${lib.getLib luaEnv}/lib/libluajit-5.1.so" \
    LUA_RAPIDJSON_ROCK="${rockspecFor "rapidjson"}" \
    OPENSSL_LIB="${lib.getLib openssl}/lib/libssl.so" \
    OPENSSL_DIR="${opensslAll}" \
    SSL_LIB="${lib.getLib openssl}/lib/libssl.so.3" \
    CRYPTO_LIB="${lib.getLib openssl}/lib/libcrypto.so" \
    PNG_LIB="${lib.getLib libpng}/lib/libpng.so" \
    PNG_DIR="${libAndDev libpng}" \
    SQLITE_LIB="${lib.getLib sqlite}/lib/libsqlite3.so" \
    SQLITE_DIR="${lib.getDev sqlite}" \
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
  makeFlags = ''
    TARGET=${target} DEBIAN=1 SHELL=sh VERBOSE=1 \
      DO_STRIP=0 \
      ${makefileDefs} \
  '';

  symlinkThirdpartyBins = outdir: ''
    ln -sf "${lib.getBin dropbear}/bin/dropbear" "${outdir}/dropbear"
    ln -sf "${lib.getExe gnutar}" "${outdir}/tar"
    ln -sf "${lib.getBin openssh}/libexec/sftp-server" "${outdir}/sftp-server"
    ln -sf "${lib.getBin sdcv}/bin/sdcv" "${outdir}/sdcv"
    ln -sf "${lib.getBin zsync}/bin/zsync" "${outdir}/zsync2"
  '';

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
    libunibreak'
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
in
stdenv.mkDerivation rec {
  pname = "koreader-from-src";
  inherit version;
  srcs = [ src ] ++ (lib.mapAttrsToList
    (name: src: fetchgit (
      {
        inherit name;
      } // src.source // {
        # koreader sometimes specifies the rev as `tags/FOO`.
        # we need to remember that to place the repo where it expects, but we have to strip it here for fetchgit to succeed.
        rev = lib.removePrefix "tags/" src.source.rev;
      }
    ))
    sources.thirdparty
  );

  patches = [
    ./debug.patch  #< not needed to build, just helps debug packaging issues
    ./no_rm_build_dirs.patch
    ./lua-Spore-no-luajson.patch  #< TODO: test this at runtime! we ship luajson, but just don't expose it via luarocks
    ./rss-no-interrupt-on-image-failure.patch  # just a preference
  ];

  sourceRoot = "koreader";

  nativeBuildInputs = [
    buildPackages.stdenv.cc  # TODO: move to depsBuildBuild?
    autoconf  # autotools is used by some thirdparty libraries
    automake
    autoPatchelfHook  # used by us, in fixupPhase, to ensure substituted thirdparty deps can be loaded at runtime
    cmake  # for koreader/base submodule
    git
    libtool
    makeWrapper
    pkg-config
    luaEnv.pkgs.luarocks
  ];
  buildInputs = [
    # luajson
    luaEnv
  ];

  postPatch = ''
    # patch for newer openssl
    substituteInPlace --fail base/ffi/crypto.lua \
      --replace 'ffi.load("libs/libcrypto.so.1.1")' 'ffi.load("libcrypto.so")'

    # dlopen libraries by name only, allowing them to be found via LD_LIBRARY_PATH
    # instead of just via $out/libs. this is required whenever we direct KOreader to use system libs instead of its vendored libs.
    for f in $(shopt -s globstar; ls **/*.lua) ; do
      substituteInPlace "$f" \
        --replace-quiet 'ffi.load("libs/' 'ffi.load("'
    done

    # lots of places in Makefile.third (incorrectly) assume lib paths are relative to CURDIR,
    # so link /nix into CURDIR to allow them to work anyway
    ln -s /nix base/nix
  '';

  dontConfigure = true;
  buildPhase = ''
    link_lib_into_build_dir() {
      lib="$1"
      rev="$2"
      platform="$3"
      prebuilt="$4"

      lib_src="../$lib"
      cmake_lists="base/thirdparty/$lib/CMakeLists.txt"
      build_dir="base/thirdparty/$lib/build/$platform"

      # link the nix clone into the directory koreader would use for checkout
      # ref="base/thirdparty/$l/build/git_checkout"
      # echo "linking thirdparty library $l $ref -> $deref"
      # mkdir -p "$ref"
      # ln -s "$deref" "$ref/$l"
      # mv "$deref" "$ref/$l"
      # cp -R "$deref" "$ref/$l"
      # needs to be writable for koreader to checkout it specific revision
      # chmod u+w -R "$ref/$l/.git"

      # koreader wants to clone each library into this git_checkout dir,
      # then checkout a specific revision,
      # and then copy that checkout into the build/working directory further down.
      # instead, we replicate that effect here, and by creating these "stamp" files
      # koreader will know to skip the `git clone` and `git checkout` calls.
      # the logic we're spoofing lives in koreader/base/thirdparty/cmake_modules/koreader_thirdparty_git.cmake
      stamp_dir="$build_dir/git_checkout/stamp"
      stamp_info="$stamp_dir/$lib-gitinfo-$rev.txt"
      stamp_clone="$stamp_dir/$lib-gitclone-lastrun.txt"
      echo "creating stamps for $lib: $stamp_clone > $stamp_info"
      # mkdir $(dirname ..) to handle the case where `$rev` contains slashes
      mkdir -p $(dirname "$stamp_info")
      # koreader-base decides whether to redo the git checkout based on a timestamp compare of these two stamp files
      touch -d "last week" $(dirname "$stamp_info")  #< XXX: necessary?
      touch -d "last week" "$stamp_info"
      touch -d "next week" "$stamp_clone"

      # koreader would copy the checkout into this build/working directory,
      # but because we spoof the stamps to work around other git errors,
      # copy it there on koreader's behalf
      prefix="$build_dir/$lib-prefix"
      mkdir -p "$prefix/src"
      cp -R "$lib_src" "$prefix/src/$lib"
      # src dir needs to be writable for koreader to apply its own patches
      chmod u+w -R "$prefix/src/$lib"

      if [ -n "$prebuilt" ]; then
        abs_build_dir="$(realpath "$build_dir")"
        sed -i 's/INSTALL_COMMAND .*/INSTALL_COMMAND ""/' "$cmake_lists"
        sed -i \
          "s:BUILD_COMMAND .*:BUILD_COMMAND ${fakeBuildDep} $lib $abs_build_dir $prebuilt:" \
          "$cmake_lists"
      fi
    }

    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList
      (name: src:
        let
          # for machine-agnostic libraries (e.g. pure lua), koreader doesn't build them in a flavored directory
          machine = if src.machineAgnostic or false then "" else stdenv.hostPlatform.config;
        in
          ''link_lib_into_build_dir "${name}" "${src.source.rev}" "${machine}" "${src.package or ""}"''
      )
      sources.thirdparty
    )}

    # outDir should match OUTPUT_DIR in koreader-base
    outDir="/build/koreader/base/build/${stdenv.hostPlatform.config}"
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
    inherit luajit52 luaEnv;
  };

  meta = with lib; {
    homepage = "https://github.com/koreader/koreader";
    description =
      "An ebook reader application supporting PDF, DjVu, EPUB, FB2 and many more formats, running on Cervantes, Kindle, Kobo, PocketBook and Android devices";
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ colinsane contrun neonfuz];
  };
}
