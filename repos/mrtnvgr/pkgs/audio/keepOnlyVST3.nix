_:
drv:
drv.overrideAttrs (oldAttrs: {
  postInstall = (oldAttrs.postInstall or "") + ''
    rm -rf "$out/bin"
    rm -rf "$out/lib/vst2"
    rm -rf "$out/lib/clap"
    rm -rf "$out/lib/lv2"
  '';
})
