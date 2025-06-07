{
  wpsoffice-cn,
}:
wpsoffice-cn.overrideAttrs (previousAttrs: {
  pname = "wpsoffice-cn-fcitx";
  postInstall =
    (previousAttrs.postInstall or "")
    + ''
      for exe in $out/bin/*;do
        wrapProgram $exe \
          --prefix XMODIFIERS : @im=fcitx\
          --prefix GTK_IM_MODULE : fcitx\
          --prefix QT_IM_MODULE : fcitx\
          --prefix SDL_IM_MODULE : fcitx\
          --prefix GLFW_IM_MODULE : ibus
      done
    '';
  meta = previousAttrs.meta // {
    description = "WPS Office CN with Fcitx support";
    mainProgram = "wps";
  };
})
