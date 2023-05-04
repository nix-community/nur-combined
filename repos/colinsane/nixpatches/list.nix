{ fetchpatch, fetchurl }: [

  # splatmoji: init at 1.2.0
  (fetchpatch {
    # https://github.com/NixOS/nixpkgs/pull/211874
    url = "https://git.uninsane.org/colin/nixpkgs/commit/75149039b6eaf57d8a92164e90aab20eb5d89196.diff";
    hash = "sha256-IvsIcd2wPdz4b/7FMrDrcVlIZjFecCQ9uiL0Umprbx0=";
  })

  # (fetchpatch {
  #   # stdenv: fix cc for pseudo-crosscompilation
  #   # closed because it breaks pkgsStatic (as of 2023/02/12)
  #   url = "https://github.com/NixOS/nixpkgs/pull/196497.diff";
  #   hash = "sha256-eTwEbVULYjmOW7zUFcTUqvBZqUFjHTKFhvmU2m3XQeo=";
  # })

  ./2022-12-19-i2p-aarch64.patch

  # fix for CMA memory leak in mesa: <https://gitlab.freedesktop.org/mesa/mesa/-/issues/8198>
  # fixed in mesa 22.3.6: <https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/21330/diffs>
  # only necessary on aarch64.
  # it's a revert of nixpkgs commit dcf630c172df2a9ecaa47c77f868211e61ae8e52
  # ./2023-01-30-mesa-cma-leak.patch
  # upgrade to 22.3.6 instead
  # ./2023-02-28-mesa-22.3.6.patch

  # fix qt6.qtbase and qt6.qtModule to cross-compile.
  # unfortunately there's some tangle that makes that difficult to do via the normal `override` facilities
  ./2023-03-03-qtbase-cross-compile.patch

  # let ccache cross-compile
  # TODO: why doesn't this apply?
  # ./2023-03-04-ccache-cross-fix.patch

  # 2023-04-11: bambu-studio: init at unstable-2023-01-11
  (fetchpatch {
    url = "https://github.com/NixOS/nixpkgs/pull/206495.diff";
    hash = "sha256-RbQzAtFTr7Nrk2YBcHpKQMYoPlFMVSXNl96B/lkKluQ=";
  })

  ./2023-04-29-lemmy.patch

  # 2023-04-20: perl: fix modules for compatibility with miniperl
  # (fetchpatch {
  #   url = "https://github.com/NixOS/nixpkgs/pull/225640.diff";
  #   hash = "sha256-MNG8C0OgdPnFQ8SF2loiEhXJuP2z4n9pkXr8Zh4X7QU=";
  # })

  # # kaiteki: init at 2022-09-03
  # vendorHash changes too frequently (might not be reproducible).
  # using local package defn until stabilized
  # (fetchpatch {
  #   url = "https://git.uninsane.org/colin/nixpkgs/commit/e2c7f5f4870fcb0e5405e9001b39a64c516852d4.diff";
  #   # url = "https://github.com/NixOS/nixpkgs/pull/193169.diff";
  #   sha256 = "sha256-UWnfS+stVpUZ3Sfaym9XtVBlwvHWJVMaW7cYIcf3M5Q=";
  # })


  # Fix mk flutter app
  # closed (not merged). updates fluffychat 1.2.0 -> 1.6.1, but unstable hashing
  # (fetchpatch {
  #   url = "https://github.com/NixOS/nixpkgs/pull/186839.diff";
  #   sha256 = "sha256-NdIfie+eTy4V1vgqiiRPtWdnxZ5ZHsvCMfkEDUv9SC8=";
  # })

  # for raspberry pi: allow building u-boot for rpi 4{,00}
  # TODO: remove after upstreamed: https://github.com/NixOS/nixpkgs/pull/176018
  #   (it's a dupe of https://github.com/NixOS/nixpkgs/pull/112677 )
  ./02-rpi4-uboot.patch

  # ./07-duplicity-rich-url.patch

  # enable aarch64 support for flutter's dart package
  # ./10-flutter-arm64.patch
]
