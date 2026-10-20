# 青简输入法 NixOS 模块主体。
# 本模块随 zhyi-packages 发布，由上层 flake（nixos-config 的
# nixos/client-apps/qingjian.nix 薄壳）导入后启用；包定义在
# ../pkgs/uncategorized/qingjian，逻辑不重复落在上层仓库。
self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lantian.qingjian;
in
{
  options.lantian.qingjian = {
    enable = lib.mkEnableOption "Qingjian pinyin input method (fcitx5 addon + user backend server)";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.qingjian;
      defaultText = lib.literalExpression "zhyi-packages.packages.\${pkgs.system}.qingjian";
      description = "The Qingjian package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod.fcitx5.addons = [ cfg.package ];

    # 上游 Linux 版由用户手动启动后端 server，这里固化为用户服务。
    # server 不依赖图形会话（经 dbus/socket 与 fcitx5 插件通信），
    # 挂 default.target 保证登录即起。
    systemd.user.services.qingjian-server = {
      description = "Qingjian input method backend server";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/qingjian-linux-server";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
