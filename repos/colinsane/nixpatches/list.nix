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
  # if a patch has been merged, use
  #   merged.staging = "<date>";
  #   merged.master = "<date>";
  # etc, where "date" is like "20240228181608"
  # and can be found with `nix-repl  > :lf .  > lastModifiedDate`

  (fetchpatch' {
    # NECESSARY FOR DINO CALLS TO WORK ON AARCH64: <https://gitlab.freedesktop.org/gstreamer/orc/-/issues/64>
    prUrl = "https://github.com/NixOS/nixpkgs/pull/291661";
    title = "orc: 0.4.36 -> 0.4.38";
    hash = "sha256-ULav0vt3QlI8lKcCVKP986H/GjBZqUYLwOHJ3XppAeo=";
    merged.staging = "20240406000000";
    merged.staging-next = "20240418000000";
  })

  (fetchpatch' {
    prUrl = "https://github.com/NixOS/nixpkgs/pull/298001";
    saneCommit = "d599839060400762a67d2c01d15b102ffe75e703";
    title = "gnupg: fix cross compilation";
    hash = "sha256-d3kD2/UyMzzdBkiEdWtCibbWiPWBZLUWRry1TMkS25g=";
    merged.staging = "20240326000000";
    merged.staging-next = "20240418000000";
  })

  (fetchpatch' {
    prUrl = "https://github.com/NixOS/nixpkgs/pull/292415";
    title = "sway/hyprland: cross compilation fixes";
    hash = "sha256-IDf8OcZzFgw0DalxzBqbqP7TZVnZkzoRHQ51RlR1xWc=";
  })

  (fetchpatch' {
    title = "gcr: remove build gnupg from runtime closure";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/263158";
    saneCommit = "8c71ab22c6df4e5ce290e131a7769688b0c5a017";
    # hash = "sha256-9PNKzNlJ62WAq6H+tqlt0spFZ1DPP1hHmpx0YPuieFE=";
    hash = "sha256-6hUdsExHSMHy6FMY1+OLtVmKpRwysGIVkcDpYv7RRBk=";
  })

  # 2024/02/25: still outstanding; merge conflicts
  # (fetchpatch' {
  #   title = "hspell: remove build perl from runtime closure";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/263182";
  #   hash = "sha256-Wau+PB+EUQDvWX8Kycw1sNrM3GkPVjKSS4niIDI0sjM=";
  # })

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
  # (fetchpatch' {
  #   title = "rpm: 4.18.1 -> 4.19.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/260558";
  #   hash = "sha256-kwod+6SbUZechzbmu1D4Hlh6pYiPD18wcqetk0OIOrA=";
  # })

  # (fetchpatch' {
  #   # XXX: doesn't cleanly apply; fetch `firefox-pmos-mobile` branch from my git instead
  #   title = "firefox-pmos-mobile: init at -pmos-2.2.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/121356";
  #   hash = "sha256-eDsR1cJC/IMmhJl5wERpTB1VGawcnMw/gck9sI64GtQ=";
  # })

  # (fetchpatch' {
  #   title = "firefox-pmos-mobile: init at 4.0.2";
  #   saneCommit = "c3becd7cdf144d85d12e2e76663e9549a0536efd";
  #   hash = "sha256-fQdKm5kIFzheEUgSkwxrivynJk221suigWJ/WxZJ0Zk=";
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

  # (fetchpatch {
  #   # stdenv: fix cc for pseudo-crosscompilation
  #   # closed because it breaks pkgsStatic (as of 2023/02/12)
  #   url = "https://github.com/NixOS/nixpkgs/pull/196497.diff";
  #   hash = "sha256-eTwEbVULYjmOW7zUFcTUqvBZqUFjHTKFhvmU2m3XQeo=";
  # })

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
    hash = "sha256-RUw88u7CI2C1IpRUhGbdYamHsPT1jBV0ROyVvzLWdv8=";
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
    hash = "sha256-UyZaNNp84zKShuo6zu0nfZ2FygHGcmV63Ww4Y4CtCF0=";
  })

  (fetchpatch' {
    title = "libgweather: enable introspection on cross builds";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/251956";
    saneCommit = "7a2d0a90cc558ea71dfc78356e61b0675b995634";
    hash = "sha256-4x1yJgrgmyqYiF+u3A9BrcbNQPQ270c+/jFBYsJoFfI=";
  })

  # for raspberry pi: allow building u-boot for rpi 4{,00}
  # TODO: remove after upstreamed: https://github.com/NixOS/nixpkgs/pull/176018
  #   (it's a dupe of https://github.com/NixOS/nixpkgs/pull/112677 )
  ./02-rpi4-uboot.patch

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
