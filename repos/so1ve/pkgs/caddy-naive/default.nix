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

    meta = old.meta // {
      description = "Caddy with the NaïveProxy forward proxy plugin";
      homepage = "https://github.com/klzgrad/naiveproxy";
    };
  })
