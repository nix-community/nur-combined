{ fcitx5-mellow-themes }:

fcitx5-mellow-themes.overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    for theme in "$out"/share/fcitx5/themes/*/theme.conf; do
      if ! grep -q '^ScaleWithDPI=' "$theme"; then
        sed -i '/^\[Metadata\]$/a ScaleWithDPI=True' "$theme"
      fi
    done
  '';
})
