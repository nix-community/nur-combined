{ unstable, config }:

self: super:
rec {
  dtrx = super.dtrx.override {
    unzipSupport = true;
    unrarSupport = true;
  };
  #lmms = super.lmms.overrideAttrs (oldAttrs: rec {
  #  cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWANT_WEAKJACK=OFF" ];
  #});
}
