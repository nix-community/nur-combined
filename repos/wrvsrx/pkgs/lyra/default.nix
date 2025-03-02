{
  lyra,
  source,
}:
lyra.overrideAttrs (oldAttrs: {
  inherit (source) src;
  version = oldAttrs.version + "-unstable-" + source.date;
})
