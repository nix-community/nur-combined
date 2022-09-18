{ sources
, qbittorrent
, ...
} @ args:

qbittorrent.overrideAttrs (old: {
  inherit (sources.qbittorrent-enhanced-edition) pname version src;
})
