final: prev: {
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
  nixVersions = prev.nixVersions.extend (_: nixSuper: {
    nixComponents_2_31 = nixSuper.nixComponents_2_31.overrideScope (_: _: {
      nix-functional-tests = null;
    });
    nixComponents_2_32 = nixSuper.nixComponents_2_32.overrideScope (_: _: {
      nix-functional-tests = null;
    });
    nixComponents_2_33 = nixSuper.nixComponents_2_33.overrideScope (_: _: {
      nix-functional-tests = null;
    });
    nixComponents_2_34 = nixSuper.nixComponents_2_34.overrideScope (_: _: {
      nix-functional-tests = null;
    });
    nixComponents_git = nixSuper.nixComponents_git.overrideScope (_: _: {
      nix-functional-tests = null;
    });
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyself: pysuper: {
      lancedb = pysuper.lancedb.overridePythonAttrs (prevAttrs: {
        postPatch = (prevAttrs.postPatch or "") + ''
          for f in $cargoDepsCopy/source-registry-0/lance-linalg-6.0.0/src/distance/{cosine_u8.rs,dot_u8.rs,l2_u8.rs}; do
            substituteInPlace $f \
              --replace-fail '_avx512_vnni' '_avx2' \
              --replace-fail '#[target_feature(enable = "avx512f,avx512bw,avx512vnni")]' '#[cfg(false)]'
          done
        '';
      });
      pylance = pysuper.pylance.overridePythonAttrs (prevAttrs: {
        # disable avx512vnni primitives which fail to compile, like
        # - _mm512_dpbusd_epi32
        # - _mm512_dpwssd_epi32
        # > rustc-LLVM ERROR: Cannot select: intrinsic %llvm.x86.avx512.vpdpbusd.512
        postPatch = (prevAttrs.postPatch or "") + ''
          for f in ../rust/lance-linalg/src/distance/{cosine_u8.rs,dot_u8.rs,l2_u8.rs}; do
            substituteInPlace $f \
              --replace-fail '_avx512_vnni' '_avx2' \
              --replace-fail '#[target_feature(enable = "avx512f,avx512bw,avx512vnni")]' '#[cfg(false)]'
          done
        '';
      });
    })
  ];

  slurp = if final.lib.versionAtLeast prev.slurp.version "1.5.1" then
    final.lib.warnOnInstantiate "new slurp screenshotter may fail: test before committing" prev.slurp
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
      (final.fetchurl {
        name = "Remap-message-serials-to-monotonically-increasing-value";
        # https://github.com/flatpak/xdg-dbus-proxy/pull/81
        url = "https://github.com/flatpak/xdg-dbus-proxy/pull/81/commits/300c7c612eb961c233a4d076836804ed5a298c16.patch?full_index=1";
        hash = "sha256-7PK+x7lnJxwTn04MYTEnj0iae2ChE4yAi9+gMOusxrs=";
      })
      # 2026-04-22: from checkraisefold to fix <https://github.com/flatpak/xdg-dbus-proxy/issues/67>
      # ./patches/xdg-dbus-proxy/monotonic-serial.patch
    ];
  });
}
