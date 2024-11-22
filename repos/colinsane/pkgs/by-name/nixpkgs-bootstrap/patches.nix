{ fetchpatch2 }:
let
  fetchpatch' = {
    saneCommit ? null,
    nixpkgsCommit ? null,
    saneGhCommit ? null,
    prUrl ? null,
    hash ? null,
    name ? null,
    revert ? false,
  }:
    let
      # XXX(2024-07-31): full_index=1 for reproducibility (prevent patch hashes from spontaneously changing)
      # - <https://github.com/NixOS/nixpkgs/issues/257446#issuecomment-1736563091>
      url = if prUrl != null then
        # prUrl takes precedence over any specific commit
        "${prUrl}.diff?full_index=1"
      else if nixpkgsCommit != null then
        "https://github.com/NixOS/nixpkgs/commit/${nixpkgsCommit}.patch?full_index=1"
      else if saneGhCommit != null then
        "https://github.com/uninsane/nixpkgs/commit/${saneGhCommit}.patch?full_index=1"
      else
        "https://git.uninsane.org/colin/nixpkgs/commit/${saneCommit}.diff"
      ;
    in fetchpatch2 (
      { inherit revert url; }
      // (if hash != null then { inherit hash; } else {})
      // (if name != null then { inherit name; } else {})
    );
in
[
  ./2024-10-01-python-cross-resource-usage.patch

  # these patches should work, but mass rebuild w/o an urgent need for it from me
  # (fetchpatch' {
  #   name = "alsa-ucm-conf: 1.2.11 -> 1.2.12";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/347585";
  #   saneCommit = "c26fe95744d672a4a2acc881e09c607fd3e3189c";
  #   hash = "sha256-4nzTHWmAiY9HMTu07rj0RdhlK7SWshXpkoqlKHg25do=";
  # })

  (fetchpatch' {
    name = "gnome-maps: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/357238";
    hash = "sha256-o2mwpO2b4vTnoqQYAIHpxK/VOwGXR65p25x3HyDte8k=";
  })

  (fetchpatch' {
    name = "gtk4-layer-shell: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/357230";
    hash = "sha256-v4OUuzpB8kXIU25r20SKtASEUwz/tgxCQQ6WQL1I/N8=";
  })

  (fetchpatch' {
    name = "nixos/bonsaid: init";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/347818";
    # saneCommit = "bc3d311bdc11a26b8b0a95806c0ea7b80554548d";
    hash = "sha256-xCZIz7vmA/Fq0/G3tyapkdU2qIVtfueArN1qvbZ0y3w=";
  })

  (fetchpatch' {
    name = "nixos/pam: replace apparmor warnings with assertions";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/332119";
    # saneCommit = "17e5fa9dc3c6d9f1fbfa2b23f6e1ae5c7e17bebd";
    hash = "sha256-8aQ/kI5Gd78KqR1DmiXZpJMyeL2JLVW4ZAWkk8PbvEA=";
  })

  (fetchpatch' {
    # TODO: send to upstream nixpkgs once tested (branch: lappy: pr-stepmania-wrapper)
    name = "stepmania: wrap the program so it knows where to find its data files";
    saneCommit = "e2022b4caab6dcf031841fcf48752ebeb6837978";
    hash = "sha256-43zxnbUJuGXThadHoQRi6cevD7SFSZejWj324V6eBpw=";
  })

  (fetchpatch' {
    name = "procs: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/346310";
    saneCommit = "b552249a1884b239337d21d4f75d4d81a2251ace";
    hash = "sha256-xkT86fa0KNBE00gtIa0qqXVV6cU7SJ9X/dxPPrik+Ps=";
  })

  (fetchpatch' {
    name = "libpeas2: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/345305";
    saneGhCommit = "7062afb2ff428fa0ee8b5635ae06d5adb6fbb396";
    hash = "sha256-rvJLYnmZIr1WYzcZG6gGj/5bNPBRA3Vw/RslhGFjnR4=";
  })

  (fetchpatch' {
    name = "Add package sm64coopdx";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/344305";
    hash = "sha256-46KFQ7p0QMZVOJRr207LNPHyA0RGVOgWgNn01BklNfg=";
  })

  # (fetchpatch' {
  #   # this causes a rebuild of systemd and everything above it:
  #   # PR against staging is live: <https://github.com/NixOS/nixpkgs/pull/332399>
  #   name = "libcap: ship the optional 'captree' component";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/332399";
  #   saneCommit = "30d6d5d6e86c490978b9615a9c685ffd92c81116";
  #   hash = "sha256-hEcpS7r1K6yb5dcj2evbWajwIQaaSHKdLPQVg1LlCYE=";
  # })

  (fetchpatch' {
    name = "python312Packages.contourpy: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/328218";
    saneCommit = "74a003b0af9820f6f7c6c62b3d2bec6df3a8d7b8";
    hash = "sha256-+7iAefzfYzAHO+f+q5JROejGjCujnwhvt8ItkU562DA=";
  })

  # (fetchpatch' {
  #   name = "unl0kr: 2.0.0 -> 3.2.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/319126";
  #   hash = "sha256-frSOcOQs6n+++w95DWz92H8SVwrs8ZJyJ1KHwOQ6ql8=";
  # })

  (fetchpatch' {
    name = "nixos/networkmanager: split ModemManager bits into own module";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/316824";
    hash = "sha256-1wm23pSXN+gez/LnaIRrEXsy8hWAAy70RuJ+umVnJCI=";
    # saneCommit = "23bfba9b76757ffc00fc2be810009dcf92e2eaf2";
    # hash = "sha256-cn6ihwO3MyzdpVoJoQNKAHyo8GuGvFP6vr//7r9pzjE=";
  })

  # (fetchpatch' {
  #   # branch: 2024-08-11-wip-ffado-cross / pr-ffado-cross-2
  #   name = "ffado: support cross compilation";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/334096";
  #   saneCommit = "cd316aaa667b6758d6866b356f4040343ffb6f80";
  #   hash = "sha256-r0jKr65dRkVU/LPfgZqNJArs2XWEudsgyYXs5bJpgj4=";
  # })

  (fetchpatch' {
    # see: <https://github.com/NixOS/nixpkgs/pull/284562#issuecomment-2079104081>
    name = "nixos/lemmy: fix nginx backend to proxy needed headers";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/306984";
    hash = "sha256-VErGtaZjsUNNXtVESFHAmQlTLabJfZBEftL/nYcpyyE=";
    saneCommit = "bd87a38b86f889a6902a356ab415eeead881766b";
  })

  # (fetchpatch' {
  #   # TODO: send for review once hspell fix is merged <https://github.com/NixOS/nixpkgs/pull/263182>
  #   # this patch works as-is, but hspell keeps a ref to build perl and thereby pollutes this closure as well.
  #   name = "gtkspell2: support cross compilation";
  #   saneCommit = "56348833b4411e9fe2016c24c7fc4af1e3c1d28a";
  #   hash = "sha256-RUw88u7CI2C1IpRUhGbdYamHsPT1jBV0ROyVvzLWdv8=";
  # })
  # (fetchpatch' {
  #   # TODO: send for review (it should be unblocked as of 2024/05/08)
  #   name = "pidgin: support cross compilation";
  #   saneCommit = "caacbcc54e217f5ee9281422777a7f712765f71a";
  #   hash = "sha256-UyZaNNp84zKShuo6zu0nfZ2FygHGcmV63Ww4Y4CtCF0=";
  # })

  # (fetchpatch' {
  #   name = "rpm: 4.18.1 -> 4.19.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/260558";
  #   hash = "sha256-kwod+6SbUZechzbmu1D4Hlh6pYiPD18wcqetk0OIOrA=";
  # })

  # (fetchpatch' {
  #   # XXX: doesn't cleanly apply; fetch `firefox-pmos-mobile` branch from my git instead
  #   name = "firefox-pmos-mobile: init at -pmos-2.2.0";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/121356";
  #   hash = "sha256-eDsR1cJC/IMmhJl5wERpTB1VGawcnMw/gck9sI64GtQ=";
  # })

  # (fetchpatch' {
  #   name = "firefox-pmos-mobile: init at 4.0.2";
  #   saneCommit = "c3becd7cdf144d85d12e2e76663e9549a0536efd";
  #   hash = "sha256-fQdKm5kIFzheEUgSkwxrivynJk221suigWJ/WxZJ0Zk=";
  # })
  # (fetchpatch' {
  #   saneCommit = "70c12451b783d6310ab90229728d63e8a903c8cb";
  #   name = "firefox-pmos-mobile: init at -pmos-2.2.0";
  #   hash = "sha256-mA22g3ZIERVctq8Uk5nuEsS1JprxA+3DvukJMDTOyso=";
  # })
  # (fetchpatch' {
  #   saneCommit = "ee19a28aa188bb87df836a4edc7b73355b8766eb";
  #   name = "firefox-pmos-mobile: format the generated policies.nix file";
  #   hash = "sha256-K8b3QpyVEjajilB5w4F1UHGDRGlmN7i66lP7SwLZpWI=";
  # })
  # (fetchpatch' {
  #   saneCommit = "c068439c701c160ba15b6ed5abe9cf09b159d584";
  #   name = "firefox-pmos-mobile: implement an updateScript";
  #   hash = "sha256-afiGDHbZIVR3kJuWABox2dakyiRb/8EgDr39esqwcEk=";
  # })
  # (fetchpatch' {
  #   saneCommit = "865c9849a9f7bd048e066c2efd8068ecddd48e33";
  #   name = "firefox-pmos-mobile: 2.2.0 -> 4.0.2";
  #   hash = "sha256-WjWSW0qE+cypvUkDRfK7d9Te8m5zQXwF33z8nEhbvrE=";
  # })
  # (fetchpatch' {
  #   saneCommit = "eb6aae632c55ce7b0a76bca549c09da5e1f7761b";
  #   name = "firefox-pmos-mobile: refactor and populate `passthru` to aid external consumers";
  #   hash = "sha256-/LhbwXjC8vuKzIuGQ3/FGplbLllsz57nR5y+PeDjGuA=";
  # })
  # (fetchpatch' {
  #   saneCommit = "c9b90ef1e17ea21ac779a86994e5d9079a2057b9";
  #   name = "librewolf-pmos-mobile: init";
  #   hash = "sha256-oQEM3EZfAOmfZzDu9faCqyOFZsdHYGn1mVBgkxt68Zg=";
  # })

  # these probably work, but i don't use them
  # (fetchpatch' {
  #   name = "networkmanager-openvpn: support cross compilation";
  #   saneCommit = "6f53c267fbeb2ff543f075032a7e73af2d4bcb9e";
  #   hash = "sha256-gq9AyKH7/k2ZVSZ3jpPJPt3uAM+CllXQnaiC1tE1r/8=";
  # })
  # (fetchpatch' {
  #   name = "WIP: networkmanager-sstp: support cross compilation";
  #   saneCommit = "6de63fe320406ec9a509db721c52b3894a93bda2";
  #   hash = "sha256-EY3bQuv/80JbpquUJhc89CcYAgN9A9KkpsSitw/684I=";
  # })
  # (fetchpatch' {
  #   name = "WIP: networkmanager-l2tp: support cross compilation";
  #   saneCommit = "7a4191c570b0e5a1ab257222c26a4a2ecb945037";
  #   hash = "sha256-FiPJhHGqZ8MFwLY+1t6HgbK6ndomFSYUKvApvrikRHE=";
  # })
]
