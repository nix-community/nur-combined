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
  # https://github.com/jellyfin/jellyfin/issues/7642
  jellyfin-ffmpeg = super.jellyfin-ffmpeg.override (optionalAttrs (config.services.jellyfin.enable or false) {
    ffmpeg_5-full = super.ffmpeg_5-full.override {
      libva = let
        mesa = super.mesa.overrideAttrs (oldAttrs: rec {
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ super.gnused ];
          # https://github.com/jellyfin/jellyfin-ffmpeg/blob/jellyfin/docker-build.sh
          postPatch = ''
            ${oldAttrs.postPatch}
            # fix the invalid modifier issue on amd apu
            MESA_SI_TEX="./src/gallium/drivers/radeonsi/si_texture.c"
	          sed -i 's|(struct si_texture \*)screen->resource_create(screen, \&templ)|(struct si_texture\*)((tex->surface.modifier==DRM_FORMAT_MOD_INVALID\|\|!screen->resource_create_with_modifiers)?screen->resource_create(screen,\&templ):screen->resource_create_with_modifiers(screen,\&templ,\&tex->surface.modifier,1))|g' $MESA_SI_TEX
            # disable the broken hevc packed header
            MESA_VA_PIC="./src/gallium/frontends/va/picture.c"
            MESA_VA_CONF="./src/gallium/frontends/va/config.c"
            sed -i 's|handleVAEncPackedHeaderParameterBufferType(context, buf);||g' $MESA_VA_PIC
            sed -i 's|handleVAEncPackedHeaderDataBufferType(context, buf);||g' $MESA_VA_PIC
            sed -i 's|if (u_reduce_video_profile(ProfileToPipe(profile)) == PIPE_VIDEO_FORMAT_HEVC)|if (0)|g' $MESA_VA_CONF
            # force reporting all packed headers are supported
            sed -i 's|value = VA_ENC_PACKED_HEADER_NONE;|value = 0x0000001f;|g' $MESA_VA_CONF
            sed -i 's|if (attrib_list\[i\].type == VAConfigAttribEncPackedHeaders)|if (0)|g' $MESA_VA_CONF
          '';
        });
      in super.libva.overrideAttrs (oldAttrs: rec {
        mesonFlags = [ "-Ddriverdir=${mesa.drivers}/lib/dri" ];
      });
    };
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
