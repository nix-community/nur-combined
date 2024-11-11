{
  sources,
  lib,
  amule,
}:
amule.overrideAttrs (old: {
  inherit (sources.amule-dlp) pname version src;
  patches = [ ];

  meta = old.meta // {
    mainProgram = "amule";
    maintainers = with lib.maintainers; [ xddxdd ];
    homepage = "https://github.com/persmule/amule-dlp";
    description = old.meta.description + " (with Dynamic Leech Protection)";
  };
})
