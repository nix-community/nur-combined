{ chmlib, lib, ... }:
chmlib.overrideAttrs (oldAttrs: {
  configureFlags = [ "--enable-examples=yes" ];

  meta = oldAttrs.meta // {
    mainProgram = "extract_chmLib";
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
