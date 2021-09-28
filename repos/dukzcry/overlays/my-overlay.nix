{ unstable, config }:

self: super:
rec {
  dtrx = (super.dtrx.override { unzipSupport = true; }).overrideAttrs (oldAttrs: {
    postFixup = ''
      ${oldAttrs.postFixup}
      wrapProgram $out/bin/dtrx \
        --prefix PATH : "${super.lib.makeBinPath [ super.unrar ]}"
    '';
  });
  #lmms = super.lmms.overrideAttrs (oldAttrs: rec {
  #  cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWANT_WEAKJACK=OFF" ];
  #});
}
