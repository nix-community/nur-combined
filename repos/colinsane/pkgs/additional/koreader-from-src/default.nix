{ lib
, autoPatchelfHook
, autoconf
, automake
, buildPackages
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
, SDL2
, stdenv
, substituteAll
, which
}:
let
  sources = import ./sources.nix;
  version = "2023.10";
  src = fetchFromGitHub {
    owner = "koreader";
    repo = "koreader";
    name = "koreader";  # needed because `srcs = ` in the outer derivation is a list
    fetchSubmodules = true;
    rev = "v${version}";
    hash = "sha256-J8WNSkhPO0Y+m/h246w1GpowOVROOHVbmuDHFAniItk=";
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
      pname = "luajson";
      version = "1.3.4-1";
      src = fetchgit {
        url = "https://github.com/harningt/luajson.git";
        rev = "1.3.4";
        hash = "sha256-JaJsjN5Gp+8qswfzl5XbHRQMfaCAJpWDWj9DYWJ0gEI=";
      };
      knownRockspec = (fetchurl {
        url = "mirror://luarocks/luajson-1.3.4-1.rockspec";
        hash = "sha256-+S4gfa6QaOMmOCDX8TxBq3kFWlbaEeiSMxCfefYakv0=";
      }).outPath;
      propagatedBuildInputs = [ lpeg ];
    })
  ]);
  crossTargets = {
    # koreader-base Makefile targets to use when compiling for the given host platform
    # only used when cross compiling
    aarch64 = "debian-arm64";
  };
  target = if stdenv.buildPlatform == stdenv.hostPlatform then
    "debian"
  else
    crossTargets."${stdenv.hostPlatform.parsed.cpu.name}";
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
    ./lua-Spore-no-luajson.patch  #< TODO: test this at runtime! we ship luajson, but just don't expose it via luarocks...
    (substituteAll (
      {
        src = ./vendor-external-projects.patch;
      } // (lib.mapAttrs
        (_proj: source: fetchurl source)
        sources.externalProjects
      )
    ))
    ./rss-no-interrupt-on-image-failure.patch  # just a preference
  ];

  sourceRoot = "koreader";

  nativeBuildInputs = [
    buildPackages.stdenv.cc  # TODO: move to depsBuildBuild?
    autoconf  # autotools is used by some thirdparty libraries
    automake
    autoPatchelfHook  # TODO: needed?
    cmake  # for koreader/base submodule
    dpkg
    gettext
    git
    libtool
    makeWrapper
    perl  # TODO: openssl might try to take a runtime dep on this; see nixpkg
    pkg-config
    python3
    ragel
    which
    # luajit_lua52.pkgs.luarocks
    luaEnv.pkgs.luarocks
  ];
  buildInputs = [
    # luajson
    luaEnv
  ];

  postPatch =
  let
    env = "${buildPackages.coreutils}/bin/env";
  in ''
    substituteInPlace ../openssl/config --replace '/usr/bin/env' '${env}'
    substituteInPlace ../openssl/Configure --replace '/usr/bin/env' '${env}'

    chmod +x ../glib/gio/gio-querymodules-wrapper.py
    chmod +x ../glib/gio/tests/gengiotypefuncs.py
    chmod +x ../glib/gobject/tests/taptestrunner.py
    # need directory write perm in order to patchShebangs
    chmod u+w ../glib/{gio,gio/tests,glib,gobject/tests,tests}

    patchShebangs ../glib/gio/data-to-c.py
    patchShebangs ../glib/gio/gio-querymodules-wrapper.py
    patchShebangs ../glib/gio/tests/gengiotypefuncs.py
    patchShebangs ../glib/glib/update-gtranslit.py
    patchShebangs ../glib/gobject/tests/taptestrunner.py
    patchShebangs ../glib/tests/gen-casefold-txt.py
    patchShebangs ../glib/tests/gen-casemap-txt.py

    substituteInPlace ../glib/gio/gdbus-2.0/codegen/gdbus-codegen.in --replace '/usr/bin/env @PYTHON@' '@PYTHON@'
    substituteInPlace ../glib/glib/gtester-report.in --replace '/usr/bin/env @PYTHON@' '@PYTHON@'
    substituteInPlace ../glib/gobject/glib-genmarshal.in --replace '/usr/bin/env @PYTHON@' '@PYTHON@'
    substituteInPlace ../glib/gobject/glib-mkenums.in --replace '/usr/bin/env @PYTHON@' '@PYTHON@'

    substituteInPlace ../harfbuzz/autogen.sh --replace 'which pkg-config' 'which $PKG_CONFIG'
    substituteInPlace ../fribidi/autogen.sh --replace 'which pkg-config' 'which $PKG_CONFIG'

    substituteInPlace base/Makefile.defs --replace \
      'LUAROCKS_BINARY=luarocks' 'LUAROCKS_BINARY=${stdenv.hostPlatform.emulator buildPackages} ${luajit52}/bin/lua ${luaEnv.pkgs.luarocks}/bin/.luarocks-wrapped'
  '';

  dontConfigure = true;
  buildPhase = ''
    install_lib() {
      lib="$1"
      rev="$2"
      platform="$3"

      lib_src="../$lib"
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
    }

  '' + builtins.concatStringsSep "\n" (lib.mapAttrsToList
    (name: src:
      let
        # for machine-agnostic libraries (e.g. pure lua), koreader doesn't build them in a flavored directory
        machine = if src.machineAgnostic or false then "" else stdenv.hostPlatform.config;
      in
        ''install_lib "${name}" "${src.source.rev}" "${machine}"''
    )
    sources.thirdparty
  ) + ''

    make TARGET=${target} DEBIAN=1 SHELL=sh VERBOSE=1
  '';
  env = lib.optionalAttrs (stdenv.buildPlatform != stdenv.hostPlatform) {
    CHOST = stdenv.hostPlatform.config;
  };

  installPhase = ''
    make TARGET=${target} DEBIAN=1 debianupdate
    mv koreader-${target}-${stdenv.hostPlatform.config}/debian/usr $out

    wrapProgram $out/bin/koreader --prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [ SDL2 ]
    }
  '';
  # XXX: ^ don't specify INSTALL_DIR="$out" as make arg because that conflicts with vars used by third-party libs
  # might be safe to specify that as an env var, though?
  # XXX: nixpkgs adds glib and gtk3-x11 to LD_LIBRARY_PATH as well

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
