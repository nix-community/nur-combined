# systemd 代理加固与 shh 测试记录

2026-10-22，在 `eihort` 实测 shh 建议，并测试加入限制后的服务。当前测试部署使用 `/run/systemd/system/*.service.d/95-shh-validation.conf`，没有切换整机 generation。仓库中的 Nix 配置供后续正常部署使用。主机重启会清除本次运行时覆盖。

本文是 2026-10-22 的历史测试记录。下文 `realm-socks-mautrix-telegram` 等 unit 和计数属于当时配置；
当前桥接已改为 realm-agent 透明 TCP，Internet gateway 使用 Caddy。这些历史测试不证明本次配置迁移后的业务行为。

## 范围

| 项目 | 范围 |
|---|---|
| 公共限制 | `lib/proxy-hardening.nix` |
| Realm | `nixosModules/realm-workloads.nix` 生成的 ghostunnel、socket-proxyd、gost 和 bridge 代理 |
| 独立代理 | `sept-proxy`、`cloudflared-tunnel` |
| DNS 修复 | 仅为 eihort 的 Cloudflared 启用 `edgeDnsOverHttps` |
| 配置求值 | 10 个主机配置，其中 8 个配置合计包含 226 个 Realm 代理 unit |
| 主机测试 | eihort 的 132 个 Realm unit 加上两个独立代理，共 134 个现有 unit |
| 实际重启 | 这 134 个 unit 中原本运行的 100 个 unit |

本次没有为业务应用、数据库、容器运行时、SPIRE Agent 或 namespace holder 加入公共限制。其它主机没有部署或运行测试。本文的功能结论仅适用于下述测试覆盖。

## 限制选择

共同限制包括内核参数、模块、日志、控制组和时钟保护，以及 `LockPersonality`、`RestrictRealtime`、`MemoryDenyWriteExecute`。系统调用拒绝规则覆盖 17 个组，并以 `EPERM` 返回错误。

NixOS 为列表中的每项生成一条 `SystemCallFilter=`。因此，每项都带 `~`。如果只在首项写 `~`，后续正向组会从拒绝集合中移除调用。

每个组的限制都来自代表性代理的 shh 采集结果。公共规则没有加入 `@process`、`@sandbox` 或 `@ipc`，因为各代理的采集结果不同。没有使用文件路径白名单、远端 IP 白名单或采集所得的 socket bind 限制。保留现有 IPv4、IPv6、Unix socket、临时目录与连接目标。

Realm 继续使用原有的空 capability 集合和私有网络模型。Sept 使用空 capability 集合。Cloudflared 的 capability 上限保留 `CAP_NET_BIND_SERVICE` 和 `CAP_NET_RAW`，没有新增 ambient capability。

## shh 采集

环境：shh `2026.3.8`、strace `7.2`、systemd `261.2`、Linux `6.18.54`，架构为 x86_64。

成功采集的生产 unit：

- `realm-egress-caddy-grafana`
- `realm-ingress-grafana-http`
- `realm-local-grafana-victoriametrics`
- `realm-backend-loki-http`
- `realm-socks-mautrix-telegram`
- `sept-proxy`
- `cloudflared-tunnel`

采集包含启动、实际请求、连接关闭与服务停止。Cloudflared 的有效采集发生在 DNS 恢复之后，期间 `/ready` 返回 200，公网请求也返回 200。未保存原始 strace 内容或服务凭据。

### ptrace 权限

eihort 设置 `kernel.yama.ptrace_scope=2`。最初无特权采集失败，相关代理无法处理请求，随后恢复了原服务。

成功采集时，仅为目标 unit 临时设置 `CAP_SYS_PTRACE` 的 bounding 和 ambient capability。主机的 ptrace sysctl 保持为 2。采集结束后，移除了这些权限与 shh profile dropin。加固后的 100 个运行进程均未保留 `CAP_SYS_PTRACE`。

### Socket activation

systemd 261 同时传递 `LISTEN_PID` 和 `LISTEN_PIDFDID`。shh 改变目标进程身份后，单独更新 PID 仍会使 libsystemd 拒绝监听 FD。

采集时，在 `shh run --` 后、实际代理前加入以下临时包装器：

```sh
#!/bin/sh
unset LISTEN_PIDFDID
export LISTEN_PID=$$
exec "$@"
```

包装器保留 `LISTEN_FDS`、`LISTEN_FDNAMES` 和监听 FD。独立 fixture 先测试了该方法，然后生产代理在采集期间完成实际请求。采集完成后移除了包装器。

shh 在目标启动失败时也可能退出 0 并产生建议。因此，必须检查真实请求与目标日志，不能仅依据 shh 的退出码。

## Cloudflared 重启与 DNS

重启暴露了现有 DNS 路径的问题：`argotunnel.com` 名称解析到 sing-box Fake IP，QUIC 无法连接。旧进程已有的连接曾继续工作。该故障在移除全部 shh 设置后仍存在。

`services.cloudflared.edgeDnsOverHttps = true` 为 Cloudflared 启动独立的 SmartDNS resolver，监听 `127.0.0.55:53`。仅 `argotunnel.com` 及其子域通过经过证书检查的 Cloudflare DoH 查询。其它名称仍交给 `127.0.0.53`，保留主机 DNS 分流。没有固定 Cloudflare edge IP。

Cloudflared 的挂载命名空间使用专用 `resolv.conf`。`GODEBUG=netdns=go` 使它使用该文件。主机和其它服务的 resolver 配置保持不变。

resolver 使用 DynamicUser、单个 bind capability 和公共加固规则。实测 UDP/TCP DNS、A/AAAA 查询及 mesh 名称解析。替换临时恢复程序后，重启 resolver 与 Cloudflared，四条 QUIC 连接恢复，`/ready` 返回 200。临时 Python resolver 和测试进程均已移除。

## 测试结果

| 检查 | 结果 |
|---|---|
| 加固前的 18 项应用、指标与代理请求 | 全部 200 |
| 同样 18 项请求在采集期间及加固后 | 全部 200 |
| 扩展主机测试脚本 | 23 项请求全部 200 |
| 100 个原本运行的 unit | 全部 active，`NRestarts=0` |
| 这 100 个进程的 seccomp | 全部为 filter 模式 |
| 这 100 个 unit 的 `MemoryDenyWriteExecute` | 全部启用 |
| 加固后权限错误与 seccomp 失败日志 | 未发现匹配记录 |
| 主机失败 unit | 0 |
| NixOS 整机 derivation 求值 | 通过 |
| 134 个相关 unit 与新 resolver 的构建 | 通过 |
| Nix 格式和差异空白检查 | 通过 |
| 完整 VM 回归，包括新增传输与重启检查 | 通过，测试脚本用时 51.71 秒 |

`tests/realm-vm.nix` 测试合法和非法 SPIFFE 身份、PostgreSQL peer 认证、IPv4/IPv6、SOCKS、证书轮换、DNS 变化、路径权限和私有网络隔离。新增的传输测试发送 1 MiB 随机二进制数据，比较完整响应，并在四个代理重启后重复测试。

`systemd-analyze security` 的分数越低，表示检查项中的暴露越少。该分数不能替代功能测试。

| 代表性 unit | 加固前 | 加固后 |
|---|---:|---:|
| Sept proxy | 8.1 | 1.3 |
| Cloudflared | 9.2 | 1.8 |
| Realm egress | 4.2 | 1.7 |
| Realm ingress | 4.0 | 1.5 |
| Realm local / backend / SOCKS | 3.5 | 1.0 |

## 重复测试

在仓库根目录运行主机检查，通常需要 5 至 20 秒：

```sh
ssh root@eihort python3 - < tests/eihort-hardening.py
```

运行完整 VM 回归。依赖已在 store 时，测试脚本约需 60 秒，构建时间另计：

```sh
nix-build tests/realm-vm.nix \
  --arg nixpkgs "$(nix eval --raw .#nixosConfigurations.eihort.pkgs.path)" \
  --no-out-link
```

当前运行时覆盖清单在 eihort 的 `/run/shh-validation/applied.json`。原本运行的 unit 清单在同目录的 `active.json`。撤销 Realm 和 Sept 的运行时加固时，移除对应的 `95-shh-validation.conf`，然后 daemon-reload 并重启这些 unit。

Cloudflared 的覆盖同时包含 DNS 修复。撤销其加固时，保留 resolver unit、`Requires`、`After`、`GODEBUG=netdns=go` 和专用 `resolv.conf` 的 `BindReadOnlyPaths`，仅移除其它加固属性。否则，原有 Fake IP 故障可能再次出现。

本次没有测试主机重启、其它节点的运行行为，或所有业务应用的完整用户流程。shh 的采集结果也不保证未来版本和未覆盖功能兼容。升级代理、内核或 systemd 后，应重复请求、身份、传输和重启测试。
