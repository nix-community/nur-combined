{
  sources,
  lib,
  librime,
  librime-lua,
  librime-octagram,
}:
(librime.override {
  plugins = [
    librime-lua
    librime-octagram
    (sources.librime-charcode.src.overrideAttrs (_old: {
      name = "librime-charcode";
    }))
    (sources.librime-proto.src.overrideAttrs (_old: {
      name = "librime-proto";
    }))
  ];
}).overrideAttrs
  (old: {
    meta = old.meta // {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Librime with plugins (librime-charcode, librime-lua, librime-octagram, librime-proto)";
      mainProgram = "rime_deployer";
    };
  })
