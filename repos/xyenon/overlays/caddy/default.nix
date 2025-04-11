_final: prev: {
  caddy = prev.nur.repos.xyenon.caddyWithPlugins.override { caddyOrig = prev.caddy; };
}
