{
  sable-next,
  conf ? { },
}:

sable-next.override (prev: {
  inherit conf;
  sable-next-unwrapped = prev.sable-next-unwrapped.overrideAttrs (
    final: old: {
      env = old.env // {
        VITE_SABLE_SERVER_URL = "/_sable/ws";
        VITE_SABLE_SERVER_VERSION = final.version;
      };
    }
  );
})
