let
  pkgs = import <nixpkgs> { };
  mylib = import ../lib { inherit pkgs; };
in
pkgs.testers.runNixOSTest {
  name = "fungi-service-test";

  nodes.machine =
    {
      config,
      pkgs,
      ...
    }:
    {
      # 导入你的模块
      imports = [ ../modules/fungi ];
      _module.args.mylib = mylib;

      services.fungi = {
        enable = true;
        configFile = pkgs.writeText "test-config.toml" ''
          [rpc]
          listen_address = "127.0.0.1:5405"

          [network]
          listen_tcp_port = 0
          listen_udp_port = 0
          incoming_allowed_peers = [
            "16Uiu2HAmN7utr2gU28MizZqpL3tHtFK3nnPfxedzYVCLBxxCDWAP", # main
          ]
          disable_relay = false
          custom_relay_addresses = []

          [tcp_tunneling.forwarding]
          enabled = true
          rules = []

          [tcp_tunneling.listening]
          enabled = true
          rules = [
            { host = "127.0.0.1", port = 22 }, # Expose SSH to remote devices
          ]
        '';
      };
    };

  testScript = ''
    # 1. 等待服务启动
    machine.wait_for_unit("fungi.service")

    # 2. 验证 StateDirectory 是否创建且权限正确 (UID/GID check)
    # 获取 fungi 用户的 uid/gid，通常 systemd 动态用户或指定用户会有特定 ID，这里直接查名字
    machine.succeed("stat -c '%U:%G' /var/lib/fungi | grep 'fungi:fungi'")

    # 3. 验证 config.toml 是否被正确复制到 StateDirectory
    machine.succeed("test -f /var/lib/fungi/config.toml")
    machine.succeed("grep 'listen_address' /var/lib/fungi/config.toml")

    # 4. 检查进程是否在运行
    machine.succeed("pgrep -u fungi fungi")

    print(machine.succeed("journalctl -u fungi --no-pager"))
  '';
}
