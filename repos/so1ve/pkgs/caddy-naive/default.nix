{
  caddy,
  callPackage,
  source ? callPackage ./source.nix { },
}:

(caddy.withPlugins {
  inherit (source) plugins hash;
}).overrideAttrs
  (old: {
    pname = "caddy-naive";

    # Backport the idle-timeout API required by NaïveProxy to Caddy 2.11.7.
    postPatch = (old.postPatch or "") + ''
      patch -d vendor/github.com/caddyserver/caddy/v2 -p1 < ${source.patch}
    '';

    meta = old.meta // {
      description = "Caddy with the NaïveProxy forward proxy plugin";
      homepage = "https://github.com/klzgrad/naiveproxy";
    };
  })
