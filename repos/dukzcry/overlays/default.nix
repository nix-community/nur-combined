{ pkgs, config ? null }:

self: super: with super.lib;
rec {
  dtrx = super.dtrx.override {
    unzipSupport = true;
    unrarSupport = true;
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
  # https://github.com/jellyfin/jellyfin/issues/7642
  jellyfin-ffmpeg = super.jellyfin-ffmpeg.override (optionalAttrs (config.services.jellyfin.enable or false) {
    ffmpeg_6-full = super.ffmpeg_6-full.override {
      libva = let
        mesa = super.mesa.overrideAttrs (oldAttrs: rec {
          postPatch = ''
            ${oldAttrs.postPatch}
            # https://github.com/jellyfin/jellyfin-ffmpeg/blob/v5.1.2-8/docker-build.sh#L390
            substituteInPlace src/gallium/frontends/va/config.c \
              --replace "value = VA_ENC_PACKED_HEADER_NONE;" "value = 0x0000001f;" \
              --replace "if (attrib_list[i].type == VAConfigAttribEncPackedHeaders)" "if (0)"
          '';
        });
      in super.libva.overrideAttrs (oldAttrs: rec {
        mesonFlags = [ "-Ddriverdir=${mesa.drivers}/lib/dri" ];
      });
    };
  });
  vpn-slice = super.vpn-slice.overrideAttrs (oldAttrs: optionalAttrs (config.services.job.server or false) {
    preConfigure = ''
      substituteInPlace vpn_slice/posix.py \
        --replace /etc/hosts /var/lib/dnsmasq/hosts/hosts
    '';
  });
  # https://github.com/NixOS/nixpkgs/issues/271333
  sunshine = super.sunshine.overrideAttrs (oldAttrs: optionalAttrs (config.programs.sunshine.enable or false) {
    runtimeDependencies = oldAttrs.runtimeDependencies ++ [ super.libglvnd ];
  });
} // optionalAttrs (config.hardware.regdomain.enable or false) {
  inherit (pkgs.nur.repos.dukzcry) wireless-regdb;
  crda = super.crda.overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
}
