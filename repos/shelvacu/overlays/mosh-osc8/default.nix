final: prev: {
  # backport of https://github.com/mobile-shell/mosh/pull/1360 and https://github.com/mobile-shell/mosh/pull/1440
  mosh =
    if prev.mosh.version == "1.4.0" then
      prev.mosh.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./osc8-hyperlinks.patch ];
      })
    else
      prev.mosh;
}
