# EPD-Dashboard（家庭食品存储看板）NixOS 模块主体。
# 本模块随 zhyi-packages 发布，由上层 flake（nixos-config 的
# nixos/optional-apps/food-dashboard.nix 薄壳）导入后启用；包定义在
# ../pkgs/uncategorized/epd-food-server，逻辑不重复落在上层仓库。
#
# 服务组成：
#   - epd-food-server.service  常驻 REST API + WebUI（默认仅监听本机，nginx 私网反代）
#   - epd-food-push.service    oneshot 推送（供 timer 与手动调用）
#   - epd-food-push.timer      每天 00:00 推送墨水屏（Persistent 补跑）
#
# 私有服务：不开公网 vhost，WebUI/API 经 nginx 私网 vhost 暴露（accessibleBy private）。
self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lantian.food-dashboard;

  package =
    if cfg.package != null then
      cfg.package
    else
      self.packages.${pkgs.system}.epd-food-server;

  # 从字体包里挑出 CJK Bold 字体文件（对包内目录布局变化稳健）
  fontFile = pkgs.runCommand "epd-food-cjk-font" { } ''
    f="$(find ${cfg.fontPackage}/share/fonts -iname '*bold*' \( -name '*.ttc' -o -name '*.otf' -o -name '*.ttf' \) 2>/dev/null | head -n1)"
    if [ -z "$f" ]; then
      f="$(find ${cfg.fontPackage}/share/fonts \( -name '*.ttc' -o -name '*.otf' \) 2>/dev/null | head -n1)"
    fi
    test -n "$f" || { echo "no CJK font found in ${cfg.fontPackage}"; exit 1; }
    ln -s "$f" "$out"
  '';

  commonEnvironment = {
    EPD_FOOD_DSN = "host=/run/postgresql dbname=epd_dashboard";
    EPD_FOOD_FONT_PATH = "${fontFile}";
    EPD_FOOD_STATE_DIR = "/var/lib/epd-dashboard";
    EPD_FOOD_DEVICE_NAME_PREFIX = cfg.deviceNamePrefix;
    EPD_FOOD_MAX_CHUNK = toString cfg.maxChunk;
    EPD_FOOD_PUSH_ON_CHANGE = if cfg.pushOnChange then "true" else "false";
  };

  # BLE 走 BlueZ D-Bus：不需要 /dev 设备节点，但要放开 PrivateDevices 并允许网链
  bleHarden = LT.serviceHarden // {
    PrivateDevices = lib.mkForce false;
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
      "AF_BLUETOOTH"
    ];
  };
in
{
  options.lantian.food-dashboard = {
    enable = lib.mkEnableOption "EPD 家庭食品存储看板服务端";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "覆盖服务端包（默认取 zhyi-packages 的 epd-food-server）";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "API Bearer Token 文件（建议 sops-nix 管理）；null = 免鉴权（仅测试环境）";
    };

    fontPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.noto-fonts-cjk-sans;
      description = "CJK 字体包（用于把食品名称渲染成墨水屏位图）";
    };

    deviceNamePrefix = lib.mkOption {
      type = lib.types.str;
      default = "NRF_EPD";
      description = "墨水屏 BLE 广播名前缀";
    };

    maxChunk = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 0;
      description = "BLE 单片数据字节上限；0=按协商 MTU 自动（Linux 可留 0）";
    };

    pushOnChange = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "数据变更后防抖即时推送墨水屏";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = LT.port.EpdFoodDashboard;
      description = "API 监听端口（端口常量登记于上层仓库 ports.nix）";
    };

    vhost = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "生成 nginx 私网 vhost（food.<host>.zhyi.xin）";
    };

    sslCertificate = lib.mkOption {
      type = lib.types.str;
      default = "zerossl-zhyi.xin";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.epd-dashboard = {
      group = "epd-dashboard";
      isSystemUser = true;
    };
    users.groups.epd-dashboard = { };

    # 数据库：沿用仓库 ensureDatabases 模式；使用方主机需已启用 services.postgresql。
    services.postgresql = {
      ensureDatabases = [ "epd_dashboard" ];
      ensureUsers = [
        {
          name = "epd-dashboard";
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.epd-food-server = {
      description = "EPD Food Dashboard API";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.service"
        "bluetooth.service"
      ];
      wants = [
        "network.target"
        "postgresql.service"
        "bluetooth.service"
      ];

      environment = commonEnvironment;
      script =
        if cfg.tokenFile != null then
          ''
            export EPD_FOOD_API_TOKEN="$(cat ${cfg.tokenFile})"
            exec ${package}/bin/epd-food-server serve --host ${cfg.bindAddress} --port ${toString cfg.port}
          ''
        else
          ''
            exec ${package}/bin/epd-food-server serve --host ${cfg.bindAddress} --port ${toString cfg.port}
          '';

      serviceConfig = bleHarden // {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        User = "epd-dashboard";
        Group = "epd-dashboard";
        StateDirectory = "epd-dashboard";
        WorkingDirectory = "/var/lib/epd-dashboard";
      };
    };

    systemd.services.epd-food-push = {
      description = "EPD Food Dashboard 推送墨水屏";
      after = [
        "network.target"
        "postgresql.service"
        "bluetooth.service"
      ];
      wants = [
        "network.target"
        "postgresql.service"
        "bluetooth.service"
      ];

      environment = commonEnvironment;
      script = ''
        exec ${package}/bin/epd-food-server push-now
      '';

      serviceConfig = bleHarden // {
        Type = "oneshot";
        User = "epd-dashboard";
        Group = "epd-dashboard";
        StateDirectory = "epd-dashboard";
        WorkingDirectory = "/var/lib/epd-dashboard";
        # 物理刷新 + 锁等待，上限放宽
        TimeoutStartSec = "10min";
      };
    };

    systemd.timers.epd-food-push = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00";
        Persistent = true;
        RandomizedDelaySec = "30";
        Unit = "epd-food-push.service";
      };
    };

    lantian.nginxVhosts."food.${config.networking.hostName}.zhyi.xin" = lib.mkIf cfg.vhost {
      locations = {
        "/" = {
          proxyPass = "http://${cfg.bindAddress}:${toString cfg.port}";
          proxyNoTimeout = true;
        };
      };
      accessibleBy = "private";
      sslCertificate = cfg.sslCertificate;
      noIndex.enable = true;
    };
  };
}
