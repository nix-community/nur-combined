{ fetchpatch2, fetchurl, lib }:
let
  fetchpatch' = {
    saneCommit ? null,
    nixpkgsCommit ? null,
    prUrl ? null,
    hash ? null,
    title ? null,
    revert ? false,
  }:
    let
      # XXX(2024-07-31): full_index=1 for reproducibility (prevent patch hashes from spontaneously changing)
      # - <https://github.com/NixOS/nixpkgs/issues/257446#issuecomment-1736563091>
      url = if prUrl != null then
        # prUrl takes precedence over any specific commit
        "${prUrl}.diff?full_index=1"
      else if saneCommit != null then
        "https://git.uninsane.org/colin/nixpkgs/commit/${saneCommit}.diff"
      else
        "https://github.com/NixOS/nixpkgs/commit/${nixpkgsCommit}.patch?full_index=1"
      ;
    in fetchpatch2 (
      { inherit revert url; }
      // (if hash != null then { inherit hash; } else {})
      // (if title != null then { name = title; } else {})
    );
in
[
  # (fetchpatch' {
  #   title = "pantheon.switchboard-plug-sound: support cross compilation";
  #   saneCommit = "86f85de8d008710a11b7b3653ec594438374059e";
  #   hash = "sha256-fGuS46f9qSMRHvWZvTmcirKufIqlXHwwhckeK1RNejE=";
  # })

  (fetchpatch' {
    title = "nixos/pam: replace apparmor warnings with assertions";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/332119";
    saneCommit = "17e5fa9dc3c6d9f1fbfa2b23f6e1ae5c7e17bebd";
    hash = "sha256-9UrJB/ijXL07H/SESquCCqI1boVoYpDcYqxD+Mx2Mwc=";
  })

  (fetchpatch' {
    # branch: pr-flatpak-cross
    title = "flatpak: support cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/334324";
    saneCommit = "0656837e8bb3aae72245145ea8b2250eadad653d";
    hash = "sha256-etogClsQ8USoBzfx8eYXUYp+C5VQ0wJs/1LumjtE+9E=";
    # hash = "sha256-Jo37TmzEbqZQVlFtLQ/hI1AAPXS0dnkXh58eHpuwT5M=";
    # hash = "sha256-/N3FQ0CZ8IOxEYci2UKOG0POYuTyCTH/ZWTRyjIOlEc=";
  })

  (fetchpatch' {
    title = "syshud: 0-unstable-2024-07-29 -> 0-unstable-2024-08-10";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/333975";
    hash = "sha256-DMV9rnigWUGW6kcV5Ve151OEArMWroLcuoK6PdFjTHk=";
  })

  (fetchpatch' {
    title = "hare-ev: 2024-07-11 -> 2024-08-06";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/333378";
    hash = "sha256-3RnqId/Rk0A5YyvsixLvKyLFOiFuvlThKdT00D6hjWI=";
  })

  # (fetchpatch' {
  #   # this causes a rebuild of systemd and everything above it:
  #   # PR against staging is live: <https://github.com/NixOS/nixpkgs/pull/332399>
  #   title = "libcap: ship the optional 'captree' component";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/332399";
  #   saneCommit = "30d6d5d6e86c490978b9615a9c685ffd92c81116";
  #   hash = "sha256-hEcpS7r1K6yb5dcj2evbWajwIQaaSHKdLPQVg1LlCYE=";
  # })

  (fetchpatch' {
    # merged into staging 2024-07-25
    title = "texinfo: set texinfo_cv_sys_iconv_converts_euc_cn=yes when crosscompiling";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/328919";
    hash = "sha256-jPbFTg5YHBxAyhOaQGuiLVximKMj7ACXzCK89ddZyNQ=";
  })

  (fetchpatch' {
    title = "python312Packages.contourpy: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/328218";
    saneCommit = "74a003b0af9820f6f7c6c62b3d2bec6df3a8d7b8";
    hash = "sha256-+7iAefzfYzAHO+f+q5JROejGjCujnwhvt8ItkU562DA=";
  })

  (fetchpatch' {
    title = "unl0kr: 2.0.0 -> 3.2.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/319126";
    hash = "sha256-8rsX4Yrrp8lKrG3nySu8vvOofbxVRzpbjYVc+AQNqLs=";
  })

  (fetchpatch' {
    title = "nixos/networkmanager: split ModemManager bits into own module";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/316824";
    hash = "sha256-1wm23pSXN+gez/LnaIRrEXsy8hWAAy70RuJ+umVnJCI=";
    # saneCommit = "23bfba9b76757ffc00fc2be810009dcf92e2eaf2";
    # hash = "sha256-cn6ihwO3MyzdpVoJoQNKAHyo8GuGvFP6vr//7r9pzjE=";
  })

  (fetchpatch' {
    title = "passt: support cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/334097";
    saneCommit = "3ef36d3aa139f94e8716b0721856c5808937c9f2";
    hash = "sha256-w50SLYDgMqNAfq4bgjrd6ugxHbb0VjvHdzhuJl0lzs4=";
  })

  # (fetchpatch' {
  #   # branch: 2024-08-11-wip-ffado-cross / pr-ffado-cross-2
  #   title = "ffado: support cross compilation";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/334096";
  #   saneCommit = "cd316aaa667b6758d6866b356f4040343ffb6f80";
  #   hash = "sha256-r0jKr65dRkVU/LPfgZqNJArs2XWEudsgyYXs5bJpgj4=";
  # })

  (fetchpatch' {
    # required for gpodder to build
    title = "python311Packages.mygpoclient: 1.8 -> 1.9";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/324734";
    hash = "sha256-W2KBnwPonYCKO4TA9+mGbknxgJaZej7iX9dFLLXf/jw=";
  })

  (fetchpatch' {
    # see: <https://github.com/NixOS/nixpkgs/pull/284562#issuecomment-2079104081>
    title = "nixos/lemmy: fix nginx backend to proxy needed headers";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/306984";
    hash = "sha256-VErGtaZjsUNNXtVESFHAmQlTLabJfZBEftL/nYcpyyE=";
    saneCommit = "bd87a38b86f889a6902a356ab415eeead881766b";
  })

  (fetchpatch' {
    title = "libgweather: enable introspection on cross builds";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/251956";
    hash = "sha256-sFuuZpq/DlgFESJhvKj8UaZiA8JGsGpVmyx1s/0OKT8=";
  })

  # (fetchpatch' {
  #   # 2024/06/08: still outstanding
  #   title = "hspell: remove build perl from runtime closure";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/263182";
  #   hash = "sha256-Wau+PB+EUQDvWX8Kycw1sNrM3GkPVjKSS4niIDI0sjM=";
  # })

  # (fetchpatch' {
  #   # TODO: send for review once hspell fix is merged <https://github.com/NixOS/nixpkgs/pull/263182>
  #   # this patch works as-is, but hspell keeps a ref to build perl and thereby pollutes this closure as well.
  #   title = "gtkspell2: support cross compilation";
  #   saneCommit = "56348833b4411e9fe2016c24c7fc4af1e3c1d28a";
  #   hash = "sha256-RUw88u7CI2C1IpRUhGbdYamHsPT1jBV0ROyVvzLWdv8=";
  # })
  # (fetchpatch' {
  #   # TODO: send for review (it should be unblocked as of 2024/05/08)
  #   title = "pidgin: support cross compilation";
  #   saneCommit = "caacbcc54e217f5ee9281422777a7f712765f71a";
  #   hash = "sha256-UyZaNNp84zKShuo6zu0nfZ2FygHGcmV63Ww4Y4CtCF0=";
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

  # (fetchpatch' {
  #   title = "gnustep: remove `rec` to support `overrideScope`";
  #   saneCommit = "69162cbf727264e50fc9d7222a03789d12644705";
  #   hash = "sha256-rD0es4uUbaLMrI9ZB2HzPmRLyu/ixNBLAFyDJtFHNko=";
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
]
