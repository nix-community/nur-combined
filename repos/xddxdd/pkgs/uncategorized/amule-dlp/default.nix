{
  lib,
  sources,
  amule,
  ...
}:
amule.overrideAttrs (old: {
  inherit (sources.amule-dlp) pname version src;
  patches = [];
})
