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
        "https://git.uninsane.org/colin/nixpkgs/commit/${saneCommit}.patch?full_index=1"
      ;
    in fetchpatch2 (
      { inherit revert url; }
      // (if hash != null then { inherit hash; } else {})
      // (if name != null then { inherit name; } else {})
    );
in
[
  (fetchpatch' {
    name = "xarchiver: build with strictDeps=true";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/406599";
    hash = "sha256-xaI6YEGuxZaYtaTbfeTK9cr2ELhWnrO+Azic5aG6XbE=";
  })
  (fetchpatch' {
    # 2025-05-03: merged into staging
    name = "qt6.{qttools,qtwayland}: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/403830";
    hash = "sha256-NaDHdsfKY3Gg3RJTMgbHYqnezdLuei/71d0d+/cubmE=";
  })

  (fetchpatch' {
    # 2025-05-03: merged into staging
    name = "qt6.qttranslations: bootstrap directly";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/403944";
    hash = "sha256-ZjEGozWbxfplMGU61ohTkqjDmhZRvVildXx6TWlHhvQ=";
  })

  (fetchpatch' {
    # 2025-05-02: merged into staging
    name = "fcitx5: fix cross compilation";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/399981";
    hash = "sha256-BSnp80+8cpb+1yFaB0g7ZnPgQQqC7qo+ReMJUtlKgr4=";
  })

  (fetchpatch' {
    # 2025-05-02: merged into staging
    name = "psqlodbc: fix cross";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/403706";
    hash = "sha256-VKX8RpD8V0tYC6w0O97iJN1r8nVRRSU1FCY3hXlfZoc=";
  })

  (fetchpatch' {
    # 2025-05-04: merged into staging
    name = "libcdio: omit manpages when cross compiling";
    # saneCommit = "2248d99b4edb7b01b667139f16949367773bf03a";
    # hash = "sha256-OjK34Mo/5JXFNn4rBFhWq8wfeHItM6zzDodMPBYyERY=";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/404076";  #< someone else's fix (worse though :P)
    hash = "sha256-pP4rnz8vskuVC5hkoGORVpcW3/kFF3m4gSW25H4TJvg=";
  })

  (fetchpatch' {
    name = "zelda64recomp: init at 1.2.0";
    prUrl = "https://github.com/NixOS/nixpkgs/pull/313013";
    hash = "sha256-zCZmR+ffSd6WXoRmaorMNrJsdithC2hXzGOYcZAzZjc=";
  })

  # (fetchpatch' {
  #   # XXX(2025-01-06): patch does not produce valid binaries for cross
  #   name = "lua-language-server: fix cross compiling";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/370992";
  #   hash = "sha256-jW66W1V3upZMfbjuoruY3OGNJfEewx7DW/Z4vAhMEXw=";
  # })

  # (fetchpatch' {
  #   # patch should be safe to remove; keeping it here to track the upstreaming status
  #   name = "nixos/gitea: don't configure the database if `createDatabase == false`";
  #   prUrl = "https://github.com/NixOS/nixpkgs/pull/268849";
  #   # saneCommit = "92662a9920cf8b70ad8a061591dc37146123bde3";
  #   hash = "sha256-Bmy1xqqmHqJVpleKWOssF+6SUpKOIm6hIGQsW6+hUTg=";
  # })

  # (fetchpatch' {
  #   # TODO: send to upstream nixpkgs once tested (branch: lappy: pr-stepmania-wrapper)
  #   name = "stepmania: wrap the program so it knows where to find its data files";
  #   saneCommit = "e2022b4caab6dcf031841fcf48752ebeb6837978";
  #   hash = "sha256-43zxnbUJuGXThadHoQRi6cevD7SFSZejWj324V6eBpw=";
  # })

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
]
