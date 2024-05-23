{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fcitx5-tokyonight";
  version = "unstable-2024-01-28";

  src = fetchFromGitHub {
    owner = "ch3n9w";
    repo = "fcitx5-Tokyonight";
    rev = "f7454ab387d6b071ee12ff7ee819f0c7030fdf2c";
    hash = "sha256-swOy0kDZUdqtC2sPSZEBLnHSs8dpQ/QfFMObI6BARfo=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 Tokyonight-Day/{arrow.png,panel.png,radio.png} -t $out/share/${finalAttrs.pname}/
    for _variant in Tokyonight-Day Tokyonight-Storm; do
      mkdir -p $out/share/fcitx5/themes/$_variant/
      ln -s $out/share/${finalAttrs.pname}/arrow.png $out/share/fcitx5/themes/$_variant/arrow.png
      ln -s $out/share/${finalAttrs.pname}/radio.png $out/share/fcitx5/themes/$_variant/radio.png
      install -Dm644 $_variant/theme.conf $out/share/fcitx5/themes/$_variant/theme.conf
    done

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    description = "Fcitx5 theme using TokyoNight colorscheme";
    homepage = "https://github.com/ch3n9w/fcitx5-Tokyonight";
    license = lib.getLicenseFromSpdxId "GPL-3.0-only";
    platforms = lib.platforms.all;
  };
})
