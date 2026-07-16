# places to find musl patches:
# - <https://github.com/nixos/nixpkgs/pulls?q=label%3A%226.topic%3A+musl%22+>
# - <https://github.com/nixos/nixpkgs/pulls?q=pkgsMusl>
# - <https://github.com/nixos/nixpkgs/pulls?q=musl>
# - <https://github.com/MatthewCroughan/nixos-musl/blob/master/musl.nix>
# - <https://github.com/MatthewCroughan/nixos-musl/blob/master/musl-llvm.nix>
#
# - <https://wiki.gentoo.org/wiki/Musl_porting_notes#Patches_from_other_distros>
#
# - <https://gitlab.alpinelinux.org/alpine/aports>
# - <https://github.com/void-linux/void-packages>
# - <https://github.com/chimera-linux/cports>
final: super:
let
  inherit (final)
    applyPatches
    emptyDirectory
    fetchFromGitHub
    fetchpatch
    fetchPypi
    fetchurl
    lib
    overlays
    pkgs
    runCommand
    rustPlatform
    stdenv
    writeTextFile
  ;
  fetchAports = {
    path,
    rev ? "d802a8d44da2e309fe934d7d0fc54a558051b24c",  # 2026-03-01
    ...
  }@args: let
    args' = lib.removeAttrs args [ "path" "rev" ];
  in fetchpatch (args' // {
    # fetchpatch not fetchurl, to support args like `stripLen = 2;`
    url = "https://gitlab.alpinelinux.org/alpine/aports/-/raw/${rev}/${path}";
    # key the name by rev to help the url remain valid as i bulk upgrade
    name = "${rev}-${args'.name or path}";
  });
  fetchCports = {
    path,
    rev ? "a2ff12940763e924f4e93cf5aca3dcafccc0a493",
    ...
  }@args: let
    args' = lib.removeAttrs args [ "path" "rev" ];
  in fetchpatch (args' // {
    # fetchpatch not fetchurl, to support args like `stripLen = 2;`
    url = "https://raw.githubusercontent.com/chimera-linux/cports/${rev}/${path}";
    # key the name by rev to help the url remain valid as i bulk upgrade
    name = "${rev}-${args'.name or path}";
  });
  fetchVoid = {
    path,
    rev ? "ada2178075fdf3f270c6e924461eccecb809673b",  # 2026-03-01
    ...
  }@args: let
    args' = lib.removeAttrs args [ "path" "rev" ];
  in fetchpatch (args' // {
    # fetchpatch not fetchurl, to support args like `stripLen = 2;`
    url = "https://raw.githubusercontent.com/void-linux/void-packages/${rev}/${path}";
    # key the name by rev to help the url remain valid as i bulk upgrade
    name = "${rev}-${args'.name or path}";
  });
in
super.lib.composeManyExtensions [
  (_: prev: {
    # XXX(2026-01-20): some things (e.g. securityWrapper) build from pkgsStatic, for dubious reasons;
    # `pkgsMusl.pkgsStatic.stdenv` is broken so just redirect it to ordinary `pkgs`.
    # pkgsStatic = final.pkgs;
    #
    # XXX(2026-01-21): in fact some things *rely* on pkgsStatic being static, e.g. `lix` which needs a static, embeddable `busybox`.
    # so create a real + working pkgsStatic set, by recreating it with a gnu build machine.
    # 2026-04-30: still required
    pkgsStatic = import pkgs.path {
      overlays = [
        (self': super': {
          pkgsStatic = super';
        })
      ] ++ overlays;
      localSystem = {
        config = lib.systems.parse.tripleFromSystem (stdenv.buildPlatform.parsed // { abi.name = "gnu"; });
      };
      crossSystem = {
        isStatic = true;
        config = lib.systems.parse.tripleFromSystem (
          stdenv.hostPlatform.parsed
        );
        gcc = stdenv.hostPlatform.gcc or { };
      };
    };

    # exposed for debuggability.
    # some packages (e.g. glibc) don't cross compile _from_ musl,
    # but do compile in a glibc-native environment.
    # for that, define `_pkgsGnu` -- akin to `pkgsMusl`.
    # this could maybe be upstreamed.
    _pkgsGnu = import pkgs.path {
      overlays = [
        (self': super': {
          _pkgsGnu = super';
        })
      ] ++ overlays;
      localSystem = {
        config = lib.systems.parse.tripleFromSystem (stdenv.buildPlatform.parsed // { abi.name = "gnu"; });
      };
      crossSystem = {
        config = lib.systems.parse.tripleFromSystem (stdenv.hostPlatform.parsed // { abi.name = "gnu"; });
      };
    };
    # inherit (final._pkgsGnu)
    #   glibc  #< don't inherit this here: causes mass rebuild
    # ;

    # XXX(2026-02-02): a base musl system lacks /dev/input and wifi.
    # this is likely because systemd can't modprobe the appropriate modules.
    # > systemd-modules-load: Failed to initialize libkmod context: Not supported
    # > buffyboard: Can't open /dev/input: No such file or directory
    #
    # Matthew Croughan links this patch for fixing it:
    # - <https://inbox.vuxu.org/musl/20251017-dlopen-use-rpath-of-caller-dso-v1-1-46c69eda1473@iscas.ac.cn/>
    #
    # test before deploying, with:
    # > $ nix-build -A pkgsMusl.systemd
    # > $ ./result/lib/systemd/systemd-modules-load
    #
    # on success: "Module 'ctr' is built in"
    # on failure: "Failed to initialize libkmod context: Not supported"
    #
    # TODO: scope this down / simplify
    #
    # related/alternatives:
    # - <https://github.com/NixOS/nixpkgs/pull/475746>
    _pkgsSystemd = prev._pkgsSystemd or (import pkgs.path {
      overlays = [
        (final': prev': {
          _pkgsSystemd = prev';  #< prevents infinite recursion; avoid re-defining _pkgsSystemd if we're already inside it.
          musl = prev'.musl.overrideAttrs (upstream: {
            patches = (upstream.patches or []) ++ [
              (prev.fetchpatch {
                # <https://inbox.vuxu.org/musl/20251017-dlopen-use-rpath-of-caller-dso-v1-1-46c69eda1473@iscas.ac.cn/>
                # 2026-02-02: allegedly, fixes systemd/kmod, particularly:
                # > $ /nix/store/xxx-systemd-258.2/lib/systemd/systemd-modules-load
                # > Failed to initialize libkmod context: Not supported
                # see also:
                # - <https://github.com/NixOS/nixpkgs/pull/475746>
                name = "ldso: Use rpath of dso of caller in dlopen";
                url = "https://inbox.vuxu.org/musl/20251017-dlopen-use-rpath-of-caller-dso-v1-1-46c69eda1473@iscas.ac.cn/raw";
                hash = "sha256-ltg6Vt2EO8VDb/rMZlniPQNz2Kv4TXFOV+4xfnhJ1+Q=";
              })
            ];
          });
        })
      ] ++ overlays;
      localSystem = stdenv.buildPlatform;
      crossSystem = stdenv.hostPlatform;
    });

    inherit (final._pkgsSystemd) systemd;
    # _pkgsSystemd = prev.extend (final': prev': {
    #   # _pkgsSystemd = final';  #< prevents infinite recursion; avoid re-defining _pkgsSystemd if we're already inside it.
    #   # _pkgsSystemd = null;
    #   musl = prev'.musl.overrideAttrs (upstream: {
    #     patches = (upstream.patches or []) ++ [
    #       (prev.fetchpatch {
    #         # <https://inbox.vuxu.org/musl/20251017-dlopen-use-rpath-of-caller-dso-v1-1-46c69eda1473@iscas.ac.cn/>
    #         # 2026-02-02: allegedly, fixes systemd/kmod, particularly:
    #         # > $ /nix/store/xxx-systemd-258.2/lib/systemd/systemd-modules-load
    #         # > Failed to initialize libkmod context: Not supported
    #         # see also:
    #         # - <https://github.com/NixOS/nixpkgs/pull/475746>
    #         name = "ldso: Use rpath of dso of caller in dlopen";
    #         url = "https://inbox.vuxu.org/musl/20251017-dlopen-use-rpath-of-caller-dso-v1-1-46c69eda1473@iscas.ac.cn/raw";
    #         hash= "sha256-ltg6Vt2EO8VDb/rMZlniPQNz2Kv4TXFOV+4xfnhJ1+Q=";
    #       })
    #     ];
    #   });
    #   # systemd = prev.systemd; #< doesn't actually reduce rebuilds
    # });
    #
    # systemd = prev.systemd.override {
    #   # N.B.: this only needs to apply to `systemd` -- not `systemdMinimal` or `systemdLibs`.
    #   # we could use `pname == "systemd-minimal" to detect that, or `passthru.withKmod`, or `finalAttrs.mesonInstallTags == []`
    #   # to detect that, but i can't find a way to do that w/o infinite rec.
    #   stdenv = final._pkgsSystemd.stdenv;
    # };
    #vvv doesn't actually reduce rebuilds, hm.
    # systemdLibs = prev.systemdLibs;
    # systemdMinimal = prev.systemdMinimal;

    # XXX(2026-01-28): `pkgsMusl.glibc` fails build.
    # buildFHSEnv links in ld.so.conf, ld.so.cache, so let's provide it a real, non-cross glibc.
    # i could try patching this out later, but there's probably a lot more to do here first.
    # e.g. zoom still fails launch with:
    # > /opt/zoom/ZoomLauncher: /lib/libstdc++.so.6: no version information available (required by /opt/zoom/ZoomLauncher)
    # there's a good chance those _are_ needed -- but i could try patching it out later & seeing what works.
    # buildFHSEnvBubblewrap = prev.buildFHSEnvBubblewrap.override (
    # let
    #   limitedUseOfNativeGlibc = final.extend (self': super': {
    #     pkgs = super'.pkgs // {
    #       inherit (self'._pkgsGnu) glibc;
    #     };
    #   });
    # in {
    #   inherit (limitedUseOfNativeGlibc) callPackage;
    #   inherit (limitedUseOfNativeGlibc.pkgs) glibc;
    # });
    # XXX(2026-02-03): this fixes `pkgsMusl.zoom-us` to actually launch & join meetings and such.
    # it has no `musl` anywhere though -- it's ~identical to `_pkgsGnu.zoom-us` itself
    # buildFHSEnvBubblewrap = final._pkgsGnu.buildFHSEnvBubblewrap;

    # Alyssa Ross tried to upstream this earlier, stalled:
    # - <https://github.com/NixOS/nixpkgs/pull/379174>
    # accountsservice = prev.accountsservice.overrideAttrs (upstream: {
    #   patches = (upstream.patches or []) ++ [
    #     # 2026-01-28: doesn't apply cleanly...
    #     # (fetchurl {
    #     #   name = "daemon-use-portable-fgetspent";
    #     #   url = "https://gitlab.freedesktop.org/accountsservice/accountsservice/-/commit/995a036b7cff6329e2db30bf923c34b4eee40f77.patch?full_index=1";
    #     #   hash = "sha256-HeficBEf+TcdWUjFYl2SExue+lmZ5BS8u8+qy2jytik=";
    #     # })
    #     # 2026-01-28: causes other build failures...
    #     (fetchAports {
    #       path = "community/accountsservice/musl-fgetspent_r.patch";
    #       hash = "sha256-Zvl4H0jqA9yx3IazNPx4SsMEAheEDcxSYxTdIvtzX/g=";
    #     })
    #     (fetchAports {
    #       path = "community/accountsservice/musl-wtmp.patch";
    #       hash = "sha256-zWDcMFKu9M5NJBwvcGrQHP4EPoDZ0uD2CrNPAQZEK1k=";
    #     })
    #   ];
    # });

    # 2026-01-29: dante (SOCKS5 server/client) fails build, but the aerc build doesn't reference it --
    # it's wrapped onto PATH by nixpkgs. so hopefully aerc doesn't _truly_ need it.
    # 2026-03-22: aerc -> notmuch -> emacs -> mailutils fails build
    aerc = prev.aerc.override {
      # 2026-04-30: still required
      dante = null;
      # 2026-04-30: still required
      notmuch = prev.notmuch.override {
        withEmacs = false;
      };
    };

    apparmor-parser = prev.apparmor-parser.overrideAttrs (prevAttrs: {
      postPatch = prevAttrs.postPatch + ''
        # LLM claims:
        # > Fix musl strtol EINVAL behavior causing conditional expression test failures.
        # > musl sets errno=EINVAL for non-numeric input (POSIX-compliant), while
        # > glibc leaves errno=0. Don't treat EINVAL as fatal since non-numeric
        # > strings are already detected downstream via nullstr().
        substituteInPlace cond_expr.cc \
          --replace-fail 'if (errno == EINVAL)' 'if (0 && errno == EINVAL)'
      '';
    });

    # 2026-06-07: still required
    # 2026-02-14: upstream nixpkgs disables a few tests on aarch64, and a few more for any platform with S3 enabled.
    # alpine disables all python tests, and a few c++ tests:
    # > ctest -j2 --test-dir build-cpp -E "arrow-compute-scalar-temporal-test|arrow-orc-adapter-test|arrow-dataset-dataset-writer-test"
    # the following tests fail, perhaps legitimately, but let's just disable them to make progress.
    # - (GTEST)"TestStringKernels/0.StrptimeZoneOffset"
    # - (GTEST)"TestStringKernels/1.StrptimeZoneOffset"
    # - (GTEST)"TimestampConversion.UserDefinedParsersWithZone"
    # - (GTEST)"TimestampParser.StrptimeZoneOffset"
    # there also also some interrmittent failures (not disabled here), in e.g.:
    # - (ctest)"arrow-dataset-dataset-writer-test"
    arrow-cpp = prev.arrow-cpp.overrideAttrs (upstream: {
      # `--exclude-regex` excludes whole test _suites_, whereas GTEST_FILTER is more targeted
      # installCheckPhase = let
      #   re = lib.concatStringsSep "|" [
      #     "arrow-compute-scalar-type-test"
      #     "arrow-orc-adapter-test"
      #     "arrow-dataset-dataset-writer-test"
      #     "arrow-compute-scalar-type-test"
      #     "arrow-utility-test"
      #     "arrow-csv-test"
      #   ];
      # in lib.replaceStrings
      #   [ "ctest -L unittest --exclude-regex '^(" ]
      #   [ "ctest -L unittest --exclude-regex '^(${re}|" ]
      #   upstream.installCheckPhase;
      env = upstream.env // {
        GTEST_FILTER = lib.concatStringsSep ":" (lib.optionals (upstream.env ? GTEST_FILTER) [
          upstream.env.GTEST_FILTER
        ] ++ [
          "TestStringKernels/0.StrptimeZoneOffset"
          "TestStringKernels/1.StrptimeZoneOffset"
          "TimestampConversion.UserDefinedParsersWithZone"
          "TimestampParser.StrptimeZoneOffset"
        ]);
      };
    });

    # 2026-06-07: still required
    audacity = prev.audacity.overrideAttrs (upstream: {
      # 2026-02-16: fixes "/build/source/libraries/lib-sqlite-helpers/sqlite/Statement.h:55:4: error: ‘int64_t’ does not name a type"
      patches = (upstream.patches or []) ++ [
        (fetchAports {
          path = "community/audacity/add-cstdint.patch";
          hash = "sha256-OoUI7L1L8N//tTzGWe2Xl5Cr3qx4eHjm9JyRBxAro5s=";
        })
      ];
    });

    # chromium = prev.chromium.override {
    #   # chromium (used by e.g. electron) sandboxes itself but with special access to gconv & glibcLocales.
    #   # neither of those are used on musl: patch them out to avoid broken dep on glibc
    #   # this alone isn't enough to fix the build
    #   newScope = f: final.newScope (f // {
    #     glibc = emptyDirectory;
    #   });
    # };

    # 2026-04-30: still required
    claude-code = final._pkgsGnu.claude-code;
    # claude-code = (prev.claude-code.override {
    #   # autoPatchelfHook = null;
    # }).overrideAttrs {
    #   doInstallCheck = false;
    #   buildInputs = [
    #     final._pkgsGnu.glibc
    #   ];
    # };

    # 2026-01-29: tried, but could not fix build
    # dante = prev.dante.overrideAttrs (upstream: {
    #   patches = (upstream.patches or []) ++ [
    #     # > Rbindresvport.c:75:14: error: implicit declaration of function 'bindresvport'; did you mean 'Rbindresvport'? [-Wimplicit-function-declaration]
    #     # >    75 |       return bindresvport(s, _sin);
    #     # >       |              ^~~~~~~~~~~~
    #     # >       |              Rbindresvport
    #     (fetchAports {
    #       path = "community/dante/dante-no-bindresvport.patch";
    #       hash = "sha256-sS7fOPIe4FO3NTcnV2uKv2oGUKzIFXxTpQ5wh+o5F50=";
    #     })
    #   ];

    #   # intentionally wipe the upstream configureFlags, which hardcodes `libc.so.6`
    #   configureFlags = [
    #     "ac_cv_func_sched_setscheduler=no"
    #   ];
    # });

    # no hope of discord running natively on musl:
    # <https://github.com/void-linux/void-packages/issues/35132>
    discord = final._pkgsGnu.discord;

    # electron = prev.electron.override {
    #   electron-unwrapped = prev.electron.unwrapped.overrideAttrs (base: {
    #     preConfigure = (base.preConfigure or "") + ''
    #       set -x
    #     '';
    #   });
    # };

    # electron = prev.electron.overrideAttrs (base: {
    #   preConfigure = (base.preConfigure or "") + ''
    #     set -x
    #   '';
    #   # postConfigure = ''
    #   #   set -x
    #   # '' + (base.postConfigure or "");
    # });

    # 2026-04-30: still required
    # 2026-01-20: knot-dns -> xdp-tools -> emacs-nox -> mailutils.
    # mailutils fails to build, non-trivial to fix; hopefully disabling it here doesn't lose anything.
    # emacs-nox = prev.emacs-nox.override {
    #   withMailutils = false;
    # };

    # 2026-05-23: still required
    ffmpeg_7 = prev.ffmpeg_7.overrideAttrs {
      # 2026-02-03: two tests fail: tests/data/hls-list.append.m3u8, tests/data/hls-list.m3u8
      # Alpine disables check because "tests/data/hls-lists.append.m3u8 [sic] fails".
      # only applies to ffmpeg_7: nix ffmpeg (8) builds fine.
      doCheck = false;
    };

    # 2026-06-07: still required
    # 2026-01-28: disable malcontent to unblock flatpak: it's some "parental controls" thing?
    # flatpak -> malcontent -> accountsservice (broken).
    flatpak = prev.flatpak.override {
      withMalcontent = false;
    };

    firefox-unwrapped = (prev.firefox-unwrapped.override {
      # nothing wrong with lto/pgo, except that it's slow to build/iterate
      ltoSupport = false;
      pgoSupport = false;
    }).overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        # (fetchVoid {
        #   # 2026-03-01: fixes "/build/firefox-148.0/dom/media/webrtc/libwebrtc_overrides/call/call_basic_stats.h:17:24: error: unknown type name 'int64_t'"
        #   # 2026-03-01: fixes "/build/firefox-148.0/dom/media/webrtc/libwebrtc_overrides/call/call_basic_stats.cc:13:29: error: out-of-line definition of 'ToString' does not match any declaration in 'webrtc::CallBasicStats'"
        #   path = "srcpkgs/firefox/patches/firefox-148-webrtc-missing-includes.patch";
        #   hash = "sha256-kTuUPOutcNJwSAlAEmHXf8Jcm7UmbWmOAjQkiuG2IkI=";
        # })
        (fetchAports {
          # 2026-02-03: fixes "/build/firefox-147.0.2/objdir/dist/system_wrappers/sys/single_threaded.h:3:15: fatal error: 'sys/single_threaded.h' file not found"
          # 2026-06-07: still required
          path = "community/firefox/bmo-1988166-no-single_threaded-h.patch";
          hash = "sha256-oD/UdVfvOtY+HR5mLExf7ARQfvjpaMd2rOf0EBQ5TyM=";
        })
        (fetchAports {
          # 2026-02-03: fixes "/nix/store/hsvrmvp1i7k326fpvdrg99gmka863fwi-musl-1.2.5-dev/include/sys/prctl.h:88:8: error: redefinition of 'prctl_mm_map'"
          # 2026-06-07: still required
          path = "community/firefox/musl-no-linux-prctl.patch";
          hash = "sha256-Mwyvdqc//WvSn7HqbkCILipl2C9Qo0T3ZQWbYPtGK8A=";
        })

        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/big-endian-image-decoders.patch";
        #   hash = "sha256-UFjiDp/qqzpFQQijvSKiLgBbM0u9/b8FVcdtCGRR8L8=";
        # })
        # # (fetchVoid {
        # #   path = "srcpkgs/firefox/patches/clang-sysroot-toolchain-fix.patch";
        # #   hash = "sha256-rQZ7ZGsTj2FxEC/Onk1uvel5jTNNoTGHVwUEQFiTudI=";
        # # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/firefox-146-musl-linux-sys-prctl-conflict.patch";
        #   hash = "sha256-5nvz00l6cIOUjSx5GejbnCVwj6onC8mn9H4tST+uGc0=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/firefox-148-mach-clobber.patch";
        #   hash = "sha256-7P5AmL8CH/O2GmFjxy2roYpiUdH8wUPorB4ohWEN85Y=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/firefox-148-webrtc-missing-includes.patch";
        #   hash = "sha256-kTuUPOutcNJwSAlAEmHXf8Jcm7UmbWmOAjQkiuG2IkI=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/firefox-i686-build.patch";
        #   hash = "sha256-48zYfmK1PMVVXfzzidJjds/NmNf/YigL+VB4HHtLy1c=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/fix-arm-opus-include.patch";
        #   hash = "sha256-A0eEE71miasm+tXJxCS24RFVs6qRrE31xnsuRzgxJyQ=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/fix-i686-atomics.patch";
        #   hash = "sha256-h6UeEjqbXjdIfxaZtMWIz2jev3Huwd811HXTRVs/Dj8=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/fix-i686-build-moz-1792159.patch";
        #   hash = "sha256-NZhz1TPZSAuHCpYc9Wxxa+QAq4T6dyJofscmHoEF+KU=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/fix-i686-ppc-musl.patch";
        #   hash = "sha256-PV1MVSyzOZf0mQzdZzMPKWbhZgvI2PQmXsir27gFRiA=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/mallinfo.patch";
        #   hash = "sha256-TU3XWqb/dkN/P51LB9Ox/gnq9v/UI5o/lBIU4Fx5txQ=";
        # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/ppc32-fix-build.patch";
        #   hash = "sha256-qW/NulOuZfQvRbAC/TI2rJTnJuZX/ZTQ0WWjgwNYTIo=";
        # })
        # # (fetchVoid {
        # #   path = "srcpkgs/firefox/patches/rust-configure.patch";
        # #   hash = "sha256-5DPl0/dpyk7NDo0HwFoDZEfF361MorFhxfqNAGzYUUE=";
        # # })
        # # (fetchVoid {
        # #   path = "srcpkgs/firefox/patches/rust-lto-thin.patch";
        # #   hash = "sha256-scnfIrR8e2gez2JJYeFKwGfnGxR/3gmPyyY0/x5QK9A=";
        # # })
        # (fetchVoid {
        #   path = "srcpkgs/firefox/patches/sandbox-sched_setscheduler.patch";
        #   hash = "sha256-kvm2umjb1FKM2Dm9b5Mc5bcyqWDr41u8uR7f6gG0a5A=";
        # })


        # (fetchCports {
        #   path = "main/firefox/patches/atoi.patch";
        #   hash = "sha256-wddYZ2N+bODFeeBp9n0xeKPrwSr3RswDacLc1FzevYU=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/clang-ias.patch";
        #   hash = "sha256-x2moJRfabz/ZGGosVsGXp6kDbzC3kXIebGSUPbjwejc=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/clang-memory-throw-gcc.patch";
        #   hash = "sha256-3dPjEfGO/rg7UB6KhbiUqlfdNmoTUKRKJmLm4zt5UFY=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/depflags.patch";
        #   hash = "sha256-roAVTWAlMFtbW9X8EB0PDO8omzL6RSrB31yrzgBg2lo=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/enable-elfhack-relr.patch";
        #   hash = "sha256-jgUTzcUwzkX+fD5scQcgN+txhjWKIEEVjRnRfTGugKU=";
        # })
        # (fetchCports {
        #   # 2026-03-01: fixes "/build/firefox-148.0/objdir/dist/system_wrappers/sys/single_threaded.h:3:15: fatal error: 'sys/single_threaded.h' file not found"
        #   path = "main/firefox/patches/fix-fortify-system-wrappers.patch";
        #   hash = "sha256-MHNvWg9oAu8pSd09w8/Lfl5X0nMrt1r3/M8PUOQlFh8=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/fix-rust-target.patch";
        #   hash = "sha256-xSokjyVgPze3kx9zQyHMIKmFSM3e25qzE3DWkumxPts=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/fix-webrtc-pid_t.patch";
        #   hash = "sha256-j7ar/LsNAgJzFj8PDRky+iQDzvBwTfNhESPdv/CoIbc=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/google-sucks.patch";
        #   hash = "sha256-zvNZON13stAUKWtviDtJYCJJV44i4Rrw0sYiAyrdnps=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/lfs64.patch";
        #   hash = "sha256-CvmtbmslHAIZkXySOuEXeg+FAqfNUUoFY3wVQMaxDRc=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/libcxx18.patch";
        #   hash = "sha256-dtVs0lbQJEYUg0V6zvkmkN+cd1HNWrN3IKqk0g40TMM=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/loong0001-Enable-WebRTC-for-loongarch64.patch";
        #   hash = "sha256-5zJ51LOCKRjmSDdb9s3RFIVesGUrRozGCTcn4l+gFlw=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/loong0003-Define-HWCAP_LOONGARCH_LSX_and_LASX.patch";
        #   hash = "sha256-NNyLyGRUkEPYZmsaLg0M+n9dy18qfXi1uqed2/PKK4o=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/loong0004-Fix-ycbcr-chromium_types-warning.patch";
        #   hash = "sha256-BwT3y/5+YQ0VLR8gBb4TVaiNuJ3WiswuhLShfHDkGfU=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/loongarch-brotli-smallmodel.patch";
        #   hash = "sha256-9u+UWNLL84C77pAb6fPokP8+nbVUavg/3e3iLpXXg0A=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/musl-prctl.patch";
        #   hash = "sha256-5nvz00l6cIOUjSx5GejbnCVwj6onC8mn9H4tST+uGc0=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/no-ccache-stats.patch";
        #   hash = "sha256-24+F9bVaY0xdfSmk+WVrNPD5pSoyt5wT2r819Hbp7lY=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/pgo-notimeout.patch";
        #   hash = "sha256-ag3ai2JWA1WpqJwvPQZckjI3Gv1cX/D81RjvXTiASKQ=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/ppc64-webrtc.patch";
        #   hash = "sha256-cQ6nU6+XZEgda8aUM2Ya2ZCYEvvSidEgZQYl0nQteNw=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/riscv64-reduce-debug.patch";
        #   hash = "sha256-BxVo5HWAavX8YGQSHfqTqb6jHJjR91tkzOc87LlrSqg=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/rust-lto.patch";
        #   hash = "sha256-TowbZN2XVsdi5wVCZM4XMUJNn5ieZdQXqYrwA4dVIBM=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/sandbox-sched_setscheduler.patch";
        #   hash = "sha256-iIPpfpL8YerviYI3C71TCVwYdBI3gkhA+0iEsq/2gRI=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/sqlite-ppc.patch";
        #   hash = "sha256-sZeGybuD+t4HXAoVYNsUEtfgkbE8kzkmKUxBH7+0xng=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/wasip1.patch";
        #   hash = "sha256-bfoZoqG7QrmmrF7B7+8OM72aVK/nkWpxULY8W3O6XEg=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/x86_64-Fix-stack-alignment-in-breakpad_getcontext.S.patch";
        #   hash = "sha256-1aNX8pEY1cF7YvnQMSi3p2m7WFMLT3p5YMJXZeORoCE=";
        # })
        # (fetchCports {
        #   path = "main/firefox/patches/xptcall-integrated-as.patch";
        #   hash = "sha256-ZXAUHxqxXKRM0Hr7NWSScaotflpkFn7q4Au2Cf7fLZE=";
        # })

        # # (writeTextFile {
        # #   # this patch was an attempt to fix the following symptoms, but it doesn't:
        # #   # - immediately upon launch and until close, Firefox pegs 100% cpu while spamming the console:
        # #   #   > Sandbox: seccomp sandbox violation: pid 88, tid 113, syscall 23, args 20 140041528812544 140041528812672 140041528812800 0 0.
        # #   #
        # #   # `syscall 23` is `select`.
        # #   # it appears that for some reason, `__NR_select` was not being permitted inside the sandbox.
        # #   # it's unclear if either:
        # #   # A. `__NR_select` is forbidden in both glibc and musl builds, but only musl was making use of it (internally, presumably).
        # #   # B. `__NR_select` was allowed in glibc, but not allowed in musl build (due e.g. to some bug in the #ifdef's below).
        # #   #
        # #   # alternatives to this patch include:
        # #   # A. set `MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1` env var before launching firefox.
        # #   # B. set `security.sandbox.socket.process.level = 0` in `about:config`.
        # #   name = "sandbox-allow-select.patch";
        # #   text = ''
        # #     diff --git a/security/sandbox/linux/SandboxFilterUtil.h b/security/sandbox/linux/SandboxFilterUtil.h
        # #     index 3e07948c5ac0..34651602c7e7 100644
        # #     --- a/security/sandbox/linux/SandboxFilterUtil.h
        # #     +++ b/security/sandbox/linux/SandboxFilterUtil.h
        # #     @@ -182,27 +182,19 @@ class SandboxPolicyBase : public sandbox::bpf_dsl::Policy {
        # #      #  define CASES_FOR_clock_gettime case __NR_clock_gettime
        # #      #  define CASES_FOR_clock_getres case __NR_clock_getres
        # #      #  define CASES_FOR_clock_nanosleep case __NR_clock_nanosleep
        # #      #  define CASES_FOR_pselect6 case __NR_pselect6
        # #      #  define CASES_FOR_ppoll case __NR_ppoll
        # #      #  define CASES_FOR_futex case __NR_futex
        # #      #endif

        # #     -#if defined(__NR__newselect)
        # #     -#  define CASES_FOR_select \
        # #     -    case __NR__newselect:  \
        # #     -      CASES_FOR_pselect6
        # #     -#elif defined(__NR_select)
        # #      #  define CASES_FOR_select \
        # #          case __NR_select:      \
        # #            CASES_FOR_pselect6
        # #     -#else
        # #     -#  define CASES_FOR_select CASES_FOR_pselect6
        # #     -#endif

        # #      #ifdef __NR_poll
        # #      #  define CASES_FOR_poll \
        # #          case __NR_poll:      \
        # #            CASES_FOR_ppoll
        # #      #else
        # #      #  define CASES_FOR_poll CASES_FOR_ppoll
        # #      #endif
        # #   '';
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/abseil-cpp.patch";
        # #   hash = "sha256-frP7s/QxCiBtUcFS0OxH0BDGL7+5kFMaIfrz/Mezu+g=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/bmo-1952657-no-execinfo.patch";
        # #   hash = "sha256-qx+999tLg18LrWXoUQB9OiNBZLtiRshmQMmJ9l0BECc=";
        # # })
        # (fetchAports {
        #   # 2026-02-03: fixes "/build/firefox-147.0.2/objdir/dist/system_wrappers/sys/single_threaded.h:3:15: fatal error: 'sys/single_threaded.h' file not found"
        #   path = "community/firefox/bmo-1988166-no-single_threaded-h.patch";
        #   hash = "sha256-oD/UdVfvOtY+HR5mLExf7ARQfvjpaMd2rOf0EBQ5TyM=";
        # })
        # # (fetchAports {
        # #   path = "community/firefox/fix-fortify-system-wrappers.patch";
        # #   hash = "sha256-YK3ZDqftPeMLCW3PRlugN9EzeOaa0Cl787QeGbLKTEo=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/fix-lp64.patch";
        # #   hash = "sha256-apzFsdn0T4+FRmH/BO051Wm9kBTtWtDi9Vu/SRKTrzE=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/fix-rust-target.patch";
        # #   hash = "sha256-xFtUIfF+WCt0bXgT3VU5tuuOHHph6uuHGDwZpfcrfhs=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/lfs64.patch";
        # #   hash = "sha256-CvmtbmslHAIZkXySOuEXeg+FAqfNUUoFY3wVQMaxDRc=";
        # # })
        # (fetchAports {
        #   # 2026-02-03: fixes "/nix/store/hsvrmvp1i7k326fpvdrg99gmka863fwi-musl-1.2.5-dev/include/sys/prctl.h:88:8: error: redefinition of 'prctl_mm_map'"
        #   path = "community/firefox/musl-no-linux-prctl.patch";
        #   hash = "sha256-Mwyvdqc//WvSn7HqbkCILipl2C9Qo0T3ZQWbYPtGK8A=";
        # })
        # # (fetchAports {
        # #   path = "community/firefox/no-ccache-stats.patch";
        # #   hash = "sha256-24+F9bVaY0xdfSmk+WVrNPD5pSoyt5wT2r819Hbp7lY=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/rust-lto-thin.patch";
        # #   hash = "sha256-scnfIrR8e2gez2JJYeFKwGfnGxR/3gmPyyY0/x5QK9A=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/riscv64-no-lto.patch";
        # #   hash = "sha256-IZ4j3CHmGT6qiRZsnoKtqbUMzQ32kVJ/9VwTlUyrAHk=";
        # # })
        # # (fetchAports {
        # #   # 2026-02-03: this does NOT fix a runtime issue where Firefox spins one core immediately after launch, until closed
        # #   # > [88] Sandbox: Failed to report rejected syscall: EPIPE
        # #   # > [88] Sandbox: seccomp sandbox violation: pid 88, tid 113, syscall 23, args 20 140041528812544 140041528812672 140041528812800 0 0.
        # #   # see: <https://bugzilla.mozilla.org/show_bug.cgi?id=1657849>
        # #   path = "community/firefox/sandbox-sched_setscheduler.patch";
        # #   hash = "sha256-dq3QghmwMAPzdYDrNTff2J169ezQ/6OaKMMLKkq/aTQ=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/sqlite-ppc.patch";
        # #   hash = "sha256-MjjqgjExNlLJ7R8iCshy8qehbciSgF7KMgBx+SX70KE=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/widevine.patch";
        # #   hash = "sha256-UvH6OADowCZ9qaEsN32WS8ofjIHaNJSP+M5SCwAHDtg=";
        # # })
        # # (fetchAports {
        # #   path = "community/firefox/rust1.90-ppc.patch";
        # #   hash = "sha256-+/BVhHGNQrbptzMq7ae+OHvk5m+brPs2gqOos4rnjr8=";
        # # })
      ];
    });

    # 2026-05-23: still required
    # 2026-01-29: build fails against glycin 3.0.4
    # >    Compiling glycin v3.0.4
    # > error[E0425]: cannot find function `close_range` in crate `libc`
    # >    --> /build/cargo-deps-vendor/glycin-3.0.4/src/sandbox.rs:250:23
    # >     |
    # > 250 |                 libc::close_range(3, libc::c_uint::MAX, libc::CLOSE_RANGE_CLOEXEC as i32);
    # >     |                       ^^^^^^^^^^^ not found in `libc`
    # >
    # > For more information about this error, try `rustc --explain E0425`.
    # > error: could not compile `glycin` (lib) due to 1 previous error
    # > warning: build failed, waiting for other jobs to finish...
    # > FAILED: [code=101] src/fractal
    # > /nix/store/4lk00h8gz0qmlg6mf1hs1q8zbh95yn61-coreutils-9.9/bin/env CARGO_HOME=/build/source/build/cargo-home /nix/store/x22f9hd7qb1zpf44gl48ydg8invl2mbj-cargo-1.92.0/bin/cargo build --manifest-path /build/source/Cargo.toml --target-dir /build/source/build/cargo-target --release && cp /build/source/build/cargo-target/x86_64-unknown-linux-musl/release/fractal src/fractal
    # > ninja: build stopped: subcommand failed.
    # For full logs, run:
    #         nix log /nix/store/6a9l2n5kv5sbrafar1jljh4qs5xkq5xg-fractal-13.drv
    # fractal = prev.fractal.overrideAttrs (upstream: rec {
    #   patches = (upstream.patches or []) ++ [
    #     (fetchAports {
    #       path = "community/fractal/cargo-update-glycin.patch";
    #       hash = "sha256-qLPsV5lIJHK2BfUhajWB5sNbAXbQ8NVHKgKxx1cqDLc=";
    #     })
    #   ];
    #   cargoDeps = final.rustPlatform.fetchCargoVendor {
    #     inherit (upstream) src;
    #     inherit patches;
    #     hash = "sha256-W3fN4j408cPYfkn6oIPwD8E92CQ/GL2lZ9ygjg7tKJY=";
    #   };
    # });

    # 2026-05-23: still required
    # XXX(2026-01-29): taken from aports build flags; gcr probably has some conditional forward declaration of getpass?
    # > ../gcr/console-interaction.c: In function ‘console_interaction_ask_password’:
    # > ../gcr/console-interaction.c:100:11: error: implicit declaration of function ‘getpass’ [-Wimplicit-function-declaration]
    # >   100 |   value = getpass (prompt);
    gcr = prev.gcr.overrideAttrs (upstream: {
      NIX_CFLAGS_COMPILE = (upstream.NIX_CFLAGS_COMPILE or "") + " -D_BSD_SOURCE";
    });

    # 2026-05-23: still required
    gimp = prev.gimp.overrideAttrs (upstream: {
      # XXX(2026-02-15): build without a splash screen, else errors near end of build:
      # > FAILED: [code=245] gimp-data/images/gimp-splash.png
      #
      # this may be related to the errors recorded here:
      # - <https://github.com/NixOS/nixpkgs/pull/484971#issuecomment-3846759517>
      # > You have a writable data folder configured, but this folder is not part of your data search path.
      #
      # but figuring out where gimp's "data folder" is by tracing the source code, is nontrivial.
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace gimp-data/images/meson.build --replace-fail \
          'build_by_default: true' 'build_by_default: false'
      '';
      # nativeBuildInputs = upstream.nativeBuildInputs ++ [
      #   final.writableTmpDirAsHomeHook
      # ];
      # preBuild = (upstream.preBuild or "") + ''
      #   export XDG_CACHE_HOME=$TMPDIR/.cache
      # '';
      # env = (upstream.env or {}) // {
      #   # > Fontconfig error: Cannot load default config file: No such file: (null)
      #   # FONTCONFIG_FILE = "${final.fontconfig.out}/etc/fonts/fonts.conf";
      #   FONTCONFIG_FILE = final.makeFontsConf { fontDirectories = [ ]; };
      # };
    });

    # 2026-05-23: still required
    gmime3 = prev.gmime3.overrideAttrs {
      # alpine builds w/ tests disabled, since 2019.
      # see: <https://github.com/jstedfast/gmime/issues/63>
      doCheck = false;
    };

    # 2026-05-23: still required
    gparted = prev.gparted.override {
      # 2026-01-29: `gpart` (binary which is placed on runtime PATH) does not build for musl.
      # > In file included from gpart.h:23,
      # >                  from gm_hmlvm.c:20:
      # > l64seek.h:30:9: error: unknown type name ‘loff_t’; did you mean ‘off_t’?
      # >    30 | typedef loff_t off64_t;
      # >       |         ^~~~~~
      # >       |         off_t
      # musl appears to build without this, so it may just be not used.
      gpart = null;
    };

    gst_all_1 = prev.gst_all_1.overrideScope (_final': prev': {
      # 2026-05-23: still required
      # XXX(2026-01-28): ffv1 tests timeout. it's some new codec, just disable it.
      # <https://github.com/FFmpeg/FFV1>
      #
      # >      Running unittests src/lib.rs (build/target/x86_64-unknown-linux-musl/debug/deps/gstrswebrtc-1b727e3774204f81)
      # >
      # > running 3 tests
      # > test utils::tests::test_find_smallest_available_ext_id ... ok
      # > test utils::tests::test_deserialize_array ... ok
      # > test utils::tests::test_serialize_meta ... ok
      # >
      # > test result: ok. 3 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.01s
      # >
      # >      Running unittests src/lib.rs (build/target/x86_64-unknown-linux-musl/debug/deps/gstwebrtchttp-b761b0ba82ee0d97)
      # >
      # > running 0 tests
      # >
      # > test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
      # >
      # > Error: CliError { error: Some(1 target failed:
      # >     `-p gst-plugin-ffv1 --test ffv1dec`), exit_code: 101 }
      # >
      # > 1/1 tests FAIL           947.07s   exit status 1
      # >
      # >
      # > Summary of Failures:
      # >
      # > 1/1 tests FAIL           947.07s   exit status 1
      # >
      # > Ok:                0
      # > Fail:              1
      # >
      # > Full log written to /build/source/build/meson-logs/testlog.txt
      # For full logs, run:
      #        nix log /nix/store/jlj6sglablmw8i7n6xy7ypxflbrd9afq-gst-plugins-rs-0.14.4.drv
      # gst-plugins-rs = prev'.gst-plugins-rs.overrideAttrs {
      #   doCheck = false;
      # };
      gst-plugins-rs = prev'.gst-plugins-rs.override {
        plugins = lib.remove "ffv1" prev'.gst-plugins-rs.selectedPlugins;
      };
    });

    # 2026-04-30: still required; **partial fix** out for PR: <https://github.com/NixOS/nixpkgs/pull/515642>
    # hare = prev.hare.override {
    #   # hare-wrapper -> hare-hook attempts to build gnu toolchains
    #   # (pkgsCross.gnu64, pkgsCross.aarch64-multiplatform, pkgsCross.riscv64).
    #   # but glibc doesn't build with musl, so these fail.
    #   enableCrossCompilation = false;
    # };

    # 2026-04-30: still required
    # 2026-01-27: fails hyprland -> hyprcursor -> tomlplusplus (locale tests fail)
    # only `nwg-panel` uses hyprland; `null`ing it seems to Just Work.
    hyprland = null;

    # 2026-05-23: still required
    # 2026-01-25: fails building a test, so disable that test. probably not suitable for upstream.
    ldb = prev.ldb.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (fetchAports {
          path = "main/samba/disable-compile-error-test.patch";
          hash = "sha256-HB2/z4g+pBVcCEgyaYDXnahR89STALLbgFsDujegpY8=";
          stripLen = 2;
        })
      ];
    });

    # level-zero = prev.level-zero.overrideAttrs (upstream: {
    #   # `strerror_r` has a gnu and non-gnu variant -- patch to not use the gnu variant
    #   # > /build/source/source/utils/ze_logger.cpp:117:36: error: invalid conversion from ‘int’ to ‘const char*’ [-Werror=permissive]
    #   # >   117 |     const char *result = strerror_r(err, buf, sizeof(buf));
    #   postPatch = (upstream.postPatch or "") + ''
    #     substituteInPlace source/utils/ze_logger.cpp --replace-fail \
    #       'const char *result = strerror_r(err, buf, sizeof(buf));' \
    #       'strerror_r(err, buf, sizeof(buf)); const char *result = buf;'
    #   '';
    #   # patches = (upstream.patches or []) ++ [
    #   #   (fetchAports {
    #   #     path = "community/level-zero/xla-missing-include.patch";
    #   #     hash = "sha256-NvV5vpyE78ysQxqIYAISx3G8XV3r3gsh2ZXKa27XBxQ=";
    #   #   })
    #   # ];
    # });

    # 2026-05-23: still required
    # XXX(2026-01-29): one of the tests fail; alpine builds without tests claiming
    # "probably fpmath=sse related failures"
    # > [  FAILED  ] LineTest.CoincidingIntersect
    lib2geom = prev.lib2geom.overrideAttrs {
      doCheck = false;
    };

    # 2026-05-23: still required
    # 2026-01-29: fails tests
    # > # Begin functests/test_walkone.sh
    # > # PLATFORM=linuxlike
    # > libfaketime: In parse_ft_string(), failed to parse FAKETIME timestamp.
    # > Please check specification 1 with format %s
    # > out=1  expected=(secs since Epoch) - bad
    #
    # aports uses 0.9.12, nixpkgs is on 0.9.11.
    # nixpkgs PR to update is stalled: <https://github.com/NixOS/nixpkgs/pull/414782>
    #
    # libfaketime is used by `unifont` when building; probably most of its use
    # is build time, so disabling check is reasonably safe.
    libfaketime = prev.libfaketime.overrideAttrs (upstream: rec {
      # version = "0.9.12";
      # src = fetchFromGitHub {
      #   owner = "wolfcw";
      #   repo = "libfaketime";
      #   tag = "v${version}";
      #   hash = "sha256-Hd59b7pc6GIDvRR6EEosr/f8sKuV2q7RU7gDSaGFp3Y=";
      # };

      # patches = (upstream.patches or []) ++ [
      #   (fetchAports {
      #     path = "community/libfaketime/time-t-32-bit.patch";
      #     hash = "sha256-1c8H0eqBv+4IsSULiVYnJubz+cwTYzr2MxsNHZaSyfY=";
      #   })
      # ];

      doCheck = false;
    });

    # 2026-05-23: still required (for `pkgsMusl.appstream`)
    # libfyaml = prev.libfyaml.overrideAttrs (prevAttrs: {
    #   patches = prevAttrs.patches or [] ++ [
    #     # 2026-04-26: required to fix `nix-build -A pkgsMusl.appstream`.
    #     # > /nix/store/0cqdpmg3w6z3ccc3x6zzm7dvfdzirlp1-binutils-2.46/bin/ld.bfd: cannot find none: Invalid argument
    #     # > /nix/store/0cqdpmg3w6z3ccc3x6zzm7dvfdzirlp1-binutils-2.46/bin/ld.bfd: cannot find required: Invalid argument
    #     (fetchurl {
    #       name = "dont-output-none-required-to-LIBM-if-no-linker-flags-needed-for-it";
    #       url = "https://github.com/pantoniou/libfyaml/commit/24b18e7363b336962fe160c1dc05ca57ba95783c.patch?full_index=1";
    #       hash = "sha256-QtGgcALHF7GnH3yJIgTrx+Rds0T+s/bJURoUDs0C8pk=";
    #     })
    #     (fetchurl {
    #       name = "configure.ac-Fix-stray-fi";
    #       url = "https://github.com/pantoniou/libfyaml/commit/9f2492ca27bb1fda64f2b12edc2da17406208b93.patch?full_index=1";
    #       hash = "sha256-WyjVQa+O2MXK1UVCTSxeCHmLecEcsD1xgb4CyOLg/bA=";
    #     })
    #   ];
    # });

    # lixPackageSets = prev.lixPackageSets.extend (self: super: {
    #   # makeLixScope = args: (super.makeLixScope args).overrideScope (self': super': {
    #   #   lix = super'.lix.overrideAttrs { doInstallCheck = false; };
    #   # });
    #   lix_2_94 = super.lix_2_94.overrideScope (self': super': {
    #     # XXX(2026-02-02): pkgsMusl.lixPackageSets.latest.lix just started failing installCheck?
    #     # > lix:installcheck / functional-gc-auto                                       FAIL
    #     # > lix:installcheck / functional-build                                         TIMEOUT
    #     # lix = super'.lix.overrideAttrs { doInstallCheck = false; };
    #     # boost = final.boost187;
    #     lix = lib.pipe super'.lix [
    #       (p: p.override {
    #         # XXX(2026-02-28): segfaults building docs.
    #         # i wonder how serious a failure that is...
    #         enableDocumentation = false;  #< this actually does fix the build
    #       })
    #       (p: p.overrideAttrs (prevAttrs: {
    #         # hack disable this test:
    #         # > 1/5 check - lix:libcmd-unit-tests   FAIL            0.02s   killed by signal 11 SIGSEGV
    #         # postPatch = (prevAttrs.postPatch or "") + ''
    #         #   substituteInPlace tests/unit/libcmd/args.cc \
    #         #     --replace-fail \
    #         #       'TEST(Arguments, lookupFileArg) {' \
    #         #       'TEST(Arguments, lookupFileArg) { return;'
    #         # '';
    #         doCheck = false;
    #         # mesonBuildType = "release";
    #         # mesonBuildType = "plain";
    #         # mesonBuildType = "debug";
    #         # mesonFlags = lib.remove "-Dinternal-api-docs=enabled" prevAttrs.mesonFlags;
    #         # mesonFlags = lib.remove "-Db_lto=true" prevAttrs.mesonFlags;
    #         # doInstallCheck = false;
    #         # hardeningDisable = [ "all" ];
    #       }))
    #     ];
    #   });
    # });

    # 2026-05-23: still required
    # XXX(2026-01-22): fix broken 0122 test:
    # > FAIL: test-0112.sh
    # > ==================
    # >
    # > Running test 112
    # > No error printed, but there should be one.
    # > FAIL test-0112.sh (exit status: 3)
    # patch to fix it has been merged upstream; cherry-picked in Alpine.
    logrotate = prev.logrotate.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (fetchurl {
          name = "test-avoid-locale-dependent-errno-string";
          url = "https://github.com/logrotate/logrotate/commit/04b21743980c4e236ca5e8de18173fbd3848573b.patch?full_index=1";
          hash = "sha256-S1G/uiBeUNp0CUWzT3vYWmwVhAklEcnLzgNdUeOd8LQ=";
        })
      ];
    });

    # 2026-04-30: still required
    # 2026-01-29: build fails against glycin 3.0.4
    # > error[E0425]: cannot find function `close_range` in crate `libc`
    # >    --> /build/loupe-deps-49.2-vendor/glycin-3.0.4/src/sandbox.rs:250:23
    # >     |
    # > 250 |                 libc::close_range(3, libc::c_uint::MAX, libc::CLOSE_RANGE_CLOEXEC as i32);
    # >     |                       ^^^^^^^^^^^ not found in `libc`
    # >
    # > For more information about this error, try `rustc --explain E0425`.
    # > error: could not compile `glycin` (lib) due to 1 previous error
    # loupe = prev.loupe.overrideAttrs (upstream: rec {
    #   patches = (upstream.patches or []) ++ [
    #     (fetchAports {
    #       path = "community/loupe/glycin-2.0.5.patch";
    #       hash = "sha256-XhsAZjU3LHdiQEYrCs7zsFVizOWYZIgrkfshl0EoOMA=";
    #     })
    #   ];
    #   cargoDeps = final.rustPlatform.fetchCargoVendor {
    #     inherit (upstream) src;
    #     inherit patches;
    #     hash = "sha256-ZTyLHfmMF8rMVT1RlZ2Nmgm4kPKYHdVqqshI/Fkj/f8=";
    #   };
    # });

    # mailutils = prev.mailutils.overrideAttrs (upstream: {
    #   # nativeCheckInputs = (upstream.nativeCheckInputs or []) ++ [
    #   #   final.coreutils
    #   # ];
    #   # enableParallelBuilding = false;
    #   # enableParallelChecking = false;
    #   doCheck = false;
    # });

    # 2026-05-23: still required
    mesa-demos = prev.mesa-demos.overrideAttrs (upstream: {
      # fixes:
      # > ../src/vulkan/wsi/wayland.c:217:13: error: ‘enter’ undeclared here (not in a function)
      # >   217 |    .enter = enter,
      patches = (prev.patches or []) ++ [
        (fetchAports {
          path = "community/mesa-demos/uint.patch";
          hash = "sha256-GWRGFOFGeKJXnSS27OMZYlEq53Q9Vx4bOmCo8RNvUJY=";
        })
      ];
    });

    # 2026-05-23: still required
    # 2026-04-13: fish fails checkPhase on musl, but neovim-unwrapped doesn't seem to actually need it?
    # neovim-unwrapped = prev.neovim-unwrapped.override {
    #   fish = null;
    # };

    # 2026-05-23: still required
    nfs-utils = (prev.nfs-utils.override {
      # 2026-04-30: still required, out for PR: <https://github.com/NixOS/nixpkgs/pull/515858>
      # TODO: figure out whether this is should be conditioned by musl, or universal.
      # actually, i believe this is incorrect. it will try to read /etc/rpc at   runtime,
      # which on exists via glibc.
      # libtirpc = prev.libtirpc.overrideAttrs (upstream: {
      #   configureFlags = (upstream.configureFlags or []) ++ [
      #     # --enable-rpcdb causes it to provide functions such as `getrpcbynumber`.
      #     # this function is normally provided by glibc.
      #     # this is required for downstream consumers, such as nfs-utils, rpcbind, who otherwise fail with e.g.
      #     # > configure: error: Neither getrpcbynumber_r nor getrpcbynumber are available
      #     "--enable-rpcdb"
      #   ];
      # });
    }).overrideAttrs (upstream: {
      # XXX(2026-02-15): intentionally overwriting nixpkgs' `patches`,
      # as they don't cleanly apply anymore.
      patches = [
        (fetchVoid {
          # 2026-04-07: still required
          path = "srcpkgs/nfs-utils/patches/musl-fix_long_unsigned_int.patch";
          hash = "sha256-wcQ2IRmlBP61qZVlXk6osi4UH8ETtjllVogPEaZNK9o=";
        })
        # (fetchVoid {
        #   path = "srcpkgs/nfs-utils/patches/musl-getservbyport.patch";
        #   hash = "sha256-qx/p8BwWTchAWCIJbWylaF3XZU8OTx7w98W2atsgcdk=";
        # })
        (writeTextFile {
          # 2026-04-07: still required
          name = "musl-includes.patch";
          text = ''
            missing include for basename(3)
            --- a/utils/nfsdctl/nfsdctl.c
            +++ b/utils/nfsdctl/nfsdctl.c
            @@ -19,6 +19,7 @@
             #include <sched.h>
             #include <sys/queue.h>
             #include <limits.h>
            +#include <libgen.h>

             #include <netlink/genl/family.h>
             #include <netlink/genl/ctrl.h>
          '';
        })
        (fetchpatch {
          # XXX(2026-04-07): required for version >= 2.9.1
          url = "https://marc.info/?l=linux-nfs&m=177557989913637&q=raw";
          name = "Add-include-string-h-to-fix-build-failure";
          hash = "sha256-5hwBMbAgESudUbivwXz0hYf2qPUgCvNtN3JZp2KN60o=";
        })
        # XXX(2026-02-15): musl-includes.patch is still needed, to fixing missing include for `basename`;
        # void's patch for 2.8.4 doesn't cleanly apply to 2.8.5.
        # (fetchVoid {
        #   path = "srcpkgs/nfs-utils/patches/musl-includes.patch";
        #   hash = "sha256-dZEafrXDZH/IPo1u7B65u01nwFMfcqSMnVyHAapexa8=";
        # })
      ];

      # version = "2.6.4";
      # src = fetchurl {
      #  url = "mirror://kernel/linux/utils/nfs-utils/${version}/nfs-utils-${version}.tar.xz";
      #  hash = "sha256-AbOw+5x9C7q/URTHNlQgMHSMeI7C/Zc0dEIB6bChEZ0=";
      # };

      # # buildInputs = upstream.buildInputs ++ [
      # #   final.tcp_wrappers
      # #   final.linuxHeaders
      # #   # > configure: error: Neither getrpcbynumber_r nor getrpcbynumber are available
      # #   # final.rpcbind
      # #   final.krb5.dev
      # # ];

      # configureFlags = upstream.configureFlags ++ [
      #   # "--without-gssglue"
      #   # "--enable-svcgss"
      #   "--with-tirpcinclude=${lib.getDev final.libtirpc}/include/tirpc"
      # ];

      # patches = [
      #   (fetchAports {
      #     path = "main/nfs-utils/musl-getservbyport.patch";
      #     hash = "sha256-DnqsCanMJM/4baIY4R8GY/DhQ8ikMBSISi1Y9FvSHLs=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/musl-svcgssd-sysconf.patch";
      #     hash = "sha256-5coE3aIGj5FtbCO4st0ybVtqp+xpWntUKv73S+X9EzY=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/musl-stat64.patch";
      #     hash = "sha256-mnnjgN9QqZV4bNVGNqBI8+tM5pIRUfeX/hnYVL6Zmb4=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/include-unistd.patch";
      #     hash = "sha256-+jRUyh0gDoBqzYRKU/yMlLsdvApi592YJTTrn9rIDBw=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/0001-gssd-revert-commit-a5f3b7ccb01c.patch";
      #     hash = "sha256-LH+YetG2J2zB9pon4fSUX8/TOUyIp6rt3O/4uWjkXR4=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/0002-gssd-revert-commit-513630d720bd.patch";
      #     hash = "sha256-9Tj0cNZXNepGyBqXX+MuSnIrv3egT64xmkBLMq7YUNo=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/0003-gssd-switch-to-using-rpc_gss_seccreate.patch";
      #     hash = "sha256-zcWqFbT4j2ZWM3sdKn2/Rr/s0BlxASMvofFr/5ixZi4=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/0004-gssd-handle-KRB5_AP_ERR_BAD_INTEGRITY-for-machine-cr.patch";
      #     hash = "sha256-bycKKtI3rTJlG8fA5ZJU2hAKjT7Ga1AvofPDg5rEnzg=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/0005-gssd-handle-KRB5_AP_ERR_BAD_INTEGRITY-for-user-crede.patch";
      #     hash = "sha256-YeL4sj+Usq/SfsVvS6nX+gJELTHeVrfCAszl17yPL+Q=";
      #   })
      #   (fetchAports {
      #     path = "main/nfs-utils/0006-configure-check-for-rpc_gss_seccreate.patch";
      #     hash = "sha256-CmcUXdIIqcB+MBwmx8FtddQvLtb9WIQnwMO42OSKHeQ=";
      #   })
      # ];
      # postPatch = (lib.replaceStrings
      #   [ "chmod 4711" ]
      #   [ "chmod 4511" ]
      #   upstream.postPatch);
      # prePatch = (upstream.prePatch or "") + ''
      #   substituteInPlace configure.ac --replace-fail \
      #     'AC_MSG_ERROR([Neither getrpcbynumber_r nor getrpcbynumber are available])' \
      #     'AC_MSG_WARN([Neither getrpcbynumber_r nor getrpcbynumber are available])'
      #   substituteInPlace configure --replace-fail \
      #     'as_fn_error $? "Neither getrpcbynumber_r nor getrpcbynumber are available"' \
      #     'as_fn_warn $? "Neither getrpcbynumber_r nor getrpcbynumber are available"'
      # '';

      # tried to build older nixpkgs src/patches, but this fails:
      # > configure: error: Neither getrpcbynumber_r nor getrpcbynumber are available
      # version = "2.7.1";
      # src = fetchurl {
      #  url = "mirror://kernel/linux/utils/nfs-utils/${version}/nfs-utils-${version}.tar.xz";
      #  hash = "sha256-iFyUioSli8pBSPRZWI+ac2nbtA3MRm8E5FXGsQ/Qqkg=";
      # };

      # patches = [
      #   (fetchVoid {
      #     rev = "bb636cdb1b274f44d92b1cb2fdf0dff6079f97aa";
      #     path = "srcpkgs/nfs-utils/patches/nfs-utils-2.7.1-define_macros_for_musl.patch";
      #     hash = "sha256-wsyioRjzs1PObMHwYgf5h/Ngv+s5MPsroAuUNGs9lR0=";
      #   })
      #   (fetchVoid {
      #     rev = "bb636cdb1b274f44d92b1cb2fdf0dff6079f97aa";
      #     path = "srcpkgs/nfs-utils/patches/musl-svcgssd-sysconf.patch";
      #     hash = "sha256-3TXgqswxlhFqXRPcjwo4MdqlTYl+dWVaa0E5r9Mnw18=";
      #   })
      #   (fetchVoid {
      #     rev = "bb636cdb1b274f44d92b1cb2fdf0dff6079f97aa";
      #     path = "srcpkgs/nfs-utils/patches/musl-fix_long_unsigned_int.patch";
      #     hash = "sha256-rS6sqqoGLIaPVq04+QiqP4qa88i1z4ZZCssM5k/XQ68=";
      #   })
      # ];

      # postPatch = lib.replaceStrings
      #   [ "chmod 4711" ]
      #   [ "chmod 4511" ]
      #   upstream.postPatch;

      # version = "2.8.4";
      # src = fetchurl {
      #   url = "mirror://kernel/linux/utils/nfs-utils/${version}/nfs-utils-${version}.tar.xz";
      #   hash = "sha256-EcTMWYpDTX00C60+Byo3O6HcwsSfhV1EsgIiK3js2/U=";
      # };
      # configureFlags = upstream.configureFlags ++ [
      #   "--without-tcp-wrappers"
      # ];
      # intentionally overwriting nixpkgs `patches` entry
      # patches = [
      #   (fetchVoid {
      #     path = "srcpkgs/nfs-utils/patches/musl-fix_long_unsigned_int.patch";
      #     hash = "sha256-wcQ2IRmlBP61qZVlXk6osi4UH8ETtjllVogPEaZNK9o=";
      #   })
      #   (fetchVoid {
      #     path = "srcpkgs/nfs-utils/patches/musl-getservbyport.patch";
      #     hash = "sha256-qx/p8BwWTchAWCIJbWylaF3XZU8OTx7w98W2atsgcdk=";
      #   })
      #   (fetchVoid {
      #     path = "srcpkgs/nfs-utils/patches/musl-includes.patch";
      #     hash = "sha256-dZEafrXDZH/IPo1u7B65u01nwFMfcqSMnVyHAapexa8=";
      #   })
      #   # http://openwall.com/lists/musl/2015/08/18/10
      #   # (fetchpatch {
      #   #   url = "https://raw.githubusercontent.com/alpinelinux/aports/cb880042d48d77af412d4688f24b8310ae44f55f/main/nfs-utils/musl-getservbyport.patch";
      #   #   sha256 = "1fqws9dz8n1d9a418c54r11y3w330qgy2652dpwcy96cm44sqyhf";
      #   # })
      #   # (fetchpatch {
      #   #   url = "https://github.com/void-linux/void-packages/raw/31f0d5fef2f74999212bcfa6f982969973432750/srcpkgs/nfs-utils/patches/musl-includes.patch";
      #   #   hash = "sha256-dZEafrXDZH/IPo1u7B65u01nwFMfcqSMnVyHAapexa8=";
      #   # })
      #   # (fetchpatch {
      #   #   url = "https://github.com/void-linux/void-packages/raw/31f0d5fef2f74999212bcfa6f982969973432750/srcpkgs/nfs-utils/patches/musl-fix_long_unsigned_int.pat  ch";
      #   #   hash = "sha256-wcQ2IRmlBP61qZVlXk6osi4UH8ETtjllVogPEaZNK9o=";
      #   # })
      # ];
    });

    # 2026-05-23: still required
    nmon = prev.nmon.overrideAttrs (upstream:
      # nmon is a single-file project,
      # compiled in nixpkgs in an extremely non-patchable manner.
      let
        patchedSrc = applyPatches {
          src = runCommand "nmon-src" { } ''
            mkdir $out
            cp ${upstream.src} $out/lmon.c
          '';

          patches = [
            (fetchAports {
              # 2026-01-24: fixes `fatal error: fstab.h: No such file or directory`.
              # fstab.h is a glibc-only thing; not present in musl.
              name = "glibc.patch";
              path = "community/nmon/glibc.patch";
              hash = "sha256-TQq/nyZOYKcLT5kOmzoBWNo3j8DvJY/umPDAL7eWilw=";
            })
          ];
        };
      in
      {
        buildPhase = lib.replaceStrings
          [ "${upstream.src}" ]
          [ "${patchedSrc}/lmon.c" ]
          upstream.buildPhase;
      }
    );

    onnxruntime = prev.onnxruntime.override {
      # XXX(2026-07-01): pkgsMusl.openvino doesn't compile
      openvinoSupport = false;
    };

    openscad-unstable = prev.openscad-unstable.overrideAttrs (prevAttrs: {
      disabledTests = prevAttrs.disabledTests ++ [
        # these might be legit test failures
        "echo_recursion-test-function3"
        "echo_recursion-test-module"
        "echo_recursion-test-vector"
      ];
    });

    # XXX(2026-07-01): level-zero does not compile, assumes too many gnu-specific features
    #                  openvino remains broken even without level-zero though.
    # openvino = prev.openvino.override {
    #   level-zero = null;
    # };

    # 2026-04-30: still required
    # pipewire = prev.pipewire.overrideAttrs {
    #   # 2026-02-19: fixes:
    #   # > In function ‘array_test’:
    #   # > cc1: note: source object is likely at address zero
    #   # > /nix/store/h7x66rfwc6alim5gz0s2zjpwgavlfrz9-fortify-headers-3.0.1/include/string.h:69:1: note: in a call to function ‘__orig_memmove’ declared with attribute ‘access (read_only, 2, 3)’
    #   # >    69 | _FORTIFY_FN(memmove) void *memmove(void * _FORTIFY_POS0 __d,
    #   # >       | ^~~~~~~~~~~
    #   hardeningDisable = [ "fortify" ];
    # };

    # 2026-06-22: playwright-driver.passthru.browsers would appear to be **vendored** browsers, hence glibc-only.
    playwright-driver = final._pkgsGnu.playwright-driver;
    playwright-test = final._pkgsGnu.playwright-test;

    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyself: pysuper: {
        # XXX(2026-06-22): "Expected 12 exit code, got 14 on test/fixtures/templates/quickstart/openshift.yaml"
        cfn-lint = pysuper.cfn-lint.overridePythonAttrs (prevAttrs: {
          disabledTests = prevAttrs.disabledTests ++ [
            "test_templates" # test_quickstart_templates and test_quickstart_templates_non_strict
            "test_module_integration" # test_quickstart_templates_non_strict
          ];
        });

        crawl4ai = (pysuper.crawl4ai.override {
          alphashape = null;
          shapely = null;
          # optional deps which don't build for musl
          sentence-transformers = null;
          tokenizers = null;
          torch = null;
          transformers = null;
        }).overridePythonAttrs (prevAttrs: {
          pythonRemoveDeps = prevAttrs.pythonRemoveDeps ++ [
            "alphashape"
            "shapely"
          ];
        });

        cyclopts = pysuper.cyclopts.override {
          # XXX(2026-06-22): nativeCheckInputs; optional dep.
          fish = null;
        };

        # XXX(2026-06-22): timezone tests fail
        django = pysuper.django.overridePythonAttrs {
          doCheck = false;
        };

        # alternatively: `fastmcp = pyself.fastmcp-slim`
        fastmcp = pysuper.fastmcp.overridePythonAttrs (prevAttrs: {
          # XXX(2026-06-22): "TestSupabaseProviderIntegration::test_unauthorized_access - RuntimeError: Server failed to start after 30 attempts"
          disabledTests = prevAttrs.disabledTests ++ [
            "test_unauthorized_access"
          ];

          # XXX(2026-07-01): some test hangs there's no way to know which one.
          doCheck = false;
        });

        # 2026-05-23: still required
        # XXX(2026-01-29): test_ellipse_arc fails, looks like a legitimate failure (numerical).
        # i use inkscape mostly at build time (for wallpapers), so just disable tests.
        inkex = pysuper.inkex.overridePythonAttrs {
          doCheck = false;
        };

        # 2026-05-23: still required
        netifaces = pysuper.netifaces.overrideAttrs (upstream: {
          patches = (upstream.patches or []) ++ [
            (fetchAports {
              path = "community/py3-netifaces/gcc14.patch";
              hash = "sha256-5p5pwpV1GSyPHN0aA1J8plyB/NvAHb9hqWlepY1Mqpk=";
            })
          ];
        });

        # 2026-07-01: torch is an optional dependency, but used unconditionally in `nativeCheckInputs`.
        pylance = pysuper.pylance.overridePythonAttrs (upstream: {
          nativeCheckInputs = (lib.remove pyself.torch upstream.nativeCheckInputs) ++ [
            pyself.psutil
          ];
          # optionalDependencies = [];
        });

        swagger-spec-validator = pysuper.swagger-spec-validator.overridePythonAttrs {
          # asserts on strerror strings?
          doCheck = false;
        };

        # 2026-05-23: still required
        twisted = pysuper.twisted.overrideAttrs (upstream: {
          # 2026-01-22: no explanation; alpine just hard-disables this hanging test, quite intrusively.
          # the test *does* seem to be flakey? but builds (eventually?) w/o this.
          # patches = (upstream.patches or []) ++ [
          #   (fetchAports {
          #     name = "hanging-test.patch";
          #     path = "community/py3-twisted/hanging-test.patch";
          #     hash = "sha256-iMawFI5ydLZbgGBG6bAQCYNtd0lG8GlfG9VxemVuVPw=";
          #   })
          # ];

          # patch over nixpkgs own faulty patch. it assumes libc.so exists at:
          # "${stdenv.cc.libc}/lib/libc.so.6"
          # but that's only true for glibc.
          postPatch = upstream.postPatch + ''
            substituteInPlace src/twisted/python/_inotify.py --replace-fail \
              "'${stdenv.cc.libc}/lib/libc.so.6'" \
              "'${stdenv.cc.libc}/lib/libc.so'"
            # nixpkgs patched _inotify.py, but not _posixifaces.py -- also used by tests
            substituteInPlace src/twisted/internet/test/_posixifaces.py --replace-fail \
                "find_library(\"c\") or \"\"" "'${stdenv.cc.libc}/lib/libc.so'"
          '';
        });
      })
    ];

    # 2026-05-23: still required
    rpm = prev.rpm.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (fetchAports {
          # fixes "/build/rpm-4.20.1/rpmio/rpmglob.c:84:15: error: ‘GLOB_BRACE’ undeclared (first use in this function); did you mean ‘GLOB_NOSPACE’?"
          # upstream tracking issue (stalled): <https://github.com/rpm-software-management/rpm/issues/2844>
          path = "community/rpm/fix-glibc-glob.patch";
          hash = "sha256-ycclRqEWohv+Ur0gJjdTXb46GHnGc0ybwhIILE/j7kE=";
        })
      ];
    });

    # 2026-05-23: still required
    # XXX(2026-01-28): check fails with:
    # > Running phase: checkPhase
    # > check flags: -j24 test
    # > [0/1] Running tests...
    # > Test project /build/source/build
    # >       Start  1: testatomic
    # >       Start  2: testerror
    # >       Start  3: testevdev
    # >       Start  4: testfile
    # >       Start  5: testfilesystem
    # >       Start  6: testlocale
    # >       Start  7: testplatform
    # >       Start  8: testpower
    # >       Start  9: testqsort
    # >       Start 10: testthread
    # >       Start 11: testtimer
    # >       Start 12: testver
    # >       Start 13: testautomation
    # >  1/13 Test  #1: testatomic .......................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  2/13 Test  #2: testerror ........................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  3/13 Test  #3: testevdev ........................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  4/13 Test  #4: testfile .........................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  5/13 Test  #5: testfilesystem ...................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  6/13 Test  #6: testlocale .......................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  7/13 Test  #7: testplatform .....................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  8/13 Test  #8: testpower ........................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # >  9/13 Test  #9: testqsort ........................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # > 10/13 Test #10: testthread .......................Subprocess aborted***Exception:   0.01 sec
    # > Failed loading SDL3 library.
    # >
    # > 11/13 Test #11: testtimer ........................Subprocess aborted***Exception:   0.00 sec
    # > Failed loading SDL3 library.
    # >
    # > 12/13 Test #12: testver ..........................Subprocess aborted***Exception:   0.00 sec
    # > Failed loading SDL3 library.
    # >
    # > 13/13 Test #13: testautomation ...................Subprocess aborted***Exception:   0.00 sec
    # > Failed loading SDL3 library.
    # >
    # >
    # > 0% tests passed, 13 tests failed out of 13
    # >
    # > Total Test time (real) =   0.01 sec
    # >
    # > The following tests FAILED:
    # >           1 - testatomic (Subprocess aborted)
    # >           2 - testerror (Subprocess aborted)
    # >           3 - testevdev (Subprocess aborted)
    # >           4 - testfile (Subprocess aborted)
    # >           5 - testfilesystem (Subprocess aborted)
    # >           6 - testlocale (Subprocess aborted)
    # >           7 - testplatform (Subprocess aborted)
    # >           8 - testpower (Subprocess aborted)
    # >           9 - testqsort (Subprocess aborted)
    # >          10 - testthread (Subprocess aborted)
    # >          11 - testtimer (Subprocess aborted)
    # >          12 - testver (Subprocess aborted)
    # >          13 - testautomation (Subprocess aborted)
    # > Errors while running CTest
    # > FAILED: [code=8] CMakeFiles/test.util
    # > cd /build/source/build && /nix/store/4y5szbjgf857wn8603gx77gbznfwqh0q-cmake-4.1.2/bin/ctest
    #
    # alpine builds with tests. TODO: enable `doCheck`!
    sdl2-compat = prev.sdl2-compat.overrideAttrs {
      doCheck = false;
    };

    # XXX(2026-02-15): the below gets signal-desktop to build,
    # but it fails at runtime unless linked against the non-bin `electron`,
    # and electron itself fails to build for musl.
    # signal-desktop = prev.signal-desktop.override {
    #   # signal-desktop's sub-packages aren't accessible, except by injecting a custom callPackage.
    #   # most/all of these patches come from alpine.
    #   callPackage = lib.callPackageWith (final // {
    #     stdenv = stdenv // {
    #       # TODO: use `lib.extendMkDerivation`
    #       mkDerivation = f: stdenv.mkDerivation (finalAttrs:
    #       let
    #         attrs = f finalAttrs;
    #       in attrs
    #         // lib.optionalAttrs (attrs.pname == "signal-webrtc") {
    #           # hardeningDisable = [ "all" ];  #< silences warnings, but not necessary
    #           patches = (attrs.patches or []) ++ [
    #             (writeTextFile {
    #               # from: <repo:alpine/aports:testing/signal-desktop/webrtc-rtcbase-platform-thread-type-do-not-include-linux-prctl-header.patch>
    #               # paths updated slightly, for nixpkgs' `patch` to understand it
    #               name = "webrtc-rtcbase-platform-thread-type-do-not-include-linux-prctl-header.patch";
    #               text = ''
    #                 diff --git a/rtc_base/platform_thread_types.cc b/rtc_base/platform_thread_types.cc
    #                 index 20bf4af..482b15f 100644
    #                 --- a/rtc_base/platform_thread_types.cc
    #                 +++ b/rtc_base/platform_thread_types.cc
    #                 @@ -12,7 +12,6 @@
    #
    #                  // IWYU pragma: begin_keep
    #                  #if defined(WEBRTC_LINUX)
    #                 -#include <linux/prctl.h>
    #                  #include <sys/prctl.h>
    #                  #include <sys/syscall.h>
    #               '';
    #             })
    #           ];
    #         }
    #         // lib.optionalAttrs (attrs.pname == "node-sqlcipher") {
    #           # from aports' APKBUILD
    #           postPatch = (attrs.postPatch or "") + ''
    #             substituteInPlace deps/extension/extension.gyp \
    #               --replace-fail 'x86_64-unknown-linux-gnu' '${stdenv.hostPlatform.config}'
    #           '';
    #         }
    #       );
    #     };
    #     rustPlatform = rustPlatform // {
    #       buildRustPackage = f: rustPlatform.buildRustPackage (finalAttrs:
    #       let
    #         attrs = f finalAttrs;
    #       in attrs
    #         // lib.optionalAttrs (attrs.pname == "libsignal-node") {
    #           # from aports' APKBUILD
    #           postPatch = (attrs.postPatch or "") + ''
    #             substituteInPlace node/build_node_bridge.py \
    #               --replace-fail 'unknown-linux-gnu' '${with stdenv.hostPlatform.parsed; "${vendor.name}-${kernel.name}-${abi.name}"}'
    #           '';
    #         }
    #       );
    #     };
    #   });
    # };
    #
    # 2026-04-30: still required
    signal-desktop = final._pkgsGnu.signal-desktop;

    # 2026-04-30: still required
    # XXX(2026-02-03): default `pkgsMusl.slack` fails at launch:
    # > Error loading shared library ld-linux-x86-64.so.2: No such file or directory (needed by /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack)
    # > Error loading shared library ld-linux-x86-64.so.2: No such file or directory (needed by /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/libffmpeg.so)
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/libffmpeg.so: __mbrlen: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/libffmpeg.so: strtoll_l: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/libffmpeg.so: strtoull_l: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __fprintf_chk: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: gnu_get_libc_version: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: backtrace: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __vfprintf_chk: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __res_nclose: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __res_ninit: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: posix_fallocate64: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __longjmp_chk: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __sched_cpualloc: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __sched_cpufree: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __fdelt_chk: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: initstate_r: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: random_r: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __mbrlen: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: strtoll_l: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: strtoull_l: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __register_atfork: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __longjmp_chk: symbol not found
    # > Error relocating /nix/store/d2xqw8dspwxk2bnvgnwfzqj534rvfdj8-slack-4.47.72/lib/slack/slack: __libc_stack_end: symbol not found
    # slack = prev.slack.overrideAttrs (upstream: {
    #   installPhase = lib.replaceStrings
    #     [ "patchelf --set-rpath " ]
    #     [ "patchelf --set-rpath ${final._pkgsGnu.glibc}:" ]
    #     upstream.installPhase;
    # });
    # swapping just asar does not fix:
    # slack = prev.slack.override {
    #   inherit (final.extend (self': _super': {
    #     inherit (self'._pkgsGnu) asar;
    #   })) callPackage;
    #   # inherit (final._pkgsGnu) asar;
    # };
    slack = final._pkgsGnu.slack;

    # glibcLocales is null on musl, but some packages still refer to it.
    # is this sensible? should rather patch those out...
    # glibcLocales = pkgsCross.gnu64.glibcLocales;

    # 2026-05-23: still required
    # XXX(2026-01-21): fortify failures only on musl:
    # > In file included from /nix/store/a7ijnxh5xvipgfx2j4wn7p6ff2an966p-fortify-headers-1.1alpine3/include/strings.h:23,
    # >                  from /nix/store/ci8sxhmyzz9pgqidk2z9zh6ycgcr72bd-musl-1.2.5-dev/include/string.h:59,
    # >                  from /nix/store/a7ijnxh5xvipgfx2j4wn7p6ff2an966p-fortify-headers-1.1alpine3/include/wchar.h:38,
    # >                  from /nix/store/j95zv7f9k6m5gpwna7rzp66w75hshww6-gcc-15.2.0/include/c++/15.2.0/cwchar:49,
    # >                  from /nix/store/j95zv7f9k6m5gpwna7rzp66w75hshww6-gcc-15.2.0/include/c++/15.2.0/bits/postypes.h:42,
    # >                  from /nix/store/j95zv7f9k6m5gpwna7rzp66w75hshww6-gcc-15.2.0/include/c++/15.2.0/iosfwd:44,
    # >                  from /nix/store/j95zv7f9k6m5gpwna7rzp66w75hshww6-gcc-15.2.0/include/c++/15.2.0/ios:42,
    # >                  from /nix/store/j95zv7f9k6m5gpwna7rzp66w75hshww6-gcc-15.2.0/include/c++/15.2.0/istream:42,
    # >                  from /nix/store/j95zv7f9k6m5gpwna7rzp66w75hshww6-gcc-15.2.0/include/c++/15.2.0/sstream:42,
    # >                  from ../snapper/LoggerImpl.h:28,
    # >                  from Client.cc:26:
    # > /nix/store/a7ijnxh5xvipgfx2j4wn7p6ff2an966p-fortify-headers-1.1alpine3/include/stdlib.h:45:1: error: type of ‘snapper::realpath’ is unknown
    # >    45 | _FORTIFY_FN(realpath) char *realpath(const char *__p, char *__r)
    # >       | ^~~~~~~~~~~
    # > In file included from /nix/store/qy1m4630zb53hbipggk0pnzc4h62a2yh-boost-1.87.0-dev/include/boost/thread/detail/thread.hpp:34,
    # >                  from /nix/store/qy1m4630zb53hbipggk0pnzc4h62a2yh-boost-1.87.0-dev/include/boost/thread/thread_only.hpp:22,
    # >                  from /nix/store/qy1m4630zb53hbipggk0pnzc4h62a2yh-boost-1.87.0-dev/include/boost/thread/thread.hpp:12,
    # >                  from /nix/store/qy1m4630zb53hbipggk0pnzc4h62a2yh-boost-1.87.0-dev/include/boost/thread.hpp:13,
    # >                  from ../dbus/DBusConnection.h:29,
    # >                  from Client.cc:30:
    # > /nix/store/a7ijnxh5xvipgfx2j4wn7p6ff2an966p-fortify-headers-1.1alpine3/include/stdlib.h: In function ‘char* realpath(const char*, char*)’:
    # > /nix/store/a7ijnxh5xvipgfx2j4wn7p6ff2an966p-fortify-headers-1.1alpine3/include/stdlib.h:54:40: error: ‘__orig_realpath’ cannot be used as a function
    # >    54 |                 __ret = __orig_realpath(__p, __buf);
    # >       |                         ~~~~~~~~~~~~~~~^~~~~~~~~~~~
    # > /nix/store/a7ijnxh5xvipgfx2j4wn7p6ff2an966p-fortify-headers-1.1alpine3/include/stdlib.h:63:31: error: ‘__orig_realpath’ cannot be used as a function
    # >    63 |         return __orig_realpath(__p, __r);
    # >       |                ~~~~~~~~~~~~~~~^~~~~~~~~~
    snapper = prev.snapper.overrideAttrs {
      # knownHardeningFlags = [
      #   # or special flag "all"
      #   "bindnow"
      #   "format"
      #   "fortify"
      #   "fortify3"
      #   "glibcxxassertions"
      #   "libcxxhardeningextensive"
      #   "libcxxhardeningfast"
      #   "nostrictaliasing"
      #   "pacret"
      #   "pic"
      #   "relro"
      #   "shadowstack"
      #   "stackclashprotection"
      #   "stackprotector"
      #   "strictflexarrays1"
      #   "strictflexarrays3"
      #   "strictoverflow"
      #   "trivialautovarinit"
      #   "zerocallusedregs"
      # ];
      # hardeningDisable = [ "all" ];
      hardeningDisable = [ "fortify" ];
    };

    # 2026-05-24: still required
    # this was briefly fixed by <https://github.com/NixOS/nixpkgs/pull/518953>, then broken again
    spandsp3 = prev.spandsp3.overrideAttrs {
      # 2026-02-19: fixes SIGILL during checkPhase
      hardeningDisable = [ "fortify" ];
    };

    # 2026-05-23: still required
    # 2026-01-29: fish fails checkPhase on musl, but swaync doesn't seem to actually need it?
    swaynotificationcenter = prev.swaynotificationcenter.override {
      fish = null;
    };

    # 2026-05-23: still required
    # XXX(2026-01-29): fix missing include for posix read/close. TODO: send upstream!
    # > src/backlight.cpp: In lambda function:
    # > src/backlight.cpp:55:39: error: ‘read’ was not declared in this scope; did you mean ‘fread’?
    # >    55 |                         ssize_t ret = read(inotify_fd, buffer, 1024);
    # >       |                                       ^~~~
    # >       |                                       fread
    # > src/backlight.cpp: In destructor ‘syshud_backlight::~syshud_backlight()’:
    # > src/backlight.cpp:69:9: error: ‘close’ was not declared in this scope; did you mean ‘pclose’?
    # >    69 |         close(inotify_fd);
    # >       |         ^~~~~
    # >       |         pclose
    syshud = prev.syshud.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (fetchurl {
          url = "https://git.uninsane.org/colin/syshud/commit/e5639802cacf2d99862ccfb56fefb52b3602c07d.patch?full_index=1";
          hash = "sha256-mkHaKvt8m54EpV2+YYG4p65mhYo3qIxosvEkoU0CCdE=";
        })
      ];
    });

    # 2026-04-30: still required
    # nixpkgs actually just wraps tor's prebuilt releases.
    # neither alpine, arch, void, appear to build tor from source.
    # guix might be the *only* distro that _appears_ to do a from-source build.
    tor-browser = final._pkgsGnu.tor-browser;

    # 2026-06-19: fixes "could not find libSDL3.so" during installCheckPhase.
    # possibly addressed by <https://github.com/NixOS/nixpkgs/pull/500935>
    waybar = prev.waybar.override {
      cavaSupport = false;
    };

    # 2026-05-23: still required
    # 2026-01-29: build failure due to missing include
    # > ifrename.c: In function ‘mapping_getsysfs’:
    # > ifrename.c:1816:15: error: implicit declaration of function ‘basename’ [-Wimplicit-function-declaration]
    # >  1816 |           p = basename(linkpath);
    wirelesstools = prev.wirelesstools.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (fetchAports {
          path = "main/wireless-tools/include-libgen.patch";
          hash = "sha256-HgT04rxtu+Zr+F6xXoc7qIyUXGenGNo72VHDCEGJhXo=";
        })
      ];
    });

    # 2026-05-23: still required
    # 2026-01-28: fix build failure on both nixpkgs master, and on 0.52.0.
    # alpine doesn't need this patch -- why?
    # > ../src/xdg-desktop-portal-phosh.c: In function ‘main’:
    # > ../src/xdg-desktop-portal-phosh.c:150:3: error: implicit declaration of function ‘setlocale’ [-Wimplicit-function-declaration]
    # >   150 |   setlocale (LC_ALL, "");
    # >       |   ^~~~~~~~~
    # > ../src/xdg-desktop-portal-phosh.c:150:3: warning: nested extern declaration of ‘setlocale’ [-Wnested-externs]
    # > ../src/xdg-desktop-portal-phosh.c:150:14: error: ‘LC_ALL’ undeclared (first use in this function)
    # >   150 |   setlocale (LC_ALL, "");
    xdg-desktop-portal-phosh = prev.xdg-desktop-portal-phosh.overrideAttrs (upstream: {
      postPatch = (upstream.postPatch or "") + ''
        sed  -i '1i #include <locale.h>' src/xdg-desktop-portal-phosh.c
        sed  -i '1i #include <locale.h>' src/thumbnailer/service.c
        sed  -i '1i #include <locale.h>' src/thumbnailer/cli.c
      '';
    });

    # 2026-04-30: still required
    # XXX(2026-01-22): v1.6.0 (nixpkgs default) fails to compile:
    # >     CC       xdpsock.o
    # > In file included from /nix/store/ci8sxhmyzz9pgqidk2z9zh6ycgcr72bd-musl-1.2.5-dev/include/net/ethernet.h:10,
    # >                  from xdpsock.c:18:
    # > /nix/store/ci8sxhmyzz9pgqidk2z9zh6ycgcr72bd-musl-1.2.5-dev/include/netinet/if_ether.h:115:8: error: redefinition of ‘struct ethhdr’
    # >   115 | struct ethhdr {
    # >       |        ^~
    # > In file included from xdpsock.c:12:
    # > /nix/store/ci8sxhmyzz9pgqidk2z9zh6ycgcr72bd-musl-1.2.5-dev/include/linux/if_ether.h:173:8: note: originally defined here
    # >   173 | struct ethhdr {
    # >       |        ^~
    # > make[2]: * [Makefile:13: xdpsock.o] Error 1
    # > make[1]: * [Makefile:13: util] Error 2
    # > make: * [Makefile:31: lib] Error 2
    # For full logs, run:
    #     nix log /nix/store/h39j3mh137l8yqmnwr2vh6ijbgv28czf-xdp-tools-1.6.0.drv
    # xdp-tools = prev.xdp-tools.overrideAttrs (upstream: rec {
    #   # 1.6.0+ conflates `linux/if_ether.h` and `netinet/if_ether.h`
    #   # in a way that's difficult to reconcile 100%
    #   # NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";
    #   # postPatch = (upstream.postPatch or "") + ''
    #   #   find . -type f -exec sed -i 's:linux/if_ether.h:netinet/if_ether.h:g' '{}' ';'

    #   #   substituteInPlace lib/libxdp/xsk.c \
    #   #     --replace-fail 'netinet/if_ether.h' 'linux/if_ether.h'

    #   #   substituteInPlace lib/util/xdp_sample.c \
    #   #     --replace-fail 'netinet/if_ether.h' 'linux/if_ether.h'

    #   #   # substituteInPlace lib/util/xdpsock.c \
    #   #   #   --replace-fail 'linux/if_ether.h' 'netinet/if_ether.h'

    #   #   # substituteInPlace lib/util/params.h \
    #   #   #   --replace-fail 'linux/if_ether.h' 'netinet/if_ether.h'

    #   #   # substituteInPlace lib/util/params.c \
    #   #   #   --replace-fail 'linux/if_ether.h' 'netinet/if_ether.h'


    #   #   # substituteInPlace lib/util/xdpsock.h --replace-fail \
    #   #   #   "#include <netinet/ether.h>" "#include <linux/if_ether.h>"

    #   #   # substituteInPlace lib/util/xdpsock.c \
    #   #   #   --replace-fail "#include <netinet/ether.h>" "" \
    #   #   #   --replace-fail "#include <net/ethernet.h>" ""
    #   # '';
    #   # nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
    #   #   final.clang
    #   # ];
    #   # preConfigure = (upstream.preConfigure or "") + ''
    #   #   unset CLANG
    #   # '';
    #   # BPF_CFLAGS = "";
    #   # version = "1.5.7";  #< builds
    #   # src = fetchFromGitHub {
    #   #   owner = "xdp-project";
    #   #   repo = "xdp-tools";
    #   #   rev = "v${version}";
    #   #   hash = "sha256-dJMGBFFfEpKO+5ku5Xsc95hGSmTenHGRjBTL7s1cv0c=";
    #   # };

    #   version = "1.5.8";  #< builds
    #   src = fetchFromGitHub {
    #     owner = "xdp-project";
    #     repo = "xdp-tools";
    #     rev = "v${version}";
    #     hash = "sha256-fW0If34PTGE36KoZYPeKOMuNjaFz1JmSCaWIaSjB0gk=";
    #   };

    #   # version = "1.5.8-unstable-20260106";  #< builds
    #   # src = fetchFromGitHub {
    #   #   owner = "xdp-project";
    #   #   repo = "xdp-tools";
    #   #   rev = "c109ab3175008ffc1c7bdcfc5376c54b5666faf2";
    #   #   hash = "sha256-VRNFPPGtu+n3WBZTzC7ZIJePhY6VgaDXHYbzHkcM+EU=";
    #   # };

    #   #< this region not yet bisected

    #   # version = "1.5.8-unstable-20250911";  #< fails, `make[1]: *** No rule to make target 'xdp_socket.bpf.c', needed by 'xdp_socket.bpf.o'.  Stop.`
    #   # src = fetchFromGitHub {
    #   #   owner = "xdp-project";
    #   #   repo = "xdp-tools";
    #   #   rev = "0a4cc7469abe4f9203598c46008000ee4bbbe10f";
    #   #   hash = "sha256-vZzvFl3bfoGro3hTLnowHkFOI+9JuwO2/78QIOigcTs=";
    #   # };

    #   # version = "1.5.8-unstable-20250916";  #< fails, `make[1]: *** No rule to make target 'xdp_socket.bpf.c', needed by 'xdp_socket.bpf.o'.  Stop.`
    #   # src = fetchFromGitHub {
    #   #   owner = "xdp-project";
    #   #   repo = "xdp-tools";
    #   #   rev = "7028ccef1b62d6b546edd709fc00d7f6ad38a5f1";
    #   #   hash = "sha256-x0IF24NJNdv6U91fAPazQ8HyX+yW5q29w966eOdzCJQ=";
    #   # };

    #   #< this region not yet bisected

    #   # version = "1.5.8-unstable-20250916";  #< fails
    #   # src = fetchFromGitHub {
    #   #   owner = "xdp-project";
    #   #   repo = "xdp-tools";
    #   #   rev = "ec02d32f75431b7ed9857cb51c631bc4127f3fb2";
    #   #   hash = "sha256-dtSHXQEHucZyU/IUIXu5zRee8EMTtfS6R6M2lniI7nE=";
    #   # };

    #   # version = "1.5.8-unstable-20251216";  #< fails
    #   # src = fetchFromGitHub {
    #   #   owner = "xdp-project";
    #   #   repo = "xdp-tools";
    #   #   rev = "bf9ddf088a082141abac3e393c97233c98a39e61";
    #   #   hash = "sha256-qdGI3BgLiUckPJcz+3VERAA0C3N3ZB3/6lCEe6KkcH0=";
    #   # };

    #   # version = "1.6.0-unstable-20260115";  #< fails
    #   # src = fetchFromGitHub {
    #   #   owner = "xdp-project";
    #   #   repo = "xdp-tools";
    #   #   rev = "6754facf547ccf76c601911ba02c84c238d1748f";
    #   #   hash = "sha256-qSEPw/UaH7H0A6hT8ipdlCBS+IG/gyErUa3UK9DOEfI=";
    #   # };
    # });


    # XXX(2026-06-17): nixpkgs adds absolute libEGL/libvulkan DT_NEEDED entries to
    # wezterm-gui in preFixup. that makes the dynamic linker load them at program
    # start, but wezterm later dlopen()s libEGL.so.1 by soname. glibc returns the
    # already-loaded object; musl still needs a RUNPATH entry, and the default
    # patchelf --shrink-rpath drops that entry unless libEGL is needed by soname.
    wezterm = prev.wezterm.overrideAttrs (upstream: {
      preFixup = lib.replaceStrings
        [
          ''--add-needed "${final.libGL}/lib/libEGL.so.1"''
          ''--add-needed "${final.vulkan-loader}/lib/libvulkan.so.1"''
        ]
        [
          ''--remove-needed "${final.libGL}/lib/libEGL.so.1" --add-needed libEGL.so.1''
          ''--remove-needed "${final.vulkan-loader}/lib/libvulkan.so.1" --add-needed libvulkan.so.1''
        ]
        upstream.preFixup
      + ''
        patchelf --set-rpath "$(patchelf --print-rpath $out/bin/wezterm-gui):${final.libGL}/lib:${final.vulkan-loader}/lib" $out/bin/wezterm-gui
      '';
    });

    # 2026-03-29: still required
    # 2026-01-28: disable failing tests:
    # > cd /build/source/build/test && ./test_xsimd
    # > [doctest] doctest version is "2.4.12"
    # > [doctest] run with "--help" for options
    # > ===============================================================================
    # > /build/source/test/test_complex_trigonometric.cpp:198:
    # > TEST CASE:  [complex trigonometric]<xsimd::batch<std::complex<float> >>
    # >   atan
    # > 
    # > /build/source/test/test_complex_trigonometric.cpp:159: ERROR: CHECK_EQ( diff, 0 ) is NOT correct!
    # >   values: CHECK_EQ( 1, 0 )
    # > 
    # > ===============================================================================
    # > /build/source/test/test_complex_trigonometric.cpp:198:
    # > TEST CASE:  [complex trigonometric]<xsimd::batch<std::complex<double> >>
    # >   atan
    # > 
    # > /build/source/test/test_complex_trigonometric.cpp:159: ERROR: CHECK_EQ( diff, 0 ) is NOT correct!
    # >   values: CHECK_EQ( 1, 0 )
    # > 
    # > ===============================================================================
    # > [doctest] test cases:  327 |  325 passed | 2 failed | 0 skipped
    # > [doctest] assertions: 8606 | 8604 passed | 2 failed |
    # > [doctest] Status: FAILURE!
    # > make[3]: *** [test/CMakeFiles/xtest.dir/build.make:70: test/CMakeFiles/xtest] Error 1
    # > make[3]: Leaving directory '/build/source/build'
    # > make[2]: *** [CMakeFiles/Makefile2:246: test/CMakeFiles/xtest.dir/all] Error 2
    # > make[2]: Leaving directory '/build/source/build'
    # > make[1]: *** [CMakeFiles/Makefile2:253: test/CMakeFiles/xtest.dir/rule] Error 2
    # > make[1]: Leaving directory '/build/source/build'
    # > make: *** [Makefile:192: xtest] Error 2
    # > error: builder for '/nix/store/rsav1hbrn8s6xa5zsyanqi8m4l9i6xjp-xsimd-13.2.0.drv' failed with exit code 2;
    xsimd = prev.xsimd.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (fetchAports {
          path = "community/xsimd/failed-tests.patch";
          hash = "sha256-IvbAp/OZU2m6U+jV5xMZLFttGvnlfdkBOSrmYJnBrx8=";
        })
      ];
    });

    # yt-dlp = prev.yt-dlp.override {
    #   # 2026-01-25: deno fails to build for musl.
    #   # >    Compiling encoding_rs v0.8.35
    #   # > error: couldn't read `/build/deno-2.6.5-vendor/v8-142.2.0/gen/src_binding_release_x86_64-unknown-linux-musl.rs`: No such file or directory (os error 2)
    #   # >  --> /build/deno-2.6.5-vendor/v8-142.2.0/src/binding.rs:6:1
    #   # >   |
    #   # > 6 | include!(env!("RUSTY_V8_SRC_BINDING_PATH"));
    #   # >   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #   # >
    #   # >    Compiling unicode-xid v0.2.6
    #   # > error: could not compile `v8` (lib) due to 1 previous error
    #   javascriptSupport = false;  # a.k.a.: `deno = null;`
    # };

    # # XXX(2026-02-03): musl `buildFHSEnvBubblewrap`-based attempt failed at runtime:
    # # > /opt/zoom/ZoomLauncher: /lib/libstdc++.so.6: no version information available (required by /opt/zoom/ZoomLauncher)
    # zoom-us = final._pkgsGnu.zoom-us;

    # 2026-05-23: still required
    # XXX(2026-01-22): unblocked on staging. fixes `pkgsMusl.zsh` Internal Compiler Error
    # > gcc -c -I. -I../Src -I../Src -I../Src/Zle -I. -I/nix/store/cg1bcbp19ysvzxs4yhjb69wkf35l4v6i-pcre2-10.46-dev/include  -DHAVE_CONFIG_H -Wall -Wmissing-prototypes -O2  -o sort.o sort.c
    # > during GIMPLE pass: objsz
    # > sort.c: In function ‘strmetasort’:
    # > sort.c:234:1: internal compiler error: in check_for_plus_in_loops, at tree-object-size.cc:2158
    # >   234 | strmetasort(char **array, int sortwhat, int *unmetalenp)
    # >       | ^~~~~~~~~~~
    # > 0x22c6d7b diagnostic_context::diagnostic_impl(rich_location*, diagnostic_metadata const*, diagnostic_option_id, char const*, __va_list_tag (*) [1], diagnostic_t)
    # >         ???:0
    # > 0x22d89ba internal_error(char const*, ...)
    # >         ???:0
    # > 0x78d323 fancy_abort(char const*, int, char const*)
    # >         ???:0
    # > 0x76a108 compute_builtin_object_size(tree_node*, int, tree_node**) [clone .cold]
    # >         ???:0
    # > 0x8fac5f fold_builtin_n(unsigned long, tree_node*, tree_node*, tree_node**, int, bool) [clone .isra.0]
    # >         ???:0
    # > 0xae49c1 gimple_fold_stmt_to_constant_1(gimple*, tree_node* (*)(tree_node*), tree_node* (*)(tree_node*))
    # >         ???:0
    # > 0xae50e2 gimple_fold_stmt_to_constant(gimple*, tree_node* (*)(tree_node*))
    # >         ???:0
    # > 0xf3c82c object_sizes_execute(function*, bool)
    # >         ???:0
    # > Please submit a full bug report, with preprocessed source (by using -freport-bug).
    # > Please include the complete backtrace with any bug report.
    # > See <https://gcc.gnu.org/bugs/> for instructions.
    # > make[2]: *** [Makemod:230: sort.o] Error 1
    # > make[2]: Leaving directory '/build/zsh-5.9/Src'
    # > make[1]: *** [Makefile:449: modobjs] Error 2
    # > make[1]: Leaving directory '/build/zsh-5.9/Src'
    # > make: *** [Makefile:188: all] Error 1
    zsh = prev.zsh.overrideAttrs {
      hardeningDisable = [ "fortify" ];
    };
  })

  (_: prev: prev.lib.optionalAttrs (prev.stdenv.buildPlatform != prev.stdenv.hostPlatform) {
    # this portion of the overlay only applies to musl -> musl cross compilation (e.g. x86_64 -> aarch64)

    # XXX(2026-05-24): fixes security wrappers for `moby-musl` (pkgsCross.aarch64-multiplatform.pkgsStatic).
    # security wrappers want to access `srcOnly glibc`; default cross glibc uses a custom stdenv
    # which does not build on musl -> patch by using a compatible stdenv.
    # N.B.: the resulting glibc is not statically linked. that's OK because we only use its src.
    glibc = final._pkgsGnu.glibc;

    gvfs = prev.gvfs.override {
      # XXX(2026-05-26): samba compilation is blocked on master (on potrace i think?);
      # disable it until the upstreaming path is more clear.
      samba = null;
    };

    perlInterpreters = {
      # XXX(2026-05-24): LC_ALL=C for perl fixes pkgsMusl.pkgsCross.aarch64-multiplatform-musl.perl;
      #                  LC_ALL=C for each perl package fixes `pkgsMusl.pkgsCross.aarch64-multiplatform-musl.perl.withPackages (ps: [ ps.PACKAGE ])`
      perl5 = (prev.perlInterpreters.perl5.override (prevArgs: {
        passthruFun = args: prevArgs.passthruFun (args // {
          self = final.perlInterpreters.perl5;
          # overrides = ps: (args.overrides ps) // {
          #   buildPerlPackage = drvAttrs: ps.buildPerlPackage (drvAttrs // {
          #     env = (drvAttrs.env or {}) // {
          #       LC_ALL = "C";
          #     };
          #   });
          # };
        });
      })).overrideAttrs (prevAttrs: {
        env = prevAttrs.env // {
          HOSTCFLAGS = "-D_GNU_SOURCE";
          LC_ALL = "C";
        };
        # we should just populate this via `buildPerlPackage`, but that's difficult to override from outside nixpkgs
        setupHook = writeTextFile {
          name = "perl-setupHook";
          text = ''
            source ${prevAttrs.setupHook}
            export LC_ALL=''${LC_ALL:-C}
          '';
        };
      });
    };

    sshpass = prev.sshpass.overrideAttrs (prevAttrs: {
      configureFlags = (prevAttrs.configureFlags or []) ++ [ "ac_cv_func_malloc_0_nonnull=yes" ];
    });

    thin-provisioning-tools = prev.thin-provisioning-tools.overrideAttrs (prevAttrs: {
      preBuild = (prevAttrs.preBuild or "") + ''
        export BINDGEN_EXTRA_CLANG_ARGS="$BINDGEN_EXTRA_CLANG_ARGS --target=${stdenv.hostPlatform.config}"
      '';
    });

    potrace = prev.potrace.overrideAttrs (prevAttrs: {
      env = (prevAttrs.env or {}) // {
        # XXX(2026-05-25): it bundles getopt.c, i'm actually not sure why building to an older C spec fixes it.
        NIX_CFLAGS_COMPILE = (lib.optionalString ((prevAttrs.env.NIX_CFLAGS_COMPILE or "") != "") "${prevAttrs.env.NIX_CFLAGS_COMPILE} ") + "-std=gnu17";
      };
    });
  })

  (_: prev: prev.lib.optionalAttrs prev.stdenv.buildPlatform.isGnu {
    # this portion of the overlay only applies to glibc -> musl cross compilation
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyself: pysuper: {
        # > ModuleNotFoundError: No module named '_dbus_bindings'
        dbus-python = pysuper.dbus-python.overrideAttrs {
          doCheck = false;
          doInstallCheck = false;
        };
      })
    ];
  })
] final super
