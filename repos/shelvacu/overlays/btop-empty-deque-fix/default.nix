final: prev: {
  # https://github.com/aristocratos/btop/pull/1939, fixes https://github.com/aristocratos/btop/issues/1949
  btop =
    if prev.btop.version == "1.4.8" then
      prev.btop.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./btop-safeback.patch ];
      })
    else
      prev.btop;
}
