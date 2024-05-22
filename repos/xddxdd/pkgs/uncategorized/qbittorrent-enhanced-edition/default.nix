{
  sources,
  lib,
  qbittorrent,
  ...
}:
qbittorrent.overrideAttrs (old: {
  inherit (sources.qbittorrent-enhanced-edition) pname version src;

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
