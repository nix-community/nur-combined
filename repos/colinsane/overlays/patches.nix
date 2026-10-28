# this file contains patches relevant to all build configurations, i.e. they fix issues common across:
# - native x86_64-linux-gnu compilation  (pkgs.${pkg})
# - native x86_64-linux-musl compilation (pkgsMusl.${pkg})
# - cross compilation (pkgsCross.aarch64-multiplatform.${pkg})
# - etc
#
# to patch issues _specific_ to one particular build configurations, consult one of these files instead:
# - overlays/gnu.nix
# - overlays/musl.nix
# - overlays/cross.nix
# - overlays/static.nix  (i.e. pkgsStatic.${pkg})
#
# before editing any of these files, first check if the fix already exists as an open PR against nixpkgs.
# if so, invoke `scripts/vendor-patch ${PR_URL_OR_COMMIT_HASH}` instead:
# this downloads the patch to pkgs/by-name/nixpkgs-bootstrap/patches, where it will take effect automatically.
#
# package overrides throughout this file are sorted alphabetically by attrname.
final: super:
let
  inherit (final) lib;
in
super.lib.composeManyExtensions [
# (_: prev: {
#   pkgsi686Linux = final.pkgsCross.gnu32;
# })
#
# (_: prev: super.lib.optionalAttrs (
#   prev.stdenv.buildPlatform.system == "x86_64-linux"
#   && prev.stdenv.hostPlatform.system == "x86_64-linux"
# ) {
#   pkgsi686Linux = let
#     # Bootstrap the VM runtime by cross compilation so it does not depend on
#     # the native i686 packages which it will build.
#     vmTools = final.pkgsCross.gnu32.vmTools.override {
#       kernel = final.pkgsCross.gnu32.linux.override {
#         structuredExtraConfig = {
#           TCP_AO = lib.mkForce lib.kernel.unset;
#           HIGHMEM4G = lib.mkForce lib.kernel.yes;
#           X86_PAE = lib.mkForce lib.kernel.yes;
#         };
#       };
#       # vmTools otherwise mounts /tmp as tmpfs even with a disk-backed root.
#       writeScript = name: text: final.buildPackages.writeScript name (lib.replaceStrings
#         [ ''mount -t tmpfs -o "mode=1777" none /fs/tmp'' ]
#         [ ''chmod 1777 /fs/tmp'' ]
#         text);
#       virtiofsd = final.buildPackages.virtiofsd;
#       customQemu = "${final.buildPackages.qemu}/bin/qemu-system-i386 -machine accel=kvm:tcg -cpu max";
#     };
#     # Some stdenv adapters apply mkDerivationFromStdenv more than once.
#     wrap = drv: if drv ? origBuilder then drv else (lib.overrideDerivation (vmTools.runInLinuxVM drv) (vm: {
#       # runInLinuxVM replaces env with QEMU_OPTS; retain package exports too.
#       env = (drv.env or {}) // vm.env;
#       # Schedule the launcher on the host, not on an external i686 builder.
#       system = prev.stdenv.buildPlatform.system;
#       # runInLinuxVM normally requires KVM; allow its TCG fallback here too.
#       requiredSystemFeatures = drv.requiredSystemFeatures or [];
#     })) // {
#       # Keep package overrides inside the VM rather than reverting to the native builder.
#       overrideAttrs = f: wrap (drv.overrideAttrs f);
#     };
#     wrapStdenv = config: stdenv: stdenv.override (old: let
#       mkDerivation = old.mkDerivationFromStdenv or (stdenv:
#         (import "${prev.path}/pkgs/stdenv/generic/make-derivation.nix" lib config stdenv).mkDerivation
#       );
#     in {
#       mkDerivationFromStdenv = stdenv: args: wrap (
#         (mkDerivation stdenv args).overrideAttrs (attrs: {
#           memSize = attrs.memSize or 8192;
#           # Toolchain builds and tests can fill a tmpfs root long before
#           # running out of address space. Give each guest a sparse ext4 disk.
#           mountDisk = "/dev/vda";
#           preVM = ''
#             diskImage="$PWD/root.img"
#             ${final.buildPackages.coreutils}/bin/truncate -s 32G "$diskImage"
#             ${final.buildPackages.e2fsprogs}/bin/mkfs.ext4 -q -F "$diskImage"
#           '' + (attrs.preVM or "") + ''
#             NIX_BUILD_CORES=2
#             echo 'export NIX_BUILD_CORES=2' >> xchg/saved-env
#           '';
#         })
#       );
#     });
#   in import prev.path {
#     localSystem = "i686-linux";
#     inherit (prev) config overlays;
#     # Wrap bootstrap stages too: running i686 tools directly on a 64-bit
#     # btrfs host can overflow their inode/stat interfaces.
#     stdenvStages = args: map (stage: previous: let
#       result = stage previous;
#     in result // lib.optionalAttrs (!(result.__raw or false) && result ? stdenv) {
#       stdenv = wrapStdenv args.config result.stdenv;
#     }) (import "${prev.path}/pkgs/stdenv" args);
#   };
# })
#
(_: prev: let
  maxVersion = 99;
  versions = super.lib.range 1 maxVersion;
  nodejsName = v: "nodejs-slim_${toString v}";
  nodejsOverrides = builtins.foldl' (acc: name: acc // {
    "${name}" = super."${name}".overrideAttrs (prevAttrs: {
      # XXX(2026-10-17): nodejs fails build at high core count
      # measurements:
      # - 256 cores: peak memory 220 GB above baseline, but then fails tests:
      #   > nodejs-slim> Failed tests:
      #   > nodejs-slim> out/Release/node --max_old_space_size=32 --expose_gc /build/node-v24.21.0/test/pummel/test-vm-memleak.js
      #   > nodejs-slim> out/Release/node --expose-gc /build/node-v24.21.0/test/sequential/test-gc-http-client-onerror.js
      # - 128 cores: peak memory ~150 GB above baseline (IIRC)
      preBuild = (prevAttrs.preBuild or "") + ''
        if (( NIX_BUILD_CORES > 128 )); then
          export NIX_BUILD_CORES=128
        fi
      '';
    });
  }) {} (map nodejsName versions);
in
  nodejsOverrides
)
(_: prev: let
  electronNames = map (v: "electron_${toString v}") (super.lib.range 1 99);
in
  builtins.foldl' (acc: name: acc // super.lib.optionalAttrs (prev ? "${name}") {
    "${name}" = prev.${name}.override {
      electron-unwrapped = prev.${name}.unwrapped.overrideAttrs (old: {
        # XXX(2026-10-24): build OOMs at high core count.
        # NIX_BUILD_CORES=32 alone is not enough: it exhausts 384 GB RAM + 384 GB zswap.
        # measurements for PYTHON_CPU_COUNT=NIX_BUILD_CORES=N:
        # - 128 cores: peak memory 230 GB above baseline, build takes 1200s.
        # - 64 cores: peak memory 120 GB above baseline, build takes 1900s.
        # measurements for NIX_BUILD_CORES=N, without setting PYTHON_CPU_COUNT:
        # - 128 cores: exhausts 384 GB RAM + 384 GB zswap. dies after 900s.
        # - 64 cores: exhausts 384 GB RAM + 384 GB zswap. dies after 800s.
        # - 32 cores: peak memory+zswap 580 GB above baseline, build takes 3400s.
        preBuild = ''
          if (( NIX_BUILD_CORES == 0 || NIX_BUILD_CORES > 128 )); then
            export NIX_BUILD_CORES=128
          fi
          export PYTHON_CPU_COUNT="$NIX_BUILD_CORES"
        '' + (old.preBuild or "");
      });
    };
  }) {} electronNames
)
(_: prev: let
  applyBeamPrefs = beam: lib.makeOverridable (args: let
    beam' = beam.override args;
  in beam' // {
    packages = lib.mapAttrs (erlangVer: erlangPkgs:
      if erlangVer == "erlang" then
        # `erlang` is an alias: skip it else we'd override it twice
        erlangPkgs
      else
        erlangPkgs.overrideScope (_: beamPrev: {
          rebar3 = beamPrev.rebar3.overrideAttrs (old: {
            # XXX(2026-10-22): Common Test is excessively slow on high-core-count builders.
            env = (old.env or {}) // {
              ERL_FLAGS = (old.env.ERL_FLAGS or "") + " +S 16:16";
            };
          });
        })
      ) beam'.packages
    ;
  }) {};
in
{
  beam = applyBeamPrefs prev.beam;
  beam_minimal = applyBeamPrefs prev.beam_minimal;
})
(_: prev: {
  # Preserve beam.override: reduce-closure overrides wxSupport in a later overlay.

  bind = prev.bind.overrideAttrs {
    # XXX(2026-10-11): isc_rwlock_benchmark fails for extremely high core count (512).
    # `nix-build -A bind --cores 32` still causes it to use 512 cores.
    doCheck = false;
  };

  # XXX(2026-10-02): gcc15 -> gcc16 upgrade detects more warnings than before; default -Werror flag breaks the build.
  # clightning = prev.clightning.overrideAttrs (prevAttrs: {
  #   env = prevAttrs.env // {
  #     NIX_CFLAGS_COMPILE = (prevAttrs.env.NIX_CFLAGS_COMPILE or "") + " -Wno-error=discarded-qualifiers";
  #   };
  # });

  # XXX(2026-10-22): ha-mcp depends on broken fastmcp-slim
  # fix borrowed from <https://github.com/NixOS/nixpkgs/pull/577124>
  ha-mcp = prev.ha-mcp.override {
    python3Packages = final.python3Packages.overrideScope (pyFinal: _pyPrev: {
      mcp = pyFinal.mcp_1;
    });
  };

  # XXX(2026-10-16): `nix-build -A haskell.compiler.ghc910` fails on high-core count machines.
  # the musl and gnu forms both fail, for different reasons; reducing core count solves both.
  # gnu fails early:
  # > Running phase: buildPhase
  # > hadrianFlags: --flavour=release+split_sections --bignum=gmp --docs=no-sphinx-pdfs --hash-unit-ids -j512
  # > /nix/store/rplwbx3hgs4wzc9hcs6r3cgp9r048fgl-stdenv-linux/setup: line 1775:  4318 Segmentation fault         (core dumped) hadrian "${hadrianFlags[@]}" binary-dist-dir
  # musl fails:
  # ghc-musl> Running phase: buildPhase
  # ghc-musl> hadrianFlags: --flavour=release+split_sections --bignum=gmp --docs=no-sphinx --hash-unit-ids -j512
  # ghc-musl> hadrian: out of memory
  # error: builder for '/nix/store/c2bng26g9wqb5prqvi4r8wxqj4liwkkl-ghc-musl-9.10.3.drv' failed with exit code 251;
  haskell = prev.haskell // {
    packageOverrides = lib.composeManyExtensions [
      prev.haskell.packageOverrides
      (_: hsuper: {
        # XXX(2026-10-17): fixes hang during checkPhase.
        fast-logger = final.haskell.lib.overrideCabal hsuper.fast-logger (old: {
          # one of the tests ("logOrdering"?) scales quadratically w.r.t. core count; hangs altogether (?) at 512 CPUs.
          # this change from the default -N (all CPUs) to -N2 keeps concurrency w/o scaling by CPU count (allegedly; per GPT 6.1-sol)
          testFlags = (old.testFlags or []) ++ [ "+RTS" "-N2" "-RTS" ];
        });
      })
    ];
    # compiler = lib.mapAttrs (pname: drv: if lib.hasPrefix "ghc9" pname then
    #   drv.overrideAttrs {
    #     NIX_BUILD_CORES = "8";
    #     # NIX_BUILD_CORES = "128";
    #   }
    # else
    #   drv
    # ) prev.haskell.compiler;
    compiler = prev.haskell.compiler // {
      ghc9103 = prev.haskell.compiler.ghc9103.overrideAttrs {
        # NIX_BUILD_CORES = "8";
        NIX_BUILD_CORES = "128";
      };
      ghc910 = prev.haskell.compiler.ghc910.overrideAttrs {
        # NIX_BUILD_CORES = "8";
        NIX_BUILD_CORES = "128";
      };
      # ghc984Binary = prev.haskell.compiler.ghc984Binary.overrideAttrs {
      #   # NIX_BUILD_CORES = "8";
      #   NIX_BUILD_CORES = "128";
      # };
    };
  };

  ispc = prev.ispc.overrideAttrs (prevAttrs: {
    patches = (prevAttrs.patches or []) ++ [
      (final.fetchpatch {
        # XXX(2026-10-18): fixes a hang in checkPhase
        # https://github.com/ispc/ispc/pull/3913
        name = "Fix-a-result-collection-race-that-can-hide-functional-test-failures";
        url = "https://github.com/ispc/ispc/commit/3cec0a7d793942ffc043a8064929d322072554c8.diff";
        hash = "sha256-keaWYCR9WKF5fYUqCZw6Tz8vMLAHUFQIgDapDQsY99Q=";
      })
    ];
  });

  # XXX(2026-10-24): `onetbb` hangs in checkPhase on highly parallel builder.
  # i *think* libblake3 is the only user on my system, so disable it there.
  # libblake3 = prev.libblake3.override {
  #   useTBB = false;
  # };

  # 2026-10-16: still required
  # XXX(2026-09-23): `python3Packages.pysaml2` fails build, takes down matrix-syanpse alongside it.
  matrix-synapse-unwrapped = prev.matrix-synapse-unwrapped.overridePythonAttrs (prevAttrs: {
    nativeCheckInputs = prev.lib.subtractLists prevAttrs.optional-dependencies.saml2 prevAttrs.nativeCheckInputs;
  });

  # XXX(2026-03-02): libvulkan_nouveau.so crashes on load, on flowy.
  # N.B.: solvable instead with `environment.sessionVariables.VK_LOADER_DRIVERS_DISABLE="*nouveau*";`
  # mesa = prev.mesa.override {
  #   # disabling nouveau gallium is probably unnecessary, just being proactive.
  #   # tegra depends on nouveau so disable that too.
  #   galliumDrivers = prev.lib.filter (d: d != "nouveau" && d != "tegra") prev.mesa.galliumDrivers;
  #   vulkanDrivers = prev.lib.remove "nouveau" prev.mesa.vulkanDrivers;
  # };

  # XXX(2026-02-27): nix-functional-tests is failing on only my machines.
  # - tried building on glibc nix, glibc lix, musl lix (flowy): all fail.
  # - verifed my nix store: it passed.
  # - not seen by other btrfs nix users.
  # - not seen by other ext4 nix users.
  # - localized entirely to my kitchen.
  # well, it's a feature i don't use, so disable the checks.
  # > 193/201 local-overlay-store - nix-functional-tests:stale-file-handle        FAIL            1.22s   exit status 1
  # nixVersions = prev.nixVersions.extend (_: nixSuper: {
  #   nixComponents_2_31 = nixSuper.nixComponents_2_31.overrideScope (_: _: {
  #     nix-functional-tests = null;
  #   });
  #   nixComponents_2_32 = nixSuper.nixComponents_2_32.overrideScope (_: _: {
  #     nix-functional-tests = null;
  #   });
  #   nixComponents_2_33 = nixSuper.nixComponents_2_33.overrideScope (_: _: {
  #     nix-functional-tests = null;
  #   });
  #   nixComponents_2_34 = nixSuper.nixComponents_2_34.overrideScope (_: _: {
  #     nix-functional-tests = null;
  #   });
  #   nixComponents_git = nixSuper.nixComponents_git.overrideScope (_: _: {
  #     nix-functional-tests = null;
  #   });
  # });

  # onetbb = prev.onetbb.overrideAttrs (prevAttrs: {
  #   # XXX(2026-10-24):  test_eh_algorithms takes exceptionally long on highly parallel builders.
  #   # onetbb>  20/140 Test  #20: test_eh_algorithms .......................   Passed  1074.95 sec
  #   # tests do not honor NIX_BUILD_CORES or `-j`: use cpu affinity to make them think they have only 8 cores.
  #   preCheck = (prevAttrs.preCheck or "") + ''
  #     onetbbAffinity=$(${final.buildPackages.util-linux}/bin/taskset -pc $$)
  #     onetbbAffinity=''${onetbbAffinity##*: }
  #     IFS=, read -ra onetbbRanges <<< "$onetbbAffinity"
  #     onetbbCPUs=()
  #     for range in "''${onetbbRanges[@]}"; do
  #       first=''${range%-*}
  #       last=''${range#*-}
  #       for (( cpu=first; cpu<=last && ''${#onetbbCPUs[@]}<8; cpu++ )); do
  #         onetbbCPUs+=("$cpu")
  #       done
  #       if (( ''${#onetbbCPUs[@]} == 8 )); then break; fi
  #     done
  #     ${final.buildPackages.util-linux}/bin/taskset -pc "$(IFS=,; echo "''${onetbbCPUs[*]}")" $$
  #   '';
  #   postCheck = ''
  #     ${final.buildPackages.util-linux}/bin/taskset -pc "$onetbbAffinity" $$
  #   '' + (prevAttrs.postCheck or "");
  # });

  openssl = prev.openssl.overrideAttrs (prevAttrs: {
    # 2026-10-23: on both GNU and musl, AF_ALG sockets exist on the build host,
    # but binding cbc(aes) fails with ENOENT without the required kernel crypto support.
    # Alpine also skips this kernel-dependent test; keep the engine enabled:
    # <https://gitlab.alpinelinux.org/alpine/aports/-/blob/a9ee19e3bec8d1ac288a0912f6c860b0000766fd/main/openssl/APKBUILD>
    checkFlags = (prevAttrs.checkFlags or []) ++ [ "TESTS=-test_afalg" ];
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyself: pysuper: {
      astropy = pysuper.astropy.overridePythonAttrs (prevAttrs: {
        patches = (prevAttrs.patches or []) ++ [
          (final.fetchpatch {
            # XXX(2026-10-26): some flake because one of the tests requires on a side-effect of another test, IIUC.
            # https://github.com/astropy/astropy/pull/20665
            url = "https://github.com/astropy/astropy/commit/fa785399f1582c1ad4d46beb5cefe413fb29d626.patch";
            hash = "sha256-z8uUDJoO5tzlXv2IEBeQUUyKMym4ujtC1YWb3A+GEfE=";
          })
        ];
      });

      dask = pysuper.dask.overridePythonAttrs (prevAttrs: {
        # XXX(2026-10-18): hundreds of pytest workers each create their own Dask pools,
        # exhausting resources on high-core-count builders.
        dontUsePytestXdist = true;
        preCheck = (prevAttrs.preCheck or "") + ''
          appendToVar pytestFlags "--numprocesses=$((NIX_BUILD_CORES > 8 ? 8 : NIX_BUILD_CORES))"
        '';
      });

      hypothesis = pysuper.hypothesis.overridePythonAttrs (prevAttrs: {
        # XXX(2026-10-18): keep charmap tests on one xdist worker: they
        # delete/rewrite a shared cache, racing in test_uses_cached_charmap.
        pytestFlags = (prevAttrs.pytestFlags or []) ++ [ "--dist=loadfile" ];
      });

      # mypy = pysuper.mypy.overridePythonAttrs (prevAttrs: {
      #   # XXX(2026-10-24): superseded by <https://github.com/NixOS/nixpkgs/pull/560110>
      #   # the removed patch is described as:
      #   # ```nix
      #   # # fix build w/ glibc-2.44
      #   # # If Python.h isn't included first, a const redefinition error now occurs otherwise.
      #   # (fetchpatch {
      #   #   url = "https://github.com/python/mypy/commit/46acbe85c0e1703ebf2e6d4c699772edcdcf4652.patch";
      #   #   hash = "sha256-KslHiKqinvvXZoxvCnZXOhCm7i8577PbSdNGudCsjZE=";
      #   # })
      #   # ```
      #   patches = lib.filter (patch: !(lib.versionAtLeast prevAttrs.version "2.3.1"
      #     && lib.hasSuffix "46acbe85c0e1703ebf2e6d4c699772edcdcf4652.patch" (toString patch)
      #   )) (prevAttrs.patches or []);
      # });

      narwhals = pysuper.narwhals.overridePythonAttrs (prevAttrs: {
        # XXX(2026-10-17): either hangs, or segfaults, during checkPhase, for high core count. i don't remember which.
        dontUsePytestXdist = true;
        preCheck = (prevAttrs.preCheck or "") + ''
          appendToVar pytestFlags "--numprocesses=$((NIX_BUILD_CORES > 8 ? 8 : NIX_BUILD_CORES))"
        '';
      });

      # 2026-10-03: still required
      torchaudio = pysuper.torchaudio.overridePythonAttrs {
        # XXX(2026-07-25): hangs around test/torchaudio_unittest/functional/torchscript_consistency_cuda_test.py
        doCheck = false;
      };
    })
  ];

  slurp = if lib.versionAtLeast prev.slurp.version "1.5.1" then
    lib.warnOnInstantiate "new slurp screenshotter may fail: test before committing" prev.slurp
  else
    prev.slurp
  ;
  # slurp = prev.slurp.overrideAttrs (upstream: {
  #   # 2026-01-27: disable the slurp-specific lockfile, as it reliably fails if WAYLAND_DISPLAY contains a `/`.
  #   # see: <https://github.com/emersion/slurp/issues/188>
  #   # (not sure why my screenshotter would need a lockfile??)
  #   postPatch = (upstream.postPatch or "") + ''
  #     substituteInPlace main.c --replace-fail \
  #       'acquire_lock()' 'true'
  #   '';
  # });

  xdg-dbus-proxy = prev.xdg-dbus-proxy.overrideAttrs (prevAttrs: {
    patches = prevAttrs.patches or [] ++ [
      # 2026-04-22: from checkraisefold to fix <https://github.com/flatpak/xdg-dbus-proxy/issues/67>
      # out for PR: <https://github.com/flatpak/xdg-dbus-proxy/pull/81>
      # but carried locally as the PR version does not cleanly apply to 0.1.9/later
      ./patches/xdg-dbus-proxy/monotonic-serial.patch
    ];
  });

  zoekt = prev.zoekt.overrideAttrs (prevAttrs: {
    # XXX(2026-10-13): TestServer_parallelism assumes 4 * GOMAXPROCS < 2048.
    # Limit test parallelism so it also passes on builders with >= 512 CPUs.
    preCheck = (prevAttrs.preCheck or "") + ''
      export GOMAXPROCS=16
    '';
  });
})
] final super
