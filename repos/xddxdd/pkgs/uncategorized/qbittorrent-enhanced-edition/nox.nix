{ sources
, qbittorrent-nox
, ...
} @ args:

qbittorrent-nox.overrideAttrs (old: {
  inherit (sources.qbittorrent-enhanced-edition) pname version src;
})
