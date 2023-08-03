{ fetchpatch2, fetchurl }:
let
  fetchpatch' = {
    saneCommit ? null,
    prUrl ? null,
    hash ? null,
    title ? null,
  }:
    let
      url = if prUrl != null then
        # prUrl takes precedence over any specific commit
        "${prUrl}.diff"
      else
        "https://git.uninsane.org/colin/nixpkgs/commit/${saneCommit}.diff"
      ;
    in fetchpatch2 (
      { inherit url; }
      // (if hash != null then { inherit hash; } else {})
      // (if title != null then { name = title; } else {})
    );
in [

  (fetchpatch' {
    title = "libkiwix: 12.0.0 -> 12.1.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/246700";
    hash = "sha256-LyTkWNgG1mynCdckKm3Hj9ifzLemyrhJ9BFVaPppwgw=";
  })

  # (fetchpatch' {
  #   # XXX: doesn't cleanly apply; fetch `firefox-pmos-mobile` branch from my git instead
  #   title = "firefox-pmos-mobile: init at -pmos-2.2.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/121356";
  #   hash = "sha256-eDsR1cJC/IMmhJl5wERpTB1VGawcnMw/gck9sI64GtQ=";
  # })

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
    title = "firefox-pmos-mobile: init at 4.0.2";
    saneCommit = "c3becd7cdf144d85d12e2e76663e9549a0536efd";
    hash = "sha256-NRh2INUMA2K7q8zioqKA7xwoqg7v6sxpuJRpTG5IP1Q=";
  })

  (fetchpatch' {
    title = "splatmoji: init at 1.2.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/211874";
    saneCommit = "75149039b6eaf57d8a92164e90aab20eb5d89196";
    hash = "sha256-jDXYLlXaEBKMrZ2dgxc6ucrcX/5dtqoIIKw+Ay19vlc=";
  })

  # (fetchpatch {
  #   # stdenv: fix cc for pseudo-crosscompilation
  #   # closed because it breaks pkgsStatic (as of 2023/02/12)
  #   url = "https://github.com/NixOS/nixpkgs/pull/196497.diff";
  #   hash = "sha256-eTwEbVULYjmOW7zUFcTUqvBZqUFjHTKFhvmU2m3XQeo=";
  # })

  # ./2022-12-19-i2p-aarch64.patch

  # fix for CMA memory leak in mesa: <https://gitlab.freedesktop.org/mesa/mesa/-/issues/8198>
  # fixed in mesa 22.3.6: <https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/21330/diffs>
  # only necessary on aarch64.
  # it's a revert of nixpkgs commit dcf630c172df2a9ecaa47c77f868211e61ae8e52
  # ./2023-01-30-mesa-cma-leak.patch
  # upgrade to 22.3.6 instead
  # ./2023-02-28-mesa-22.3.6.patch


  # let ccache cross-compile
  # TODO: why doesn't this apply?
  # ./2023-03-04-ccache-cross-fix.patch

  (fetchpatch' {
    title = "bambu-studio: init at 01.06.02.04";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/206495";
    hash = "sha256-Z+IOzd+bnxjg6neF1YcrRDTzz9GhJfbbj0Wa8yTXsa4=";
  })

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

  # 2023-04-20: perl: fix modules for compatibility with miniperl
  # (fetchpatch {
  #   url = "https://github.com/NixOS/nixpkgs/pull/225640.diff";
  #   hash = "sha256-MNG8C0OgdPnFQ8SF2loiEhXJuP2z4n9pkXr8Zh4X7QU=";
  # })

  (fetchpatch' {
    title = "conky: support wayland";
    # saneCommit = "82978099c3a0d5fb4925351da1b0e2598503dc6c";
    # hash = "sha256-lnDGEDhmeOIXfFnizEIVUiUzI7nMvpoCERbdjhR+Bto=";
    saneCommit = "3ad928e20b498444e3a106b182e09317cea9a11f";
    hash = "sha256-lvIASvQWVFbjHsQwO2EhEBUTSq1UkHvriaZZ2iS0ulU=";
  })

  # (fetchpatch' {
  #   title = "hare-json: init at unstable-2023-01-31";
  #   saneCommit = "260f9c6ac4e3564acbceb46aa4b65fbb652f8e23";
  #   hash = "sha256-bjLKANo0+zaxugJlEk1ObPqRHWOKptD7dXB+/xzsYqA=";
  # })
  # (fetchpatch' {
  #   title = "hare-ev: init at unstable-2022-12-29";
  #   saneCommit = "4058200a407c86c5d963bc49b608aa1a881cbbf2";
  #   hash = "sha256-wm1aavbCfxBhcOXh4EhFO4u0LrA9tNr0mSczHUK8mQU=";
  # })
  # (fetchpatch' {
  #   title = "bonsai: init at 1.0.0";
  #   saneCommit = "65d37294d939384e8db400ea82d25ce8b4ad6897";
  #   hash = "sha256-2easgOtJfzvVcz/3nt3lo1GKLLotrM4CkBRyTgIAhHU=";
  # })
  (fetchpatch' {
    # includes hare-json and hare-ev as pre-reqs
    title = "bonsai: init at 1.0.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/233892";
    hash = "sha256-HqtDgisbR0xOUY4AxhzEv+2JJMPyQMawKo6nbd9pxhE=";
  })

  # make alsa-project members overridable
  (fetchpatch' {
    title = "alsa-project: expose the scope as a top-level package to support overrides";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/246656";
    saneCommit = "28f76deae50cc53f5f6a5e846e04426357b8ce2e";
    # hash = "sha256-dBWStotLBa4LN7JmriTzoFX3/SQr/qxGO8glv3MNyZQ=";
    hash = "sha256-QvurEnupAdPVVnHYl4DC1OqJronGt31REkTJO/alr60=";
  })

  # pin to a pre-0.17.3 release
  # removing this and using stock 0.17.3 (also 0.17.4) causes:
  #   INFO lemmy_server::code_migrations: No Local Site found, creating it.
  #   Error: LemmyError { message: None, inner: duplicate key value violates unique constraint "local_site_site_id_key", context: "SpanTrace" }
  # more specifically, lemmy can't find the site because it receives an error from diesel:
  #   Err(DeserializationError("Unrecognized enum variant"))
  # this is likely some mis-ordered db migrations
  # or perhaps the whole set of migrations here isn't being running right.
  # related: <https://github.com/NixOS/nixpkgs/issues/236890#issuecomment-1585030861>
  # ./2023-06-10-lemmy-downgrade.patch

  (fetchpatch' {
    title = "koreader: 2023.04 -> 2023.05.1";
    saneCommit = "a5c471bd263abe93e291239e0078ac4255a94262";
    hash = "sha256-38sND/UNRj5WAYYKpzdrRBIOK4UAT14RzbIv49KmNNw=";
  })

  (fetchpatch' {
    # TODO: send this upstream!
    title = "mepo: 1.1 -> 1.1.2";
    saneCommit = "eee68d7146a6cd985481cdd8bca52ffb204de423";
    hash = "sha256-uNerTwyFzivTU+o9bEKmNMFceOmy2AKONfKJWI5qkzo=";
  })


  (fetchpatch' {
    title = "gthumb: make the webservices feature be optional";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/240602";
    saneCommit = "50767d5746fd80657e997b43fc5d82ba0c2c2447";
    hash = "sha256-lXuLHdSPhWol9X5QX4cxnZqoVGUWEQTCZLmosvLX+WY=";
  })

  (fetchpatch' {
    title = "gnustep: remove `rec` to support `overrideScope`";
    saneCommit = "69162cbf727264e50fc9d7222a03789d12644705";
    hash = "sha256-rD0es4uUbaLMrI9ZB2HzPmRLyu/ixNBLAFyDJtFHNko=";
  })

  (fetchpatch' {
    title = "p11-kit: build with meson";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/244633";
    hash = "sha256-+z6hosSyt6ynLpUKS0TsHRoLOS8ck/SK9Y7W2zVUnCQ=";
  })
  (fetchpatch' {
    title = "p11-kit: use mesonEmulatorHook for cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/245124";
    hash = "sha256-8NqqLBbjt1fLj4ZYhat7wPqQSv/aez9IwgSK2b4CfW8=";
  })

  (fetchpatch' {
    title = "python310Packages.gssapi: support cross compilation";
    saneCommit = "4766ae46f863734fbe96dc4e537870b6b3894cf4";
    hash = "sha256-qCAJjPRoH8nvKzB+uwDQtGQbFfHS/MiY7m1J0BMl7tY=";
  })
  (fetchpatch' {
    title = "perlPackages.FileBaseDir: 0.08 -> 0.09";
    saneCommit = "acc990b04bbe8c99587eadccc65f100c326ec204";
    hash = "sha256-8s789GGARJH1i088OGBjGGnL2l5m8Q+iBPS213QsS6A=";
  })
  (fetchpatch' {
    title = "perlPackages.TestFile: 1.443 -> 1.993";
    saneCommit = "6cf080fb51d034f9c2ddd60cef7dee7d041afd3e";
    hash = "sha256-fAZpduh3JZeFixJ4yX0wkh/GRp0gYKsTT+XkNdpK7CU=";
  })
  (fetchpatch' {
    title = "xdg-utils: enable cross compilation";
    saneCommit = "b7aa5e0c1ec06723cf1594de192703a65be21497";
    hash = "sha256-4iE2EDIe3nSkB8xFXucyCH7k2oiIoBiuYZYAtF31G38=";
  })
  # (fetchpatch' {
  #   # N.B.: duplicates outstanding, merged PR: <https://github.com/NixOS/nixpkgs/pull/246362>
  #   # - also a stale, approved PR: <https://github.com/NixOS/nixpkgs/pull/245761>
  #   title = "libgudev: support cross compilation";
  #   saneCommit = "4dc30718fe01e9dbed4ffc2ff375148da218e86b";
  #   hash = "sha256-Nb2LphSyv8Dayqfwqfua0eKtNzsnaf7PC/KYUhIvnT8=";
  # })
  (fetchpatch' {
    title = "gupnp: fix cross compilation";
    saneCommit = "a1604d867581239c53a3dda0c845a2eb49aa814a";
    hash = "sha256-euYjOa/axVlFlWo73Xkcg0t4ip/bOCyGbZmynvhM6sc=";
  })
  (fetchpatch' {
    title = "blueman: support cross compilation";
    saneCommit = "e070195bdf213dffb0164574397b6a7417f81c9e";
    hash = "sha256-6JnIJCVBbV4tmFinX7Qv2wO2AThrgxrnyb9T4Ov6p5w=";
  })
  # (fetchpatch' {
  #   # N.B.: duplicates merged PR: <https://github.com/NixOS/nixpkgs/pull/246369>
  #   title = "tracker: support cross compilation";
  #   saneCommit = "bea390fd0c4fda96db5b1fad06ee071a10561305";
  #   hash = "sha256-Y2tVoTvSIIT9ufghqqsXgmqWq9daH+WKj4JHZgWbWwE=";
  # })
  (fetchpatch' {
    title = "tracker-miners: support cross compilation";
    saneCommit = "24b062309ea8baa2d8303c0610c9ec7b8c399e8b";
    hash = "sha256-Jj+1z2DeCEY+DqI1J4vYjYJwDDMRcA93CqpZSXzG0wE=";
  })
  (fetchpatch' {
    title = "upower: fix cross compilation";
    saneCommit = "3ab262456acc016c8dc834df1d1f7e61a00e01e3";
    hash = "sha256-kTFZVu9oDiYH4W4SoQQj0pNuo9hTJk6jUy+hy34HUtA=";
  })
  (fetchpatch' {
    title = "upower: don't pass unnecessary nativeBuildInputs";
    saneCommit = "e2cbfb1bc81afadc5d31c18d43e774fa9a985f98";
    hash = "sha256-7Q9Fjp7xrw3e887inc5cc01OvuOhThnVYduSLNtv2d0=";
  })
  (fetchpatch' {
    title = "iio-sensor-proxy: support cross compilation";
    saneCommit = "dc1c3341fef6c64d5fbc983670819cf7932f5be1";
    hash = "sha256-lSVGjNepRLMfLgaAG3zv/BfoEhJg8yX7EqaCgu8/b8I=";
  })
  (fetchpatch' {
    title = "mpvScripts.mpris: support cross compilation";
    saneCommit = "f7cd92e2afa26852ccf53f8ca59c13d82bf7bf64";
    hash = "sha256-MB3qloOW4pXZmbCIVsUKP2DnPoePmBf+qRc2x/o+nDw=";
  })
  (fetchpatch' {
    title = "wvkbd: support cross compilation";
    saneCommit = "34379f5770662b483ab0cbe252cf23dd663d84dc";
    hash = "sha256-Duim5hPBtfGePBte29ZUtojyRAts9lQlbleUsTJNkwI=";
  })
  (fetchpatch' {
    title = "clapper: support cross compilation";
    saneCommit = "8a171b49aca406f8220f016e56964b3fae53a3df";
    hash = "sha256-R11IYatGhSXxZnJxJid519Oc9Kh56D9NT2/cxf2CLuM=";
  })
  (fetchpatch' {
    title = "gcr_4: support cross compilation";
    saneCommit = "a8c3d69236fa67382a8c18cc1ef0f34610fd3275";
    hash = "sha256-UnLqkkpXxBKaqlsoD1jUIigZkxgLtNpjmMHOx10HpfE=";
  })
  (fetchpatch' {
    title = "networkmanager-openvpn: support cross compilation";
    saneCommit = "6f53c267fbeb2ff543f075032a7e73af2d4bcb9e";
    hash = "sha256-gq9AyKH7/k2ZVSZ3jpPJPt3uAM+CllXQnaiC1tE1r/8=";
  })
  (fetchpatch' {
    title = "WIP: networkmanager-sstp: support cross compilation";
    saneCommit = "6de63fe320406ec9a509db721c52b3894a93bda2";
    hash = "sha256-EY3bQuv/80JbpquUJhc89CcYAgN9A9KkpsSitw/684I=";
  })
  (fetchpatch' {
    title = "WIP: networkmanager-l2tp: support cross compilation";
    saneCommit = "7a4191c570b0e5a1ab257222c26a4a2ecb945037";
    hash = "sha256-FiPJhHGqZ8MFwLY+1t6HgbK6ndomFSYUKvApvrikRHE=";
  })
  (fetchpatch' {
    title = "gtkspell2: support cross compilation";
    saneCommit = "56348833b4411e9fe2016c24c7fc4af1e3c1d28a";
    hash = "sha256-0RMxouOBw7SUmQDLB2qGey714DaM0AOvZlZ5nB+Lkc4=";
  })
  (fetchpatch' {
    title = "libgnt: 2.14.1 -> 2.14.3";
    saneCommit = "ecd423195d72036a209912868ad02742cb4b6fcd";
    hash = "sha256-u4V/UHNtd2c3+FppuJ5LeLNSV8ZaLe8cqj8HmcW2a/0=";
  })
  (fetchpatch' {
    title = "pidgin: support cross compilation";
    saneCommit = "caacbcc54e217f5ee9281422777a7f712765f71a";
    hash = "sha256-PDCp4GOm6hWcRob4kz7qXZfxAF6YbYrESx9idoS3e/s=";
  })

  (fetchpatch' {
    title = "dtrx: 8.5.1 -> 8.5.3";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/246282";
    saneCommit = "eba9bbc251db942ae27f87824cae643b5f3198c2";
    # hash = "sha256-wgpjUXQ/ZnRY5AJ9xOL2BToA7hDaokDiMmPkMt0Y5go=";
    hash = "sha256-awUDlibmxcJcdMZeBXcWR1U+P/GCxCH/lalhwZ5Er90=";
  })
  # (fetchpatch' {
  #   title = "dtrx: don't double-wrap the binary";
  #   saneCommit = "97a9d12b6c31a58e9067eae7cdcd3f53055c124c";
  #   hash = "sha256-g+p96OrBOQAwwH7nwHBuM/KGeIrnBzh9u9lL0M0sYWo=";
  # })

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

  # ./07-duplicity-rich-url.patch

  # fix qt6.qtbase and qt6.qtModule to cross-compile.
  # unfortunately there's some tangle that makes that difficult to do via the normal `override` facilities
  # ./2023-03-03-qtbase-cross-compile.patch

  # qt6 qtwebengine: specify `python` as buildPackages
  # ./2023-06-02-qt6-qtwebengine-cross.patch

  # Jellyfin: don't build via `libsForQt5.callPackage`
  # ./2023-06-06-jellyfin-no-libsForQt5-callPackage.patch
]
