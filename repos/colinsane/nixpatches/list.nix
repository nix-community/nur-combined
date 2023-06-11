{ fetchpatch, fetchurl }:
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
    in fetchpatch (
      { inherit url; }
      // (if hash != null then { inherit hash; } else {})
      // (if title != null then { name = title; } else {})
    );
in [

  # splatmoji: init at 1.2.0
  (fetchpatch' {
    saneCommit = "75149039b6eaf57d8a92164e90aab20eb5d89196";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/211874";
    hash = "sha256-fftctCx1N/P7yLTRxsHYLHbX+gV/lFpWrWCTtZ2L1Cw=";
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

  # 2023-04-11: bambu-studio: init at 01.06.02.04
  (fetchpatch' {
    prUrl = "https://github.com/NixOS/nixpkgs/pull/206495";
    hash = "sha256-jl6SZwSDhQTlpM5FyGaFU/svwTb1ySdKtvWMgsneq3A=";
  })

  (fetchpatch' {
    title = "cargo-docset: init at 0.3.1";
    saneCommit = "5a09e84c6159ce545029483384580708bc04c08f";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/231188";
    hash = "sha256-Z1HOps3w/WvxAiyUAHWszKqwS9EwA6rf4XfgPGp+2sQ=";
  })

  (fetchpatch' {
    title = "nixos/lemmy: support nginx";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/232536";
    saneCommit = "02a9f9de49923f14fd6c2b069d73e167cdc86078";
    hash = "sha256-nnZ+95LmZ2nGZxK7yNLs4moovhPX2wFux5JwNjM4Lys=";
  })

  (fetchpatch' {
    title = "feedbackd: 0.1.0 -> 0.2.0";
    saneCommit = "a0186a5782708a640cd6eaad6e9742b9cccebe9d";
    hash = "sha256-f8he7pQow4fZkTVVqU/A5KgovZA7m7MccRQNTnDxw5o=";
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
    title = "conky: 1.13.1 -> 1.18.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/217224";
    hash = "sha256-+g3XhmBt/udhbBDiVyfWnfXKvZTvDurlvPblQ9HYp3s=";
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
    title = "bonsai: init at 1.0.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/233892";
    hash = "sha256-9XKPNg7TewicfbMgiASpYysTs5aduIVP+4onz+noc/0=";
  })

  # make alsa-project members overridable
  ./2023-05-31-toplevel-alsa.patch

  # qt6 qtwebengine: specify `python` as buildPackages
  ./2023-06-02-qt6-qtwebengine-cross.patch

  # Jellyfin: don't build via `libsForQt5.callPackage`
  ./2023-06-06-jellyfin-no-libsForQt5-callPackage.patch

  # pin to a pre-0.17.3 release
  # removing this and using stock 0.17.3 causes:
  #   INFO lemmy_server::code_migrations: No Local Site found, creating it.
  #   Error: LemmyError { message: None, inner: duplicate key value violates unique constraint "local_site_site_id_key", context: "SpanTrace" }
  # more specifically, lemmy can't find the site because it receives an error from diesel:
  #   Err(DeserializationError("Unrecognized enum variant"))
  # this is likely some mis-ordered db migrations
  # or perhaps the whole set of migrations here isn't being running right.
  # related: <https://github.com/NixOS/nixpkgs/issues/236890#issuecomment-1585030861>
  ./2023-06-10-lemmy-downgrade.patch

  # for raspberry pi: allow building u-boot for rpi 4{,00}
  # TODO: remove after upstreamed: https://github.com/NixOS/nixpkgs/pull/176018
  #   (it's a dupe of https://github.com/NixOS/nixpkgs/pull/112677 )
  ./02-rpi4-uboot.patch

  # ./07-duplicity-rich-url.patch
]
