# hastur：sing-box DNSSEC 分流与 networkd 重启后 IPv6 断网

## 结论与当前配置

保留 `nixosModules/sing-box.nix` 中完整的 tun0 DNS 配置和三个外部网络对象保护设置。不要只设置 `DNSSEC=false`，也不要只保护路由而遗漏 NextHop。

本次排障涉及两个不同故障：

| 故障 | 证据 | 处理 |
|---|---|---|
| DNSSEC 验证失败 | sing-box 已取得地址，resolved 报 `no-signature` | tun0 关闭本地 DNSSEC 验证，其他链路保留全局默认值 |
| networkd 重启后 IPv6 出口丢失 | NextHop 和默认路由被删除，DNS 仍能返回地址 | 配套关闭外部路由、策略规则和 NextHop 的清理 |

2026-10-17 应用最终配置后，完整测试通过：switch → restart networkd → restart sing-box → restart networkd。整机重启尚未验证。

## 环境与配置位置

- 主机：`hastur`，NixOS。
- sing-box：1.14.1。
- systemd：261.2。
- 系统解析器：systemd-resolved。
- 物理接口：`eno1`。sing-box 接口：`tun0`。
- `mod/net.nix`：resolved 的全局设置，包括 `settings.Resolve.DNSSEC = "true"`。
- `nixosModules/sing-box.nix`：sing-box 服务、tun0 的 networkd 配置和外部网络对象保护。
- sing-box 服务通过 systemd credentials 读取运行配置。本文不记录凭据内容。

本次 DNS 配置约定 tun0 使用 `172.19.0.1/30` 和 `fdfe:dcba:9876::1/126`，DNS 地址为各自的下一个地址。改变 sing-box 的接口名或地址时，必须同步修改 networkd 配置。

## 故障一：B 站图片、视频加载慢

### DNSSEC 标志改变了 DNS 分流

原 sing-box DNS 规则将带 DNSSEC OK 标志（DO）的查询优先送到 `foreign`，且关闭该分支的缓存。国内 `geosite-cn → domestic-dns` 规则排在后面。

DO 表示客户端请求 DNSSEC 相关数据，不表示被查询的域名已经部署 DNSSEC。

系统启用严格 DNSSEC 验证后，普通国内查询也可能携带 DO，先命中境外 DNS。对运行中的 sing-box DNS 做对照查询，改变 DO 标志会改变 B 站 CDN 地址。

现场单次测试中，指定不同解析地址请求同一域名的 HTTPS 根路径：

| 域名 | 国内 DNS 对照地址的首字节耗时 | 原 DO 分支返回地址的首字节耗时 |
|---|---:|---:|
| `i0.hdslb.com` | 51 ms | 1512 ms |
| `s1.hdslb.com` | 28 ms | 891 ms |

这只是连接与响应延迟对照，不是完整图片或视频的吞吐量测试。日志还记录了部分静态资源 IPv6 地址直连 5 秒超时。

规则集检查排除了另一项怀疑：所查 B 站域名命中本机缓存中的 `geosite-cn`，不命中 `category-media`。没有证据表明这些域名被媒体规则提前送往代理。

### 国内 DO 查询全部改走阿里后，严格验证失败

初次尝试在境外 DO 规则之前增加“`query_dnssec=true` 且命中 `geosite-cn` → domestic-dns”。随后出现浏览器 `server IP address could not be found`。

2026-10-16 的日志证明，sing-box 已取得地址，但系统验证拒绝了结果：

```text
21:46:22 sing-box: message.bilibili.com 返回 CNAME、A 和 AAAA
21:46:23 systemd-resolved:
DNSSEC validation failed for question bilibili.com IN DS: no-signature
DNSSEC validation failed for question message.bilibili.com IN A: no-signature
DNSSEC validation failed for question message.bilibili.com IN AAAA: no-signature
```

直接测试阿里 DoH 时，带 DO 的 `bilibili.com DS` 查询只返回 SOA，`com DNSKEY` 查询返回密钥但没有 RRSIG。这条测试路径没有返回严格验证所需的完整材料。不能由此断言所有阿里 DNS 接口、所有时段都不支持 DNSSEC。

即使域名未签名，严格验证也需要可验证的未签名证明。收到 IP 不等于 DNSSEC 验证通过。改用加密 DNS 传输也不自动补齐验证材料。

当时国外域名同样出现过 `no-signature`。仅凭这组日志，不能把所有失败都归因于新增的国内分流规则。

## 故障二：只配置 tun0 DNSSEC 没有生效

最初的 Nix 配置如下：

```nix
systemd.network.networks."tun0".networkConfig.DNSSEC = false;
```

`"tun0"` 是生成文件的名称，不是接口匹配条件。由于缺少 `[Match]`，networkd 忽略了文件：

```text
/etc/systemd/network/tun0.network:
No valid settings found in the [Match] section, ignoring file.
```

当时 `networkctl status tun0` 显示 `Network File: n/a` 和 `unmanaged`。

补上 `matchConfig.Name = "tun0"` 后，networkd 开始接管接口，但只声明 DNSSEC 仍然不够。现场出现 tun0 的 DNS 服务器和 `~.` 消失，只剩 `DNSSEC=no` 的状态。

`KeepConfiguration=yes` 不保留 resolved 中的 DNS 设置。让 networkd 管理链路后，不能继续假设 sing-box 可以独立维护同一链路的 DNS。最终改为由 networkd 统一声明 DNS 服务器、路由域和 DNSSEC 模式。

## 故障三：networkd → sing-box → networkd 才恢复

### 单次重启测试不足以覆盖问题

18:43 的单独 sing-box 重启测试通过。旧 tun0 删除，新接口、DNS 和策略规则自动重建，IPv6 默认路由保留。

但用户随后执行以下顺序，仍能触发故障：

```text
restart systemd-networkd
    ↓
restart sing-box
    ↓
仍失败
    ↓
restart systemd-networkd
    ↓
恢复
```

因此，“单独重启成功”不能证明所有重启顺序都安全。也不能仅用浏览器的地址错误判断 DNS 一定失败。

### 完整复现抓到了 NextHop 删除

18:47 的受控测试保存了每一阶段的 DNS、路由、NextHop 和 HTTPS 结果。监控直接记录：

```text
18:47:30.685100 Deleted id 666152904 via fe80::… dev eno1 scope link proto ra
18:47:30.685149 Deleted default nhid 666152904 via fe80::… dev eno1 proto ra
```

先删除 NextHop，约 49 微秒后删除引用它的 IPv6 默认路由。

故障期间：

- tun0 仍有 DNS 服务器、`~.` 和 `DNSSEC=no`。
- B 站域名能解析，国外域名能返回 FakeIP。
- 不带标记的 IPv6 路由查询落入 tun0 的表 2022，不能据此认为真实出口正常。
- 带 sing-box 出站标记 `0x2024` 的 IPv6 路由查询返回 `Network is unreachable`。
- 国内与国外 HTTPS 测试均失败，部分连接报重置。

18:47:37，最后一次 networkd 重启后，NextHop 和默认路由重新出现，HTTPS 恢复。

源码核对没有支持“sing-box 缓存了错误的 IPv6 能力”这个解释。networkd 261.2 的 NextHop 恢复、清理及路由器通告处理是更具体的候选机制。现场已确认删除事件及其网络后果，但没有单独复现并证明内部每个调用分支。

## 最终修正

`nixosModules/sing-box.nix` 的相关配置：

```nix
systemd.network = {
  config.networkConfig = {
    ManageForeignRoutingPolicyRules = false;
    ManageForeignRoutes = false;
    ManageForeignNextHops = false;
  };
  networks."tun0" = {
    matchConfig.Name = "tun0";
    linkConfig.RequiredForOnline = false;
    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
      LinkLocalAddressing = "no";
      KeepConfiguration = "yes";
      DNS = [ "172.19.0.2" ] ++ lib.optional config.networking.enableIPv6 "fdfe:dcba:9876::2";
      Domains = [ "~." ];
      DNSDefaultRoute = true;
      DNSSEC = false;
    };
  };
};
```

三个 `ManageForeign…` 设置配套使用。关闭外部路由清理，却继续清理路由依赖的 NextHop，会留下另一条破坏出口的路径。

这些设置作用于 networkd 全局，不只 tun0。它们保护其他程序创建的网络对象，但也意味着这些程序应自行清理退出后的残留。

## 为什么只关闭 tun0 的 DNSSEC

```text
普通应用
    ↓
systemd-resolved 根据 DNS 路由域选择链路
    ↓
tun0 的 ~. 匹配普通域名查询
    ↓
sing-box DNS → 国内上游 / 境外上游 / FakeIP
```

eno1 是最终传输数据包的物理接口，但其 DNSSEC 设置不是经过该网卡的所有 DNS 流量的过滤器。只有 resolved 选择 eno1 所属 DNS 服务器时，才使用该链路的验证设置。

关闭 tun0 的验证不等于全系统关闭 DNSSEC，也不保证上游自身是否验证。加密传输和 DNSSEC 是两种保护。FakeIP 是本地合成地址，不能用真实域名的签名验证该地址。

## 验证结果与证据目录

最终配置通过 Nix 语法、格式、求值、断言和生成文件检查。18:53 实际 switch 后，再执行完整重启序列：

| 阶段 | B 站 HTTPS | 国外 HTTPS | IPv6 默认路由 |
|---|---:|---:|---|
| switch 后 | 200 | 204 | 保留 |
| restart networkd 后 | 200 | 204 | 保留 |
| restart sing-box 后 | 200 | 204 | 保留 |
| 最后 restart networkd 后 | 200 | 204 | 保留 |

该次监控未记录默认路由及对应 NextHop 被删除。tun0 的 DNS 状态正常，eno1 保持 `DNSSEC=yes`，测试期间未出现代理节点 `network is unreachable`。自动恢复定时器已取消，没有执行额外恢复重启。

本机临时证据目录：

| 路径 | 内容 |
|---|---|
| `/var/tmp/sing-net-repro.vPPQgB/` | 无配置变化的 switch，没有触发服务重启 |
| `/var/tmp/sing-net-repro.skPnco/` | 单独重启 sing-box，通过 |
| `/var/tmp/sing-net-repro.R5aWWC/` | 完整顺序复现，抓到 NextHop 和默认路由删除 |
| `/var/tmp/sing-net-repro.YfpSqy/` | 增加 NextHop 保护后的完整验证，通过 |

这些目录不在仓库中，可能被清理。本文中的时间线和结论不依赖临时脚本长期存在。

## 再次发生时的检查顺序

先保存故障状态，不要立即用重启覆盖现场。以下命令只读，不需要读取 sing-box credentials：

```sh
resolvectl status tun0 eno1
networkctl status tun0
ip -4 rule show
ip -6 rule show
ip -6 route show table all
ip nexthop show
```

再区分系统解析和 sing-box DNS：

```sh
dig @172.19.0.2 message.bilibili.com A +time=2 +tries=1
resolvectl query message.bilibili.com
journalctl -u systemd-resolved -u systemd-networkd -u sing-box --since '5 min ago'
```

用实际 IPv6 代理节点地址检查绕过 TUN 的出口，不能只看不带标记的查询：

```sh
ip -6 route get <实际IPv6代理节点地址> mark 0x2024
```

`0x2024` 是本次配置的出站标记。改变 sing-box 的标记后，检查命令也必须同步修改。

需要监控重启顺序时，先在本机设置独立恢复任务，再采集事件。不要只依赖可能随网络故障断开的 SSH 会话：

```sh
ip -ts monitor link address route rule netconf nexthop
```

路由删除事件只能说明发生了什么，不能单独识别发起删除的进程。需要结合服务时间线、源码行为及对照测试判断。

## 维护限制

- 当前验证覆盖 switch 和服务重启，不覆盖整机重启、所有网络切换或异常退出。
- 正常停止 sing-box 并删除 tun0 后，系统可能退回 eno1 的 DNS，重新使用该链路的 DNSSEC 设置。
- tun0 若残留，networkd 可能继续公布一个没有服务处理的 DNS 地址。
- 应用缓存的 FakeIP 不会因 sing-box 停止而自动失效。清理 resolved 缓存也不会清理所有浏览器缓存。
- 不应把“反复重启 networkd”作为正式恢复机制。先区分 DNSSEC 拒绝、DNS 服务不可达和实际出口路由丢失。
- 本次不需要 fork sing-box。若以后改回由 sing-box 单独管理 DNS，应重新设计链路所有权和 DNSSEC 设置时序，不与当前 networkd 管理方式混用。
