{ pkgs, config ? null }:

self: super: with super.lib;
rec {
  dtrx = super.dtrx.override {
    unzipSupport = true;
    unrarSupport = true;
  };
  lmms = super.lmms.overrideAttrs (oldAttrs: optionalAttrs (config.services.jack.enable or config.services.pipewire.jack.enable or false) {
    cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWANT_WEAKJACK=OFF" ];
  });
  evolution = super.symlinkJoin {
    name = "evolution-without-background-processes";
    paths = with super; [
      (writeShellScriptBin "evolution" ''
        ${super.evolution}/bin/evolution "$@"
        ${super.evolution}/bin/evolution --force-shutdown
      '')
      super.evolution
    ];
  };
  ddccontrol = super.ddccontrol.overrideAttrs (oldAttrs: {
    prePatch = ''
      ${oldAttrs.prePatch}
      substituteInPlace src/gddccontrol/notebook.c \
        --replace "if (mon->fallback)" "if (0)"
    '';
  });
  autorandr = super.autorandr.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [ ./autorandr.patch ];
  });
  remmina = super.remmina.override (optionalAttrs (config.services.hardware.remminaLegacy or false) {
    freerdp = super.freerdp.override {
      ffmpeg = super.ffmpeg.override {
        libva = let
          mesa = super.mesa.override {
            enablePatentEncumberedCodecs = false;
          };
          in super.libva.overrideAttrs (oldAttrs: rec {
            mesonFlags = [ "-Ddriverdir=${mesa.drivers}/lib/dri" ];
          });
      };
    };
  });
} // optionalAttrs (config.hardware.regdomain.enable or false) {
  inherit (pkgs.nur.repos.dukzcry) wireless-regdb;
  crda = super.crda.overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
}
