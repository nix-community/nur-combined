let
  pkgs = import <nixpkgs> { };
  modules = import ../modules { inherit pkgs; };
in
pkgs.testers.runNixOSTest {
  name = "system76-scheduler-niri-test";

  nodes.machine =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ modules.system76-scheduler-niri ];

      users.users.alice = {
        isNormalUser = true;
        uid = 1000;
        # 关键：linger 允许用户服务在后台运行，无需交互式登录
        linger = true;
      };

      services.system76-scheduler-niri.enable = true;

      # Mock niri.service
      systemd.user.services.niri = {
        description = "Mock Niri Service";
        serviceConfig = {
          ExecStart = "${pkgs.coreutils}/bin/sleep inf";
          Type = "simple";
        };
      };
    };

  testScript = ''
    # 1. 等待系统启动
    machine.wait_for_unit("multi-user.target")

    # 2. 等待 alice 用户的 systemd 实例启动 (由 linger=true 触发)
    machine.wait_for_unit("user@1000.service")

    # 3. 以 alice 身份启动 mock 的 niri 服务
    # 我们使用 'su -' 来确保环境变量（如 XDG_RUNTIME_DIR）正确设置
    machine.succeed("su - alice -c 'systemctl --user start niri.service'")

    # 4. 确认 niri 服务已在 alice 用户下运行
    # wait_for_unit 的第二个参数指定用户
    machine.wait_for_unit("niri.service", "alice")

    # 5. 核心测试：验证 system76-scheduler-niri 是否自动启动
    # 因为你的 module 设置了 WantedBy = [ "niri.service" ]
    machine.wait_for_unit("system76-scheduler-niri.service", "alice")

    # 6. 额外验证：检查进程是否真的存在
    # -u alice: 指定用户
    # -f: 匹配完整命令行
    machine.succeed("pgrep -u alice -f system76-scheduler-niri")

    # 7. 打印日志以供调试（如果测试失败，这一步很有用）
    print(machine.succeed("su - alice -c 'journalctl --user -u system76-scheduler-niri.service --no-pager'"))
  '';
}
