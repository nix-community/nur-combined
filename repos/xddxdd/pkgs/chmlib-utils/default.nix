{
  lib, stdenv,
  chmlib,
  ...
} @ args:

chmlib.overrideAttrs (oldAttrs: {
  configureFlags = [ "--enable-examples=yes" ];
})
