{ pkgs, config ? null }:

self: super: with super.lib;
rec {
  dtrx = super.dtrx.override {
    unzipSupport = true;
    unrarSupport = true;
  };
  # https://github.com/jellyfin/jellyfin/issues/7642
  jellyfin-ffmpeg = super.jellyfin-ffmpeg.override {
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
  };
  # https://github.com/swaywm/sway/issues/3111#issuecomment-508958733
  sway-unwrapped = super.sway-unwrapped.overrideAttrs (oldAttrs: rec {
    postUnpack = ''
      substituteInPlace source/sway/commands/bind.c \
        --replace "if ((binding->flags & BINDING_CODE) == 0) {" "if (false) {"
    '';
  });
} // optionalAttrs (config.hardware.regdomain.enable or false) {
  inherit (pkgs.nur.repos.dukzcry) wireless-regdb;
  crda = super.crda.overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.nur.repos.dukzcry.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
}
