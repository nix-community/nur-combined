{
  sources,
  lib,
  librime,
  luajit,
}:
(librime.override {
  plugins = [
    (sources.librime-charcode.src.overrideAttrs (_old: {
      name = "librime-charcode";
    }))
    (sources.librime-lua.src.overrideAttrs (_old: {
      name = "librime-lua";
    }))
    (sources.librime-octagram.src.overrideAttrs (_old: {
      name = "librime-octagram";
    }))
    (sources.librime-proto.src.overrideAttrs (_old: {
      name = "librime-proto";
    }))
  ];
}).overrideAttrs
  (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ luajit ];

    meta = old.meta // {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Librime with plugins (librime-charcode, librime-lua, librime-octagram, librime-proto)";
    };
  })
