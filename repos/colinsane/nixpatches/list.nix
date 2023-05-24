{ fetchpatch, fetchurl }:
let
  fetchpatch' = {
    saneCommit ? null,
    prUrl ? null,
    hash ? null
  }:
    let
      url = if prUrl != null then
        # prUrl takes precedence over any specific commit
        "${prUrl}.diff"
      else
        "https://git.uninsane.org/colin/nixpkgs/commit/${saneCommit}.diff"
      ;
    in fetchpatch ({ inherit url; } // (if hash != null then { inherit hash; } else {}));
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

  # 2023-04-11: bambu-studio: init at unstable-2023-01-11
  (fetchpatch' {
    prUrl = "https://github.com/NixOS/nixpkgs/pull/206495";
    hash = "sha256-RbQzAtFTr7Nrk2YBcHpKQMYoPlFMVSXNl96B/lkKluQ=";
  })

  # update to newer lemmy-server.
  # should be removable when > 0.17.2 releases?
  # removing this now causes:
  #   INFO lemmy_server::code_migrations: No Local Site found, creating it.
  #   Error: LemmyError { message: None, inner: duplicate key value violates unique constraint "local_site_site_id_key", context: "SpanTrace" }
  # though perhaps this error doesn't occur on fresh databases (idk).
  ./2023-04-29-lemmy.patch

  (fetchpatch' {
    # cargo-docset: init at 0.3.1
    saneCommit = "5a09e84c6159ce545029483384580708bc04c08f";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/231188";
    hash = "sha256-Z1HOps3w/WvxAiyUAHWszKqwS9EwA6rf4XfgPGp+2sQ=";
  })

  (fetchpatch' {
    # nixos/lemmy: support nginx
    saneCommit = "4c86db6dcb78795ac9bb514d9c779fd591070b23";
    hash = "sha256-G7jGhSPUp9BMxh2yTzo0KUUVabMJeZ28YTA+0iPldRI=";
  })

  (fetchpatch' {
    # feedbackd: 0.1.0 -> 0.2.0
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
    # 2023-02-18: conky: 1.13.1 -> 1.18.0
    prUrl = "https://github.com/NixOS/nixpkgs/pull/217224";
    hash = "sha256-+g3XhmBt/udhbBDiVyfWnfXKvZTvDurlvPblQ9HYp3s=";
  })

  # (fetchpatch' {
  #   # harec: support pkgsCross cross-compilation
  #   saneCommit = "6f77961e94fe736b2f9963dd9c6411b36f8bb9c5";
  #   hash = "sha256-3QmV7ihPBEdLDGfJQBN+J/A3DpzpGFjzggsXLbr3hOE=";
  # })

  # (fetchpatch' {
  #   # hare: unstable-2023-03-15 -> unstable-2023-04-23
  #   saneCommit = "cdea9097fd6afb43751e42f1cd1b50e2bffb4d58";
  #   hash = "sha256-33LoktURM81bLsfY3v+SHL30Qju9GyOMCXVbsGrgOjU=";
  # })

  # (fetchpatch' {
  #   # harec: unstable-2023-02-18 -> unstable-2023-04-25
  #   saneCommit = "5595e88de982474ba6cc9c4d7f4a7a246edb4980";
  #   hash = "sha256-kKhygKpf3QqQR0kSxutKwZXbNcsSTp/z165h88J8/+g=";
  # })

  (fetchpatch' {
    # hare: unstable-2023-03-15 -> unstable-2023-04-23
    # + harec: unstable-2023-02-18 -> unstable-2023-04-25
    prUrl = "https://github.com/NixOS/nixpkgs/pull/233732";
    hash = "sha256-SGDKvsMiK3Pq57JEj/MamDBX5jBXwV/E5jclKO2NAUs=";
  })

  # for raspberry pi: allow building u-boot for rpi 4{,00}
  # TODO: remove after upstreamed: https://github.com/NixOS/nixpkgs/pull/176018
  #   (it's a dupe of https://github.com/NixOS/nixpkgs/pull/112677 )
  ./02-rpi4-uboot.patch

  # ./07-duplicity-rich-url.patch
]
