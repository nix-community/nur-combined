final: prev: {
  caddy = prev.caddy.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./multipassword.patch ];
    passthru = old.passthru // {
      withPlugins = throw "pkgs.caddy.withPlugins doesnt work with patches";
    };
  });
}
