{
  flake.modules.nixos.proxypool =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # 初始配置文件模版（默认监听 [::]，设置 Arti 为前置二段跳与抓取代理）
      defaultConfig = builtins.toJSON {
        listen = "::";
        port = 8082;
        stats_port = 8083;
        upstream_type = "socks5";
        max_clients = 100;
        fail_threshold = 3;
        timeout = 6;
        retries = 3;
        threads = 100;
        fetch_proxy = "socks5://host.containers.internal:9150";
        front_proxy = "socks5://host.containers.internal:9150";
        socks_file = "socks.txt";
        alive_file = "alive.txt";
        region_file = "region.json";
      };

      # Python 源码 Patch 脚本：
      # 1. 替换第 41 行 SOURCES 为中国出口源
      # 2. 支持 IPv6 / [::] 双栈监听
      # 3. 增强 _valid_proxy 解析带 socks5:// 和 #cn 注释的源
      # 4. 实现核心“二段跳”：ProxyPool -> 前置代理 (Arti SOCKS5 9150) -> 国内节点 -> 目标
      patchScript = pkgs.writeText "patch-proxypool.py" ''
        import re

        with open("main.py", "r", encoding="utf-8") as f:
            content = f.read()

        # 1. 替换抓取源为中国节点源
        old_sources = """SOURCES = {
            "TheSpeedX": "https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks5.txt",
            "Monosans": "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/socks5.txt",
            "ProxyScrape": "https://api.proxyscrape.com/v2/?request=displayproxies&protocol=socks5"
                           "&timeout=10000&ssl=all&anonymity=all",
        }"""
        new_sources = """SOURCES = {
            "ProxyScrape_CN": "https://api.proxyscrape.com/v2/?request=displayproxies&protocol=socks5&timeout=10000&country=CN&ssl=all&anonymity=all",
            "ProxyClean_CN": "https://raw.githubusercontent.com/HankNovic/ProxyClean/refs/heads/main/SOCKS5.txt",
            "TheSpeedX": "https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks5.txt",
            "Monosans": "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/socks5.txt",
        }"""
        assert old_sources in content, "old_sources not found"
        content = content.replace(old_sources, new_sources)

        # 2. 默认配置注入 front_proxy 并将 listen 默认为 ::
        old_defaults = """CONFIG_DEFAULTS = {
            "listen": "127.0.0.1",
            "port": 8082,            # 代理端口（HTTP+SOCKS5 入站）
            "stats_port": 8083,      # 控制台端口
            "upstream_type": "socks5",
            "max_clients": 100,
            "fail_threshold": 3,
            "timeout": 6,
            "retries": 3,
            "threads": 100,          # check 线程数
            "fetch_proxy": "",       # fetch 时经由的代理（留空直连）
            "socks_file": DEFAULT_SOCKS_FILE,
            "alive_file": DEFAULT_ALIVE_FILE,
            "region_file": DEFAULT_REGION_FILE,
        }"""
        new_defaults = """CONFIG_DEFAULTS = {
            "listen": "::",
            "port": 8082,            # 代理端口（HTTP+SOCKS5 入站）
            "stats_port": 8083,      # 控制台端口
            "upstream_type": "socks5",
            "max_clients": 100,
            "fail_threshold": 3,
            "timeout": 6,
            "retries": 3,
            "threads": 100,          # check 线程数
            "fetch_proxy": "socks5://host.containers.internal:9150",
            "front_proxy": "socks5://host.containers.internal:9150",
            "socks_file": DEFAULT_SOCKS_FILE,
            "alive_file": DEFAULT_ALIVE_FILE,
            "region_file": DEFAULT_REGION_FILE,
        }"""
        assert old_defaults in content, "old_defaults not found"
        content = content.replace(old_defaults, new_defaults)

        # 3. 增强 _valid_proxy
        old_vp = "m = PROXY_RE.match(line.strip())"
        new_vp = """clean_line = re.sub(r"^(socks5://|http://)", "", line.strip()).split("#")[0].strip()
            m = PROXY_RE.match(clean_line)"""
        assert old_vp in content, "old_vp not found"
        content = content.replace(old_vp, new_vp, 1)

        # 3.1 忽略抓取公开源时的 SSL 验证错误
        old_ffs = 'with urllib.request.urlopen(req, timeout=timeout) as resp:'
        new_ffs = 'import ssl\n        ctx = ssl._create_unverified_context()\n        with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:'
        assert old_ffs in content, "old_ffs not found"
        content = content.replace(old_ffs, new_ffs)

        # 4. 实现核心二段跳代理链
        old_connect = """def _connect_via_proxy(upstream_type, proxy_host, proxy_port,
                               dest_host, dest_port, timeout):
            \"\"\"
            通过指定上游代理建立到 dest 的连接（局部 socket，不污染全局）。
            支持 socks5 / socks4 / http。
            \"\"\"
            import socks  # PySocks
            type_attr = _UPSTREAM_TYPES.get(upstream_type)
            if type_attr is None:
                raise ValueError("不支持的上游类型: {}".format(upstream_type))
            ptype = getattr(socks, type_attr)
            s = socks.socksocket()
            s.set_proxy(ptype, proxy_host, proxy_port)
            s.settimeout(timeout)
            s.connect((dest_host, dest_port))
            return s"""

        new_connect = """def _parse_proxy_target(url):
            if not url:
                return None, None, None
            m = re.match(r"^(socks5|socks5h|http)://([^:]+):(\d+)$", str(url).strip())
            if not m:
                return None, None, None
            scheme, host, port = m.group(1), m.group(2), int(m.group(3))
            if host == "host.containers.internal":
                resolved = None
                try:
                    with open("/etc/hosts", "r") as f:
                        for line in f:
                            parts = line.strip().split()
                            if len(parts) >= 2 and "host.containers.internal" in parts[1:]:
                                resolved = parts[0]
                                break
                except Exception:
                    pass
                host = resolved or "169.254.1.2"
            return scheme, host, port

        def _connect_via_proxy(upstream_type, proxy_host, proxy_port,
                               dest_host, dest_port, timeout, front_proxy=None):
            f_scheme, f_host, f_port = _parse_proxy_target(front_proxy)
            if f_scheme in ("socks5", "socks5h") and f_host and f_port:
                # ===== 二段跳逻辑: 本服务 -> 前置代理 (Arti) -> 国内代理 (ProxyPool) -> 目标 =====
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.settimeout(timeout)
                s.connect((f_host, f_port))

                # 阶段 1: 告知前置代理 (Arti SOCKS5) CONNECT 国内节点 (proxy_host:proxy_port)
                s.sendall(b"\\x05\\x01\\x00")
                resp = s.recv(2)
                if not resp or resp[0] != 5 or resp[1] != 0:
                    s.close()
                    raise ConnectionError("前置代理 SOCKS5 握手失败")
                try:
                    ip_bytes = socket.inet_aton(proxy_host)
                    s.sendall(b"\\x05\\x01\\x00\\x01" + ip_bytes + proxy_port.to_bytes(2, "big"))
                except OSError:
                    s.sendall(b"\\x05\\x01\\x00\\x03" + bytes([len(proxy_host)]) + proxy_host.encode() + proxy_port.to_bytes(2, "big"))
                rep = s.recv(4)
                if not rep or rep[0] != 5 or rep[1] != 0:
                    s.close()
                    raise ConnectionError(f"前置代理连国内节点失败 code={rep[1] if rep else -1}")
                atyp = rep[3]
                if atyp == 1: s.recv(6)
                elif atyp == 3: s.recv(s.recv(1)[0] + 2)
                elif atyp == 4: s.recv(18)

                # 阶段 2: 经由前置隧道连通国内节点后，连接目标 dest_host:dest_port
                # 自动自适应兼容 SOCKS5 与 HTTP (CONNECT) 代理节点
                connected = False
                if upstream_type != "http":
                    try:
                        s.settimeout(3)
                        s.sendall(b"\\x05\\x01\\x00")
                        resp2 = s.recv(2)
                        if resp2 and resp2[0] == 5 and resp2[1] == 0:
                            try:
                                ip_bytes = socket.inet_aton(dest_host)
                                s.sendall(b"\\x05\\x01\\x00\\x01" + ip_bytes + dest_port.to_bytes(2, "big"))
                            except OSError:
                                s.sendall(b"\\x05\\x01\\x00\\x03" + bytes([len(dest_host)]) + dest_host.encode() + dest_port.to_bytes(2, "big"))
                            rep2 = s.recv(4)
                            if rep2 and rep2[0] == 5 and rep2[1] == 0:
                                atyp2 = rep2[3]
                                if atyp2 == 1: s.recv(6)
                                elif atyp2 == 3: s.recv(s.recv(1)[0] + 2)
                                elif atyp2 == 4: s.recv(18)
                                connected = True
                    except Exception:
                        connected = False

                if not connected:
                    try:
                        s.settimeout(timeout)
                        req = f"CONNECT {dest_host}:{dest_port} HTTP/1.1\\r\\nHost: {dest_host}:{dest_port}\\r\\n\\r\\n".encode()
                        s.sendall(req)
                        hbuf = b""
                        while b"\\r\\n\\r\\n" not in hbuf:
                            c = s.recv(1024)
                            if not c: break
                            hbuf += c
                        if b" 200 " in hbuf.split(b"\\r\\n")[0]:
                            connected = True
                    except Exception:
                        connected = False

                if not connected:
                    s.close()
                    raise ConnectionError(f"节点 {proxy_host}:{proxy_port} 无法打通到目标的连接")

                s.settimeout(timeout)
                return s
            else:
                # 单段直连回退
                import socks
                type_attr = _UPSTREAM_TYPES.get(upstream_type)
                if type_attr is None:
                    raise ValueError("不支持的上游类型: {}".format(upstream_type))
                ptype = getattr(socks, type_attr)
                s = socks.socksocket()
                s.set_proxy(ptype, proxy_host, proxy_port)
                s.settimeout(timeout)
                s.connect((dest_host, dest_port))
                return s"""
        assert old_connect in content, "old_connect not found"
        content = content.replace(old_connect, new_connect)

        # 5. 传递 front_proxy 至连接函数
        old_estab = "def _establish_upstream(pool, dest_host, dest_port, timeout, max_retries, upstream_type):"
        new_estab = "def _establish_upstream(pool, dest_host, dest_port, timeout, max_retries, upstream_type, front_proxy=None):"
        assert old_estab in content, "old_estab not found"
        content = content.replace(old_estab, new_estab)

        content = content.replace(
            "server = _connect_via_proxy(upstream_type, ph, pp,\n                                        dest_host, dest_port, timeout)",
            "server = _connect_via_proxy(upstream_type, ph, pp,\n                                        dest_host, dest_port, timeout, front_proxy=front_proxy)"
        )

        old_hc = "def handle_client(client, pool, timeout, max_retries, upstream_type):"
        new_hc = "def handle_client(client, pool, timeout, max_retries, upstream_type, front_proxy=None):"
        assert old_hc in content, "old_hc not found"
        content = content.replace(old_hc, new_hc)

        content = content.replace(
            "server, _ = _establish_upstream(pool, dest_host, dest_port,\n                                        timeout, max_retries, upstream_type)",
            "server, _ = _establish_upstream(pool, dest_host, dest_port,\n                                        timeout, max_retries, upstream_type, front_proxy=front_proxy)"
        )

        old_worker = """    def worker(conn):
                # 每次连接读取 config 最新值，UI 改动立即对新连接生效
                try:
                    handle_client(conn, pool, cfg.get("timeout"),
                                  cfg.get("retries"), cfg.get("upstream_type"))"""
        new_worker = """    def worker(conn):
                try:
                    handle_client(conn, pool, cfg.get("timeout"),
                                  cfg.get("retries"), cfg.get("upstream_type"),
                                  front_proxy=cfg.get("front_proxy"))"""
        assert old_worker in content, "old_worker not found"
        content = content.replace(old_worker, new_worker)

        # 6. 支持 [::] IPv6 与 IPv4 双栈监听
        old_makesock = """    def make_socket():
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                sock.bind((listen_addr, proxy_port))
                sock.listen(100)
                return sock"""
        new_makesock = """    def make_socket():
                clean_addr = listen_addr.strip("[]")
                fam = socket.AF_INET6 if ":" in clean_addr else socket.AF_INET
                sock = socket.socket(fam, socket.SOCK_STREAM)
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                if fam == socket.AF_INET6:
                    try:
                        sock.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
                    except (AttributeError, OSError):
                        pass
                sock.bind((clean_addr, proxy_port))
                sock.listen(100)
                return sock"""
        assert old_makesock in content, "old_makesock not found"
        content = content.replace(old_makesock, new_makesock)

        old_httpd = """    try:
                httpd = HTTPServer((listen, port), ControlHandler)"""
        new_httpd = """    try:
                clean_listen = listen.strip("[]")
                if ":" in clean_listen:
                    class IPv6HTTPServer(HTTPServer):
                        address_family = socket.AF_INET6
                    httpd = IPv6HTTPServer((clean_listen, port), ControlHandler)
                else:
                    httpd = HTTPServer((clean_listen, port), ControlHandler)"""
        assert old_httpd in content, "old_httpd not found"
        content = content.replace(old_httpd, new_httpd)

        with open("main.py", "w", encoding="utf-8") as f:
            f.write(content)
      '';

      proxypoolApp = pkgs.runCommand "shadow-proxypool-app" { } ''
        mkdir -p $out/app
        cp -r ${
          pkgs.fetchFromGitHub {
            owner = "shadow1ng";
            repo = "ProxyPool";
            rev = "c8117798519561f500f70f947a72ace1b7b25410";
            hash = "sha256-hJRty/+Pn+AWZQs91807Nu/klDdx+qtgLNRsuO1FegM=";
          }
        }/* $out/app/
        chmod -R u+w $out/app
        cd $out/app
        ${pkgs.python3}/bin/python3 ${patchScript}
      '';

      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.requests
        ps.pysocks
      ]);

      # 构建 OCI 镜像，运行时直接从 /data 读写配置和状态
      proxypoolImage = pkgs.dockerTools.buildLayeredImage {
        name = "shadow-proxypool";
        tag = "latest";
        contents = [
          pythonEnv
          pkgs.cacert
          proxypoolApp
        ];
        config = {
          WorkingDir = "/data";
          Cmd = [
            "${pythonEnv}/bin/python3"
            "/app/main.py"
            "serve"
            "--listen"
            "::"
            "--port"
            "8082"
            "--stats-port"
            "8083"
          ];
          ExposedPorts = {
            "8082/tcp" = { };
            "8083/tcp" = { };
          };
          Volumes = {
            "/data" = { };
          };
        };
      };
    in
    {
      # 独立无特权用户
      users = {
        groups.proxypool = { };
        users.proxypool = {
          isSystemUser = true;
          group = "proxypool";
          home = "/var/lib/proxypool";
          linger = true;
          createHome = true;
          uid = 952;
          autoSubUidGidRange = true;
        };
      };

      # 持久化目录与首次默认 config.json 生成（C+ 规则：不存在才写入，用户后续在网页的修改永久生效）
      systemd.tmpfiles.rules = [
        "d /var/lib/proxypool 0700 proxypool proxypool -"
        "C+ /var/lib/proxypool/config.json 0600 proxypool proxypool - ${pkgs.writeText "config.json" defaultConfig}"
      ];

      # 服务启动依赖
      systemd.services.podman-proxypool = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig.Restart = lib.mkForce "always";
      };

      # 容器编排：监听 [::]，宿主机网关映射 host.containers.internal -> 宿主机（指向 Arti 9150）
      virtualisation.oci-containers = {
        backend = "podman";
        containers.proxypool = {
          image = "shadow-proxypool:latest";
          imageFile = proxypoolImage;
          environment = {
            SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
          };
          ports = [
            "[::]:8082:8082"
            "[::]:8083:8083"
          ];
          volumes = [
            "/var/lib/proxypool:/data:Z"
          ];
          extraOptions = [
            "--add-host=host.containers.internal:host-gateway"
            "--userns=keep-id:uid=1000,gid=1000"
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
          ];
          podman = {
            user = "proxypool";
          };
        };
      };

      # 定时任务：每 30 分钟通过 Arti 代理自动拉取并检测存活中国节点
      systemd.services.proxypool-refresh = {
        description = "ProxyPool Periodic Fetch & Check via Arti";
        after = [ "podman-proxypool.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "proxypool-refresh" ''
            ${pkgs.curl}/bin/curl -s -X POST http://127.0.0.1:8083/fetch || true
            ${pkgs.coreutils}/bin/sleep 10
            ${pkgs.curl}/bin/curl -s -X POST http://127.0.0.1:8083/check || true
          '';
        };
      };

      systemd.timers.proxypool-refresh = {
        description = "Timer for ProxyPool Periodic Fetch & Check";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2m";
          OnUnitActiveSec = "30m";
        };
      };
    };
}
