{
  user,
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.sessionVariables = {
    # SYSTEMD_LOG_LEVEL = "debug";
    EDITOR = "hx";
    NIXOS_OZONE_WL = "1";
    # Steam needs this to find Proton-GE
    AWS_SHARED_CREDENTIALS_FILE = config.age.secrets.aws-s3-cred.path;
    GOPATH = "\${HOME}/.cache/go";
    QT_IM_MODULES = "fcitx;wayland";
    # NIX_CFLAGS_COMPILE = "--verbose";
    # NIX_CFLAGS_LINK = "--verbose";
    # NIX_LDFLAGS = "--verbose";
    # WLR_RENDERER = "vulkan";
    PATH = [ "/home/${user}/.npm-packages/bin" ];
    RAD_HOME = "/home/${user}/.local/share/radicle";
    NTFY_AUTH_FILE = config.services.ntfy-sh.settings.auth-file or "";
    # LD_LIBRARY_PATH = [ "${lib.getLib pkgs.pcsclite}/lib" ];
    DIRENV_CONFIG = "/etc/direnv";

    XCURSOR_SIZE = "22";
    XCURSOR_THEME = lib.mkDefault "graphite-light-nord";
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
    CARGO_UNSTABLE_SPARSE_REGISTRY = "true";
    NEOVIDE_MULTIGRID = "1";
    NEOVIDE_WM_CLASS = "1";
    NODE_PATH = "~/.npm-packages/lib/node_modules";
    MOZ_USE_XINPUT2 = "1";
    XDG_CURRENT_DESKTOP = "sway";
    RUSTIC_CACHE_DIR = "/var/cache/rustic";
  };
}
