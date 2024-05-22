{ chmlib, lib, ... }:
chmlib.overrideAttrs (oldAttrs: {
  configureFlags = [ "--enable-examples=yes" ];

  meta = oldAttrs.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
