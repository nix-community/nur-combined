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
  # https://github.com/NixOS/nixpkgs/issues/87667
  qmmp = super.qmmp.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ super.wrapGAppsHook ];
    dontWrapGApps = true;
    preFixup = ''
      qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
    '';
  });
  # https://github.com/emersion/mako/issues/154
  mako = super.mako.overrideAttrs (oldAttrs: {
    NIX_CFLAGS_COMPILE = "-Wno-error=unused-function";
    postUnpack = ''
      substituteInPlace source/dbus/xdg.c \
        --replace 'SD_BUS_METHOD("CloseNotification", "u", "", handle_close_notification, SD_BUS_VTABLE_UNPRIVILEGED),' ""
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
