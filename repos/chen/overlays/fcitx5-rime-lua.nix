final: prev:
prev.fcitx5-rime.overrideAttrs (_: {
  buildInputs = [prev.fcitx5 final.librime-lua];
})
