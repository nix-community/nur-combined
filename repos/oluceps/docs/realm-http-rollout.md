# Realm HTTP 节点身份部署记录

2026-10-28 完成六台节点的原生 `http_fqdn` 迁移。Eihort 继续运行 SPIRE Server。
Uubboo 和 Kaambl 未做系统切换或 Agent 迁移。Hastur 最后迁移。

所有目标节点的实际 Agent ID 都是 `spiffe://nyaw.xyz/spire/agent/http_fqdn/<hostname>`。
认证类型是 `http_fqdn`，`can_reattest` 是 `true`，`banned` 是 `false`。
每台机器只保留一个 `spiffe://nyaw.xyz/agent/<hostname>` 稳定别名，并指向新实际身份。

| 节点 | 架构 | 当前 generation 的 Nix store hash | 结果 |
| --- | --- | --- | --- |
| eihort | x86_64-linux | `m9m6qqlicc6az5hspjy1n81a3jkzhr8c` | 新身份、别名、业务检查通过 |
| abhoth | x86_64-linux | `575s51hpvv8r3s15d5bi899kn1pwdgdw` | 新身份、别名、业务检查通过 |
| azasos | x86_64-linux | `svwwfd3rhifrgwpv2m0nylyi9dmmqd7r` | 新身份、别名、业务检查通过 |
| nodens | aarch64-linux | `bq54wl2m34lq9l9alhasw6xzy4ipla76` | ARM 原生构建，新身份和业务检查通过 |
| yidhra | x86_64-linux | `kzzc40g5dnnh81rdy12ndmwss9x7pips` | 新身份、别名、业务检查通过 |
| hastur | x86_64-linux | `84862n7n5m2d8f0bvz1zl7iybb9c5y7s` | 最后迁移，新身份和业务检查通过 |

完整路径使用 `/nix/store/<hash>-nixos-system-<hostname>-26.11.20260926.e158d9e`。
当前 system profile 和 `/run/current-system` 必须指向同一 generation。

## 实际检查

Eihort 的 20 个原生 workload 通过了实际 UID、cgroup 和网络 namespace 检查。
检查按现有策略要求公网 DNS/HTTPS 成功，或要求外部 DNS 和公网 TCP 被拒绝。
未启动计划中的 Synapse S3 上传任务。Misskey 容器另做应用请求检查。

Eihort 的 Caddy→Misskey metadata API 返回 HTTP 200。
Caddy→S3 的实例图片读取返回 HTTP 200，内容类型是 `image/png`。
这些请求从 Caddy 的实际 UID、cgroup 和 namespace 发出。
PostgreSQL、Caddy、Misskey 和 Loki 单元均处于运行状态。

Abhoth、Azasos、Nodens 和 Hastur 的 Alloy→Loki `/ready` 请求返回 HTTP 200。
这些检查从 Alloy 的实际 UID、cgroup 和 namespace 发出，也检查了 DNS 和 TCP 拒绝策略。
Yidhra 的 Caddy→Autopeer `GET /api/peers/0` 返回 HTTP 200。
该只读请求还访问 Autopeer 的 PostgreSQL 连接，不修改 BIRD、WireGuard 或业务数据。

未注册的 root 进程向 Eihort Workload API 请求 SVID 时被拒绝。
六台目标节点均没有失败的 systemd 单元。Agent、responder 和两个 attestation socket 均运行。

## 旧身份和恢复材料

本次新增封禁 7 条旧 Agent 记录，并删除 13 条旧节点别名。
Uubboo 和 Kaambl 的现有别名和身份父节点均保留。
六台目标节点均无 `/var/lib/realm-spire/join-token`，当前 system profile 不再提供两个旧 enrollment 命令。
公共 bundle 仍位于 `/var/lib/realm-spire/trust-bundle.pem`。
本次保留 Server 状态、签名密钥和信任域，没有重建 CA。

每台机器的恢复目录是 `/var/lib/realm-http-migration/http-fqdn-89r87x70`。
Abhoth 最终成功操作使用追加 `-retry1` 的目录。
首次 Abhoth 操作在验收前触发定时回滚，随后重新迁移并通过验收。
所有相关回滚定时器均已取消。

恢复目录由 root 管理，权限是 `0700`。其中保留旧 generation 的 GC root、旧 Agent 状态，以及成功后的 HTTP Agent 状态。
私钥未进入 Git、Nix store 或部署报告。
旧身份退役后，自动回滚脚本会拒绝恢复已封禁的旧 Agent 缓存。
后续业务回滚必须保留 HTTP attestor 和当前 Agent 状态，或通过 HTTP 重新认证。

构建前的检查包括 42 项 HTTP 模块求值检查、相关 Realm 求值检查、Go 竞态检查和 vet，以及五个真实 SPIRE VM 测试。
操作步骤见 [迁移手册](realm-deployment.md)，信任条件见 [HTTP attestation](realm-http-attestation.md)。
