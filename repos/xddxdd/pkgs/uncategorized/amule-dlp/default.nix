{
  sources,
  lib,
  amule,
  ...
}:
amule.overrideAttrs (old: {
  inherit (sources.amule-dlp) pname version src;
  patches = [ ];

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
