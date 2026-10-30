{
  fetchurl,
  lib,
  musl,
  runCommandCC,
}:
let
  chimera = "https://raw.githubusercontent.com/chimera-linux/cports/c5ac74a45c801e4fd9748b21918b74067dc6fb24/main/musl";
  # TODO: use nixpkgs' own mimalloc, or at least `fetchFromGitHub`
  mimallocSrc = fetchurl {
    url = "https://github.com/microsoft/mimalloc/archive/refs/tags/v2.2.7.tar.gz";
    sha256 = "15ba8nnaq862ngvdlq5bah9aayxl92hfjj9fzxmjg0d60ycxh3lf";
  };
  unifiedSource = fetchurl {
    url = "${chimera}/files/mimalloc.c";
    sha256 = "1ky34l21scgps9b4v33d0s1sfxp6szr9pxbzb21jl8r1fw4932w5";
  };
  verifySymbols = fetchurl {
    # invoked by make; asserts that libc exports only the exact expected symbols (no mimalloc leakage)
    url = "${chimera}/files/mimalloc-verify-syms.sh";
    sha256 = "0nh49zlbx1i07hrmhcylkrvvygbsgjqkm6c93yq0s7i3kkxacf9z";
  };
  drv = musl.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "musl-mimalloc";

      patches = (prevAttrs.patches or [ ]) ++ [
        (fetchurl {
          # patches musl to support a generic `--with-malloc=external`
          url = "${chimera}/patches/0001-plumb-in-support-for-externally-provided-allocator-l.patch";
          sha256 = "11v1hxmwm5y5a7b8h06zks77asfr6jkajhv6khwzyfn935yga3l9";
        })
        (fetchurl {
          # patches mimalloc to declare its symbols `static`ally, so libc.a doesn't export them.
          # conditioned on `-DMI_LIBC_BUILD=1`. this was submitted upstream but they let it go stale
          url = "${chimera}/patches/0001-implement-necessary-bits-for-musl-integration.patch";
          sha256 = "0dvq3wb7j2324xxrckqff5b7c8jqllr649bay5qj3yv7yn6vfa9r";
        })
        (fetchurl {
          # patches mimalloc itself to correctly set `errno = EINVAL` and `ENOMEM` in its `return NULL` error paths.
          # this is maybe not 100% necessary, but without it some random downstream packages are reported to fail their tests.
          url = "${chimera}/patches/mimalloc-errno.patch";
          sha256 = "1ipfnk8g1xvh28hya5dk1n6xj7sqg3lyg9zsgq93mjlq3kpv9lvg";
        })
      ];

      postUnpack = (prevAttrs.postUnpack or "") + ''
        mkdir "$sourceRoot/mimalloc"
        tar xf ${mimallocSrc} --strip-components=1 -C "$sourceRoot/mimalloc"
        cp ${unifiedSource} "$sourceRoot/mimalloc/src/mimalloc.c"
        cp ${verifySymbols} "$sourceRoot/mimalloc-verify-syms.sh"
      '';

      postPatch = (prevAttrs.postPatch or "") + lib.optionalString musl.stdenv.cc.isGNU
      ''
        # Chimera's patch adds a redundant static variable; clang simply warns on this, GCC aborts
        # > In file included from ./mimalloc/src/static.c:32:
        # > ./mimalloc/src/os.c:735:1: error: duplicate 'static'
        # >   735 | static _Atomic(size_t) mi_numa_node_count; // = 0   // cache the node count
        # >       | ^~~~~~
        #
        # This substitution is safer than it looks: `mimalloc-verify-syms.sh` errors the build if we were to get it wrong.
        substituteInPlace mimalloc/src/os.c --replace-fail \
          $'#ifdef MI_LIBC_BUILD\nstatic\n#endif\nstatic _Atomic(size_t) mi_numa_node_count' \
          'static _Atomic(size_t) mi_numa_node_count'

        # `-print-resource-dir` seems to include c std headers only in clang; `-print-file-name=include` supports clang and gcc
        # > ./mimalloc/src/mimalloc.c:40:10: fatal error: stdatomic.h: No such file or directory
        # >    40 | #include <stdatomic.h>
        # >       |          ^~~~~~~~~~~~~
        substituteInPlace Makefile --replace-fail \
          '-isystem `$(CC) -print-resource-dir`/include' \
          '-isystem `$(CC) -print-file-name=include`'
      '';

      configureFlags = (prevAttrs.configureFlags or [ ]) ++ [
        # Chimera ships malloc/calloc/etc entrypoints in src/malloc/external
        # disable default `src/malloc/malloc-ng/*` entrypoints.
        # mimalloc/src/mimalloc.c provides __libc_malloc_impl (etc), which musl then dispatches `malloc` requests to instead
        # (via 0001-plumb-in-support-for-externally-provided-allocator-l.patch)
        "--with-malloc=external"
      ];
      makeFlags = (prevAttrs.makeFlags or [ ]) ++ [
        "EXTRA_OBJ=$(srcdir)/src/malloc/external/mimalloc.o"
      ];

      passthru = (prevAttrs.passthru or { }) // {
        inherit
          mimallocSrc
          unifiedSource
          verifySymbols
          ;
        # for downstream inspection, like `threadModel`
        allocatorModel = "mimalloc";

        tests = let
          checkFor = testName: { none ? [], some ? [] }:
            runCommandCC "musl-mimalloc-${testName}" {
              __structuredAttrs = true;
              EXPECT_NONE = none;
              EXPECT_SOME = some;
              EXPECT_NUM_CHECKED = 4 * (lib.length none + lib.length some);
            }
            ''
              set -euo pipefail
              num_checked=0
              not() {
                ! "$@"
              }
              checkPresence() {
                local maybeNot=$1
                local expr=$2
                local file=$3
                if ! $maybeNot grep -E "$expr" "$file"; then
                  cat "$file"
                  echo "match failed: $maybeNot grep -E $expr $file" 2>&1
                  exit 1
                fi
                num_checked=$((num_checked + 1))
              }

              for library in libc.{a,so}; do
                nm --defined-only "${musl}/lib/$library" > stock-symbols
                nm --defined-only "${finalAttrs.finalPackage}/lib/$library" > symbols
                for expr in "''${EXPECT_NONE[@]}"; do
                  checkPresence not "$expr" symbols
                  checkPresence "" "$expr" stock-symbols
                done
                for expr in "''${EXPECT_SOME[@]}"; do
                  checkPresence "" "$expr" symbols
                  checkPresence not "$expr" stock-symbols
                done
              done
              echo "num_checked: $num_checked"
              echo "expected:    $EXPECT_NUM_CHECKED"
              [[ "$num_checked" -eq "$EXPECT_NUM_CHECKED" ]] && touch $out
            '';
        in (prevAttrs.passthru.tests or { }) // {
          # a stock musl build would export:
          # malloc.lo:
          # 0000000000000000 T __libc_malloc_impl
          # 0000000000000000 T __malloc_alloc_meta
          # 0000000000000000 T __malloc_allzerop
          # 0000000000000000 T __malloc_atfork
          # 0000000000000000 B __malloc_lock
          # 0000000000000000 t alloc_slot
          # 0000000000000000 r med_cnt_tab
          # 0000000000000000 r small_cnt_tab
          no-sign-of-malloc-ng = checkFor "no-sign-of-malloc-ng" {
            none = [
              " __malloc_lock$"  #< the direct cause of perf issues in malloc-ng
              # "^malloc.lo:"  #< only present in libc.a
            ];
          };
          signs-of-mimalloc = checkFor "signs-of-mimalloc" {
            some = [ " _mi_heap_main$" ];
          };
        };
      };

      meta = prevAttrs.meta // {
        description = "Musl C library with Chimera Linux's hardened mimalloc integration";
        # Chimera's integration assumes lock-free 64-bit atomics: they fall back to mallocng on 32bit platforms.
        platforms = lib.filter (system: (lib.systems.elaborate system).is64bit) prevAttrs.meta.platforms;
      };
    }
  );
in
  # wrap in a "lazy derivation" to break out of common infinite recursion cases surrounding libc.
  # e.g. this allows for an overlay to set `musl = self.musl-mimalloc.override { musl = super.musl; }`.
  lib.lazyDerivation {
    derivation = drv;
    outputs = [
      # don't worry about drift: lazyDerivation enforces equality here
      "out"
      "bin"
      "dev"
      "debug"
    ];
    passthru = {
      inherit (drv)
        # src
        overrideAttrs
        passthru
        pname # convenience
        stdenv  # required by isBuiltByNixpkgsCompiler check (pkgs/stdenv/linux/default.nix)
        version  # required by versionOk check (pkgs/stdenv/linux/stage0.nix)
        # actual passthru attrs; try to keep in sync with the above drv.
        allocatorModel
        linuxHeaders  # nixpkgs internals access `stdenv.cc.libc.threadModel` directly, not `passthru.threadModel`
        tests
        threadModel  # nixpkgs internals access `libc.threadModel` directly, not `libc.passthru.threadModel`
        mimallocSrc
        unifiedSource
        verifySymbols
        ;
    };
  }
