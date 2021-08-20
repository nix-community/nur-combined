{ unstable, config }:

self: super:
rec {
  dtrx = super.dtrx.overrideAttrs (oldAttrs: {
    postFixup = ''
      ${oldAttrs.postFixup}
      wrapProgram $out/bin/dtrx \
        --prefix PATH : "${super.lib.makeBinPath [ super.unrar ]}"
    '';
  });
  # JUST UPDATE RELEASE
  inherit (unstable) steam goldendict ddccontrol;
  #lmms = super.lmms.overrideAttrs (oldAttrs: rec {
  #  cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWANT_WEAKJACK=OFF" ];
  #});
}
