{ wechat-uos }:
wechat-uos.override (old: {
  buildFHSEnv =
    x:
    old.buildFHSEnv (
      x
      // {
        extraPreBwrapCmds = ''
          mkdir -p ''${XDG_DATA_HOME}/wechat/home
          mkdir -p ''${XDG_DATA_HOME}/wechat/xwechat_files
        '';
        extraBwrapArgs = [
          # create a custom home dir
          "--dir \${HOME}"
          "--bind \${XDG_DATA_HOME}/wechat/home \${HOME}"

          "--dir $(dirname \${XAUTHORITY})"
          "--bind \${XAUTHORITY} \${XAUTHORITY}"

          "--dir \${XDG_CONFIG_HOME}"
          "--bind \${XDG_CONFIG_HOME}/user-dirs.dirs \${XDG_CONFIG_HOME}/user-dirs.dirs"

          # bind to XDG_DOWNLOAD_DIR
          "--dir \${XDG_DOWNLOAD_DIR}"
          "--bind \${XDG_DOWNLOAD_DIR} \${XDG_DOWNLOAD_DIR}"

          # bind to xwechat_files
          "--dir \${XDG_DOCUMENTS_DIR}/xwechat_files"
          "--bind \${XDG_DATA_HOME}/wechat/xwechat_files \${XDG_DOCUMENTS_DIR}/xwechat_files"

          # change dir to HOME
          "--chdir \${HOME}"
        ];
      }
    );
})
