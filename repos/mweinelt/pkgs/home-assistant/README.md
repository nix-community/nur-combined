# Home-Assistant

## Lovelace Modules

Installation example:


```nix
{ ... }:
let
  nur = import (builtins.fetchTarball "https://github.com/mweinelt/nur-packages/archive/master.tar.gz") {};
in {
  # Custom Lovelace Modules
  systemd.tmpfiles.rules = [
    "d /var/lib/hass/www 0755 hass hass"
    "L /var/lib/hass/www/mini-graph-card.js - - - - ${nur.hassLovelaceModules.mini-graph-card}/mini-graph-card-bundle.js"
    "L /var/lib/hass/www/mini-media-player.js - - - - ${nur.hassLovelaceModules.mini-media-player}/mini-media-player-bundle.js"
  ];

  services.home-assistant.lovelaceConfig.resources = [
    { url = "local/mini-graph-card-bundle.js";
      type = "module"; }
    { url = "local/mini-media-player-bundle.js";
      type = "module"; }
  ];
}
```

