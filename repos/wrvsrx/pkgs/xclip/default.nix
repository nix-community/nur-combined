{ xclip, source }:
# To fix https://github.com/astrand/xclip/issues/131
xclip.overrideAttrs (old: {
  inherit (source) src;
  version = old.version + "-unstable-" + source.date;
})
