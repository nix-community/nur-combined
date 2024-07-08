{
  sources,
  lib,
  qbittorrent-nox,
  ...
}:
qbittorrent-nox.overrideAttrs (old: {
  inherit (sources.qbittorrent-enhanced-edition) pname version src;

  meta = old.meta // {
    mainProgram = "qbittorrent-nox";
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
