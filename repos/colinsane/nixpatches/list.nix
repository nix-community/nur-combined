{ fetchpatch2, fetchurl, lib }:
variant: date:
let
  fetchpatch' = {
    saneCommit ? null,
    nixpkgsCommit ? null,
    prUrl ? null,
    hash ? null,
    title ? null,
    revert ? false,
    merged ? {},
  }:
    let
      url = if prUrl != null then
        # prUrl takes precedence over any specific commit
        "${prUrl}.diff"
      else if saneCommit != null then
        "https://git.uninsane.org/colin/nixpkgs/commit/${saneCommit}.diff"
      else
        "https://github.com/NixOS/nixpkgs/commit/${nixpkgsCommit}.patch"
      ;
      isMerged = merged ? "${variant}" && lib.versionAtLeast date merged."${variant}";
    in if !isMerged then fetchpatch2 (
      { inherit revert url; }
      // (if hash != null then { inherit hash; } else {})
      // (if title != null then { name = title; } else {})
    ) else null;
in [
  (fetchpatch' {
    title = "hareThirdParty.hare-ev: unstable-2023-10-31 -> unstable-2023-12-04";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/277222";
    hash = "sha256-mRcx489YFiF+1iVFJRY+bxaoWf/yJqMbRh9GO3ctApQ=";
  })
  (fetchpatch' {
    title = "argyllcms: support cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/275755";
    saneCommit = "8114d5dabbf5f4f1e8c370b889d4f2986b63998b";
    hash = "sha256-z/vY2CxdrUVd4n7w+m8aNffXaN/jH7IWEwRfWNr9w94=";
  })
  (fetchpatch' {
    title = "ripgrep: fix shell completions when cross compiling";
    saneCommit = "8631ddfb99aa8e935276b27d55ef5e10f5ab0367";
    hash = "sha256-AkxtrCJrf0wpTdty4SOIWBrWwqfG7rBI4ON38BjDi6s=";
  })
  (fetchpatch' {
    title = "jbig2dec: fix cross";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/266254";
    hash = "sha256-HOR9oehqs1n3KE4jKZavXYy7pqEq9osJsxupCDnrtHY=";
    merged.staging = "202312062110";
    merged.staging-next = "202312210000";
  })
  (fetchpatch' {
    title = "jbig2dec cross fix";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/275027";
    hash = "sha256-sGBX1UamML46oS7zPZcuQXURjwADiPvvcEmAphoHvMg=";
    merged.staging = "202312202300";
    merged.staging-next = "202312210000";
  })
  (fetchpatch' {
    title = "vala: look for files in targetOffset";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/267550";
    hash = "sha256-Dl9ZQazjXjIbw38Q78otQvgVCB/QZAC1IYoFX0Tuyw0=";
    merged.staging = "202312012359";
    merged.staging-next = "202312210000";
  })

  # (fetchpatch' {
  #   title = "nixos/slskd: allow omitting username from yaml config";
  #   saneCommit = "541c37e8689b6422ea07be1395f1a63357bb0c63";
  #   hash = "sha256-xQEj/oIfNcE4td9jxzDzhlnIYpncOOdXZuswkmcLNuk=";
  # })
  # (fetchpatch' {
  #   title = "nixos/slskd: don't enable nginx unless nginx.enable was set";
  #   saneCommit = "ea084e5739a68436cc240aeca5c10b92de1e3138";
  #   hash = "sha256-25zB5eM1WBVEigmrq1mY9GXwEkS/jf5v7BCfmN6Wux4=";
  # })
  (fetchpatch' {
    title = "nixos/slskd: option fixes";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/270646";
    hash = "sha256-5brmmPfYp7G+5Dr5q2skWSwkrEwsRAe/UetoN0AqGjY=";
  })
  # (fetchpatch' {
  #   # N.B.: obsoleted by 267550 PR above
  #   title = "vala: search for vapi files in targetOffset, not hostOffset";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/269171";
  #   saneCommit = "6990fa8f3e1cfcd1224d70d110bc1ccc18763585";
  #   hash = "sha256-QiguGtP5HrB753/V/UaoAKH3+9TINxR83I68rggbkr0=";
  # })
  (fetchpatch' {
    title = "gcr: remove build gnupg from runtime closure";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/263158";
    saneCommit = "8c71ab22c6df4e5ce290e131a7769688b0c5a017";
    # hash = "sha256-9PNKzNlJ62WAq6H+tqlt0spFZ1DPP1hHmpx0YPuieFE=";
    hash = "sha256-6hUdsExHSMHy6FMY1+OLtVmKpRwysGIVkcDpYv7RRBk=";
  })
  (fetchpatch' {
    title = "hspell: remove build perl from runtime closure";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/263182";
    hash = "sha256-Wau+PB+EUQDvWX8Kycw1sNrM3GkPVjKSS4niIDI0sjM=";
  })
  # (fetchpatch' {
  #   title = "trust-dns: 0.23.0 -> 0.24.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/262466";
  #   hash = "sha256-s8ra/tbD/xAfU3HI3wv+aQ0dip1kKQcVrJvLG6DNctY=";
  # })
  # (fetchpatch' {
  #   title = "trust-dns: rebrand as hickory-dns";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/262268";
  #   hash = "sha256-TxQiR+OS4YriLNViTg4H78Z3f3IjBVodiFAkOUCeNic=";
  # })
  (fetchpatch' {
    title = "rpm: 4.18.1 -> 4.19.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/260558";
    hash = "sha256-kwod+6SbUZechzbmu1D4Hlh6pYiPD18wcqetk0OIOrA=";
  })

  # (fetchpatch' {
  #   # XXX: doesn't cleanly apply; fetch `firefox-pmos-mobile` branch from my git instead
  #   title = "firefox-pmos-mobile: init at -pmos-2.2.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/121356";
  #   hash = "sha256-eDsR1cJC/IMmhJl5wERpTB1VGawcnMw/gck9sI64GtQ=";
  # })

  (fetchpatch' {
    title = "firefox-pmos-mobile: init at 4.0.2";
    saneCommit = "c3becd7cdf144d85d12e2e76663e9549a0536efd";
    hash = "sha256-NRh2INUMA2K7q8zioqKA7xwoqg7v6sxpuJRpTG5IP1Q=";
  })
  # (fetchpatch' {
  #   saneCommit = "70c12451b783d6310ab90229728d63e8a903c8cb";
  #   title = "firefox-pmos-mobile: init at -pmos-2.2.0";
  #   hash = "sha256-mA22g3ZIERVctq8Uk5nuEsS1JprxA+3DvukJMDTOyso=";
  # })
  # (fetchpatch' {
  #   saneCommit = "ee19a28aa188bb87df836a4edc7b73355b8766eb";
  #   title = "firefox-pmos-mobile: format the generated policies.nix file";
  #   hash = "sha256-K8b3QpyVEjajilB5w4F1UHGDRGlmN7i66lP7SwLZpWI=";
  # })
  # (fetchpatch' {
  #   saneCommit = "c068439c701c160ba15b6ed5abe9cf09b159d584";
  #   title = "firefox-pmos-mobile: implement an updateScript";
  #   hash = "sha256-afiGDHbZIVR3kJuWABox2dakyiRb/8EgDr39esqwcEk=";
  # })
  # (fetchpatch' {
  #   saneCommit = "865c9849a9f7bd048e066c2efd8068ecddd48e33";
  #   title = "firefox-pmos-mobile: 2.2.0 -> 4.0.2";
  #   hash = "sha256-WjWSW0qE+cypvUkDRfK7d9Te8m5zQXwF33z8nEhbvrE=";
  # })
  # (fetchpatch' {
  #   saneCommit = "eb6aae632c55ce7b0a76bca549c09da5e1f7761b";
  #   title = "firefox-pmos-mobile: refactor and populate `passthru` to aid external consumers";
  #   hash = "sha256-/LhbwXjC8vuKzIuGQ3/FGplbLllsz57nR5y+PeDjGuA=";
  # })
  # (fetchpatch' {
  #   saneCommit = "c9b90ef1e17ea21ac779a86994e5d9079a2057b9";
  #   title = "librewolf-pmos-mobile: init";
  #   hash = "sha256-oQEM3EZfAOmfZzDu9faCqyOFZsdHYGn1mVBgkxt68Zg=";
  # })

  (fetchpatch' {
    title = "splatmoji: init at 1.2.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/211874";
    saneCommit = "75149039b6eaf57d8a92164e90aab20eb5d89196";
    hash = "sha256-abLakAWaRfc8tgu4IwUdR/w8GAuSl+OhQkYozlprD0c=";
  })

  # (fetchpatch {
  #   # stdenv: fix cc for pseudo-crosscompilation
  #   # closed because it breaks pkgsStatic (as of 2023/02/12)
  #   url = "https://github.com/NixOS/nixpkgs/pull/196497.diff";
  #   hash = "sha256-eTwEbVULYjmOW7zUFcTUqvBZqUFjHTKFhvmU2m3XQeo=";
  # })

  # ./2022-12-19-i2p-aarch64.patch

  # let ccache cross-compile
  # ./2023-03-04-ccache-cross-fix.patch

  # (fetchpatch' {
  #   # phoc: 0.25.0 -> 0.27.0
  #   # TODO: move wayland-scanner & glib to nativeBuildInputs
  #   # TODO: once i press power button to screen blank, power doesn't reactivate phoc
  #   # sus commits:
  #   # - all lie between 0.25.0 .. 0.26.0
  #   # - 25d65b9e6ebde26087be6414e41cf516599c3469  2023/03/12 phosh-private: Forward key release as well
  #   # idle inhibit 2023/03/14
  #   #   - 20e7b26af16e9d9c22cba4550f922b90b80b6df6
  #   #   - b081ef963154c7c94a6ab33376a712b3efe17545
  #   # screen blank fix  (NOPE: this one is OK)
  #   #   - 37542bb80be8a7746d2ccda0c02048dd92fac7af  2023/03/11
  #   saneCommit = "12e89c9d26b7a1a79f6b8b2f11fce0dd8f4d5197";
  #   hash = "sha256-IJNBVr2xAwQW4SAJvq4XQYW4D5tevvd9zRrgXYmm38g=";
  # })
  # (fetchpatch' {
  #   # phosh: 0.25.1 -> 0.27.0
  #   # TODO: fix Calls:
  #   # > Failed to get emergency contacts: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.gnome.Calls was not provided by any .service files
  #   saneCommit = "c8fa213c7cb357c0ca0d5bea66278362a47caeb8";
  #   hash = "sha256-I8IZ8fjJstmcIXEN622/A1w2uHDACwXFl1WbXTWOyi4=";
  # })

  # (fetchpatch' {
  #   # phosh-mobile-settings: 0.23.1 -> 0.27.0
  #   # branch: pr/sane/phosh-mobile-settings-0.27.0
  #   # TODO: fix feedback section
  #   # > Settings schema 'org.gtk.gtk4.Settings.FileChooser' is not installed
  #   # ^ is that provided by nautilus?
  #   saneCommit = "8952f79699d3b0d72d9f6efb022e826175b143a6";
  #   hash = "sha256-myKKMt5cZhC0mfPhEsNjwKjaIYICj5LBJqV01HghYUg=";
  # })

  (fetchpatch' {
    title = "conky: enable Wayland support and cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/278071";
    hash = "sha256-e6o+Vjd3KCI9dFj0TdAWyyqfreX8cf0RfYGdyvebYC0=";
  })
  # 2023-08-06: OLD conky wayland + cross compilation patches.
  # nix path-info shows clean
  # branch is wip-conky-cross2 on servo
  # factoring out those feature abstractions was possibly overkill.
  # the manual wayland-scanner patching is unfortunate, but within
  #   acceptable norms of the existing package.
  # (fetchpatch' {
  #   title = "conky: factor out an abstraction for feature flags";
  #   saneCommit = "3ddf13038d6df90ad0db36a41d55e4077818a3e9";
  #   hash = "sha256-CjLzndFEH1Ng9CqKX8gxCJ6n/wFv5U/sHnQE0FMYILc=";
  # })
  # (fetchpatch' {
  #   title = "conky: simplify the features even more";
  #   saneCommit = "1c4aa404743f1ae7d5b95f18a96c4057ca251a96";
  #   hash = "sha256-0zhiw9siIkFgFW4sow+X88NBEa3ggCe1t1HJ5xFH4ac=";
  # })
  # (fetchpatch' {
  #   title = "conky: support cross compilation";
  #   saneCommit = "01e607e11c7e5bbbfe6ad132fb72394ec29dab0a";
  #   hash = "sha256-Bm/XFLvE7gEyLPlBWNSAcU3qwwqKLIRdpoe0/1aHUho=";
  # })
  # (fetchpatch' {
  #   title = "conky: add wayland support";
  #   saneCommit = "84c51f67e02ebc7f118fd3171bd10f1978d4f1e6";
  #   hash = "sha256-gRYbkzCe3q1R7X/FeOcz/haURQkeAfmED1/ZQlCCdWE=";
  # })
  # (fetchpatch' {
  #   title = "conky: remove no-op sed patch";
  #   saneCommit = "e8b19984a2858ca24b7e8f5acd20be8b7dfe1af0";
  #   hash = "sha256-K3mG1kcyB7sQZ7ZRCdlinNsV6mCcl3eIUI2ldSmcbJE=";
  # })

  # (fetchpatch' {
  #   title = "hare-json: init at unstable-2023-02-25";
  #   saneCommit = "6c88c2b087755e8f60c9f61c6361dec2f7a38155";
  #   hash = "sha256-9TTlhwLDZESaFC02k4+YER+NvoNVPz9wFYV79+Dmuxs=";
  # })
  # (fetchpatch' {
  #   title = "hare-ev: init at unstable-2022-12-29";
  #   saneCommit = "1761049e9b8620091f29bf864ecbbf204b0c56b4";
  #   hash = "sha256-H2ekBJx/iRX8E4uVmdEyaAZVhqeM25QbwvQ9Ki7fMQ0=";
  # })
  # (fetchpatch' {
  #   title = "bonsai: init at 1.0.0";
  #   saneCommit = "507252828934c73c7cffe255dae237c041676c27";
  #   hash = "sha256-HwycOd3v4IifdQqQmMP6w14g0E/T9RAjAw41AsUZQoc=";
  # })
  (fetchpatch' {
    # includes hare-json and hare-ev as pre-reqs
    title = "bonsai: init at 1.0.2";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/233892";
    hash = "sha256-i50rY3S4IeRHpZrG2wF/MJaLyS7TbfUv6pszrDOixzg=";
  })

  (fetchpatch' {
    title = "gthumb: make the webservices feature be optional";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/240602";
    saneCommit = "e83130f2770c314b2a482e1792b010da66cdd5de";
    hash = "sha256-GlYWpOVZvr0oFAs4RdSUf7LJD3FmGsCaTm32GPhbBfc=";
  })
  (fetchpatch' {
    # TODO: send for review once hspell fix is merged <https://github.com/NixOS/nixpkgs/pull/263182>
    # this patch works as-is, but hspell keeps a ref to build perl and thereby pollutes this closure as well.
    title = "gtkspell2: support cross compilation";
    saneCommit = "56348833b4411e9fe2016c24c7fc4af1e3c1d28a";
    hash = "sha256-0RMxouOBw7SUmQDLB2qGey714DaM0AOvZlZ5nB+Lkc4=";
  })
  (fetchpatch' {
    title = "libgnt: 2.14.1 -> 2.14.3";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/246937";
    saneCommit = "ecd423195d72036a209912868ad02742cb4b6fcd";
    # hash = "sha256-u4V/UHNtd2c3+FppuJ5LeLNSV8ZaLe8cqj8HmcW2a/0=";
    hash = "sha256-Tymh8r75pcoEzsqkU0wzm+vK137P2pEEilgNIyM8udQ=";
  })
  (fetchpatch' {
    # TODO: send for review once the libgnt patch above is merged
    title = "pidgin: support cross compilation";
    saneCommit = "caacbcc54e217f5ee9281422777a7f712765f71a";
    hash = "sha256-PDCp4GOm6hWcRob4kz7qXZfxAF6YbYrESx9idoS3e/s=";
  })

  (fetchpatch' {
    title = "libgweather: enable introspection on cross builds";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/251956";
    saneCommit = "7a2d0a90cc558ea71dfc78356e61b0675b995634";
    hash = "sha256-4x1yJgrgmyqYiF+u3A9BrcbNQPQ270c+/jFBYsJoFfI=";
  })

  # (fetchpatch' {
  #   # N.B.: compiles, but runtime error on launch suggestive of some module not being shipped
  #   title = "matrix-appservice-irc: 0.38.0 -> 1.0.0";
  #   saneCommit = "b168bf862d53535151b9142a15fbd53e18e688c5";
  #   hash = "sha256-dDa2mrCJ416PIYsDH9ya/4aQdqtp4BwzIisa8HdVFxo=";
  # })

  # for raspberry pi: allow building u-boot for rpi 4{,00}
  # TODO: remove after upstreamed: https://github.com/NixOS/nixpkgs/pull/176018
  #   (it's a dupe of https://github.com/NixOS/nixpkgs/pull/112677 )
  ./02-rpi4-uboot.patch

  # (fetchpatch' {
  #   title = "fx-cast-bridge: Pin nodejs to version 18";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/273768";
  #   hash = "sha256-THf+O5THf0URY6bsq2/bVo1P2CvUq7opxNtl548yTak=";
  # })
  # (fetchpatch' {
  #   # 2023/12/12: needs rebasing
  #   title = "gnome-feeds: 0.16.2 -> 2.2.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/217060";
  #   hash = "sha256-EY3r661V2aOQQbZ2hTdPS0wipgktwPPgNrz2OJr4qFg=";
  # })

  # (fetchpatch' {
  #   title = "gnustep: remove `rec` to support `overrideScope`";
  #   saneCommit = "69162cbf727264e50fc9d7222a03789d12644705";
  #   hash = "sha256-rD0es4uUbaLMrI9ZB2HzPmRLyu/ixNBLAFyDJtFHNko=";
  # })

  # (fetchpatch' {
  #   # 2023/11/14: deps don't cross compile (e.g. pipewire; qtsvg)
  #   title = "clapper: support cross compilation";
  #   saneCommit = "8a171b49aca406f8220f016e56964b3fae53a3df";
  #   hash = "sha256-R11IYatGhSXxZnJxJid519Oc9Kh56D9NT2/cxf2CLuM=";
  # })
  # (fetchpatch' {
  #   # not correct: build time dependencies end up in runtime closure
  #   title = "gcr_4: support cross compilation";
  #   saneCommit = "a8c3d69236fa67382a8c18cc1ef0f34610fd3275";
  #   hash = "sha256-UnLqkkpXxBKaqlsoD1jUIigZkxgLtNpjmMHOx10HpfE=";
  # })
  # these probably work, but i don't use them
  # (fetchpatch' {
  #   title = "networkmanager-openvpn: support cross compilation";
  #   saneCommit = "6f53c267fbeb2ff543f075032a7e73af2d4bcb9e";
  #   hash = "sha256-gq9AyKH7/k2ZVSZ3jpPJPt3uAM+CllXQnaiC1tE1r/8=";
  # })
  # (fetchpatch' {
  #   title = "WIP: networkmanager-sstp: support cross compilation";
  #   saneCommit = "6de63fe320406ec9a509db721c52b3894a93bda2";
  #   hash = "sha256-EY3bQuv/80JbpquUJhc89CcYAgN9A9KkpsSitw/684I=";
  # })
  # (fetchpatch' {
  #   title = "WIP: networkmanager-l2tp: support cross compilation";
  #   saneCommit = "7a4191c570b0e5a1ab257222c26a4a2ecb945037";
  #   hash = "sha256-FiPJhHGqZ8MFwLY+1t6HgbK6ndomFSYUKvApvrikRHE=";
  # })

  # (fetchpatch' {
  #   # doesn't apply cleanly. use build result in <working/zcash>
  #   title = "zcash: 5.4.2 -> 5.7.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/229810";
  #   hash = "sha256-ProoPJ10rUtOZh2PzpegviG6Ip1zSuWC92BpP+ux9ZQ=";
  # })
  # (fetchpatch' {
  #   title = "graphicsmagick: 1.3.39 -> 1.3.42";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/218163";
  #   hash = "sha256-E1Xfi7BRpAvqAzfChjWRG1Ar5dsFMm/yu7NXnDc95PM=";
  # })
  # (fetchpatch' {
  #   # disabled, at least until the PR is updated to use `pkg-config` instead of `pkgconfig`.
  #   # the latter is an alias, which breaks nix-index
  #   title = "phog: init at 0.1.3";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/251249";
  #   hash = "sha256-e38Z7sO7xDQHzE9UOfbptc6vJuONE5eP9JFp2Nzx53E=";
  # })

  # fix qt6.qtbase and qt6.qtModule to cross-compile.
  # unfortunately there's some tangle that makes that difficult to do via the normal `override` facilities
  # ./2023-03-03-qtbase-cross-compile.patch

  # qt6 qtwebengine: specify `python` as buildPackages
  # ./2023-06-02-qt6-qtwebengine-cross.patch

  # Jellyfin: don't build via `libsForQt5.callPackage`
  # ./2023-06-06-jellyfin-no-libsForQt5-callPackage.patch
]
