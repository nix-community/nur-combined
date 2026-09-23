{
  fcitx5,
  fetchpatch,
}:
fcitx5.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/wrvsrx/fcitx5/compare/5.1.22..5.1.22+wayland-flush.diff";
      hash = "sha256-Fxrw/u8wd+He4lpk4OlzJ5EgHxzHQ1/eBcRTHbstpiw=";
    })
    (fetchpatch {
      # https://github.com/nix-community/stylix/pull/2503
      url = "https://github.com/fcitx/fcitx5/compare/41d6d98dbbc38f351f9707bc99ee3c59941193f0.diff";
      hash = "sha256-osBaEk+I8gixvFk8p5HEzY3QgO2dgvjHKljUacDbO0o=";
    })
  ];
})
