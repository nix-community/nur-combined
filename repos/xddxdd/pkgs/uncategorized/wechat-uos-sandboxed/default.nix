{
  # Use pkgs to avoid calling wechat-uos in this repo
  pkgs,
  lib,
  buildFHSEnvBubblewrap,
}:
let
  buildFHSEnvWithOverride =
    args:
    buildFHSEnvBubblewrap (
      args
      // {
        # Add these root paths to FHS sandbox to prevent WeChat from accessing them by default
        # Adapted from https://aur.archlinux.org/cgit/aur.git/tree/wechat-universal.sh?h=wechat-universal-bwrap
        extraPreBwrapCmds = ''
          # Data folder setup
          # If user has declared a custom data dir, no need to query xdg for documents dir, but always resolve that to absolute path
          if [[ "''${WECHAT_DATA_DIR}" ]]; then
              WECHAT_DATA_DIR=$(readlink -f -- "''${WECHAT_DATA_DIR}")
          else
              XDG_DOCUMENTS_DIR="''${XDG_DOCUMENTS_DIR:-$(xdg-user-dir DOCUMENTS)}"
              if [[ -z "''${XDG_DOCUMENTS_DIR}" ]]; then
                  echo 'Error: Failed to get XDG_DOCUMENTS_DIR, refuse to continue'
                  exit 1
              fi
              WECHAT_DATA_DIR="''${XDG_DOCUMENTS_DIR}/WeChat_Data"
          fi
          WECHAT_FILES_DIR="''${WECHAT_DATA_DIR}/xwechat_files"
          WECHAT_HOME_DIR="''${WECHAT_DATA_DIR}/home"
          mkdir -p "''${WECHAT_FILES_DIR}"
          mkdir -p "''${WECHAT_HOME_DIR}"
        '';
        extraBwrapArgs = [
          "--tmpfs /home"
          "--tmpfs /root"
          "--bind \${WECHAT_HOME_DIR} \${HOME}"
          "--bind \${WECHAT_FILES_DIR} \${WECHAT_FILES_DIR}"
          "--chdir $HOME"
          "--setenv QT_QPA_PLATFORM xcb"
          "--setenv QT_AUTO_SCREEN_SCALE_FACTOR 1"
        ];

        unshareUser = true;
        unshareIpc = true;
        unsharePid = true;
        unshareNet = false;
        unshareUts = true;
        unshareCgroup = true;
        privateTmp = true;

        meta = pkgs.wechat-uos.meta // {
          maintainers = with lib.maintainers; [ xddxdd ];
          description = "WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap)";
        };
      }
    );
in
pkgs.wechat-uos.override { buildFHSEnv = buildFHSEnvWithOverride; }
