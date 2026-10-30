# SPIRE 长期上游 CA 接入记录

本记录对应 2026-10-30 的接入工作。用户已授权实施和部署。

**当前阶段：配置、凭据接线和隔离测试已完成；生产切换尚未执行。**
远程部署被本地 rbw 锁定阻塞：`rbw unlocked` 返回 `agent is locked`，SSH agent 无法签名。
不能将已构建的 generation 记作已部署。Uubboo 和 Kaambl 的 TCP 22 当前也不可达。

## 目标与材料

使用原有 Milieuim Root 签发的专用 Realm intermediate，直接以 intermediate 为 Realm 信任锚。
不重新签发证书，不将原根私钥部署到服务器，不延长内部 CA/SVID 生命周期。

- 长期 intermediate：`Milieuim Realm SPIRE Intermediate P384`。
- 有效期：2026-10-29 05:37:53 UTC 至 2036-10-26 05:37:53 UTC。
- SHA-256（DER）：`5B:A6:E1:B6:9D:98:4D:66:A7:E1:32:3A:95:1E:7D:C2:50:C1:97:45:4C:7B:8F:5F:02:27:35:08:BF:41:55:40`。
- 公开 PEM：[upstream-ca.pem](../pki/realm-spire/upstream-ca.pem)。
- 原根的 `pathLen:1` 不允许验证经过两层下级 CA 的完整链；验证必须止于专用 intermediate。

已比较证书和私钥导出的公钥，确认匹配；Vaultix 管理密文解密后的公钥也匹配。
私钥没有输出到日志、复制入仓库明文或进入 Nix store。

## 配置实现

- `realm.spire.server.upstream` 提供可选的 disk 上游接线，仅 eihort 启用。
- 公共 certificate/bundle 需为完整 PEM，拒绝私钥标记；私钥选项只接受绝对运行时字符串。
- eihort 的 Vaultix secret 是 `realm-spire-upstream-key`，root:root、0400。
- systemd 通过 `LoadCredential` 将私钥交给 Server；上游插件读取 `$CREDENTIALS_DIRECTORY/realm-upstream.key`。
- 私钥只在 eihort 有对应主机加密缓存，管理密文保留管理员恢复 recipient。
- 公共 CA 使用独立内容寻址文件，避免无关 flake-source 变动导致 Server 因证书路径变化而重启。
- Server 明确保持 `ca_ttl = "24h"`，默认 workload SVID 保持 1h。
- Agent 保持 `rebootstrap_mode = "always"`，明确设 `rebootstrap_delay = "30s"`。
  SPIRE 默认 10m 延迟超过本项目 300s 的 API readiness 启动门限；30s 留出重新认证余量。
- 最终 Agent bootstrap 经 `trustBundle.path` 固定为单张长期 intermediate；运行时动态 bundle 仍由 SPIRE 管理。

`just sync-trust-bundle` 的默认来源已经改为仓库固定公共锚，不再导出 Server 的动态短期 bundle。
过渡 old+new bundle 使用显式的 `sync-trust-bundle-transition`，不覆盖 generation 管理的路径。
本地 dry-run 验证 PEM、有效期、CA 属性和全部八台 Realm 节点清单，不访问远端。

## 隔离验收

使用 flake root 实际锁定的 nixpkgs `e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa`、SPIRE 1.15.3。

配置测试：

```sh
nix eval --offline --json --impure --expr \
  'import ./tests/realm-spire-upstream.nix { nixpkgs = /nix/store/44zyg8i46md22kjs7hr3bdvia86rpd8p-source; }'
nix eval --offline --json --impure --expr \
  'import ./tests/realm-spire-http.nix { nixpkgs = /nix/store/44zyg8i46md22kjs7hr3bdvia86rpd8p-source; }'
```

两者均返回 `[]`。八台主机配置断言均通过。

实际运行的迁移 VM：

```sh
nix build --offline --impure --no-link --print-out-paths --option sandbox true \
  --expr 'import ./tests/realm-spire-upstream-migration-vm.nix {}'
```

通过输出：`/nix/store/vq01rmcb8vz2bs2kljdschd1w1ky2y3w-vm-test-run-realm-spire-upstream-migration`。
VM 测试 155.51 秒，迁移与回滚阶段 99.15 秒；全部使用 VM 内生成的临时 PKI。

覆盖：

- 已有自签 Server、Agent、workload 和旧 PREPARED 槽位，保留 DB/keys/journal 加入上游。
- 显式 prepare 替换旧 PREPARED，检查新上游 SKI、旧 ACTIVE 未变和动态双信任。
- 激活前检查 Workload API bundle 已传播，再 activate 指定 authority ID。
- 固定长期 bootstrap 冷认证、保留缓存到真实过期后自动重新认证、旧锚失败与管理更新恢复。
- Server 重启、新证书链实际验证、Ghostunnel/Caddy/HTTPS CONNECT 和错误身份拒绝。
- 完整状态快照恢复回原 ACTIVE/PREPARED，业务恢复。

**仅恢复旧 Server 配置不等于恢复旧 PKI。** 本次 VM 中去掉上游并重启后，SPIRE 生成了另一张自签 ACTIVE，
长期 bootstrap 的冷认证失败；完整一致状态快照加对应 bootstrap 恢复才通过。
测试将重引导延迟缩短为 5s，不代表生产默认 10m 或本项目配置 30s 的等待时间。
测试没有修改时钟，也未实际等待生产 24h 周期。

## 部署阶段与门槛

部署使用 `/home/riro/Src/nixos-ca-rollout-20261030` 隔离 checkout，基于 `79f40e9d`，
只接入 CA 相关变更；不夹带之后提交的 Envoy/应用代理清理。

1. 经已验证 SSH 导出现有公开 bundle，与长期锚合并并预分发，逐节点记录实际指纹。
2. 在 eihort 保存一致的 Server 状态、配置、旧 generation 和公共 bundle 恢复点。
3. 激活保留 runtime bootstrap 的 Server 过渡 generation，确认旧 ACTIVE/PREPARED 与数据库保留。
4. prepare 后检查上游 SKI、Server/Agent 双 bundle 传播和旧链业务，再 activate 指定 ID。
5. 确认 Server 实际新链可由长期锚验证，逐节点部署最终固定 bootstrap generation。
6. 用非关键节点做受控冷认证，检查 HTTP ID、稳定别名、取证、实际业务和失败单元。
7. 未提前收到长期锚的离线节点恢复时，先经独立管理渠道补发公共锚。

prepare 不暂停自动轮换；部署前必须重新读取 authority 状态和切换窗口。
回滚不得仅切回旧 Nix generation。任何完整状态恢复都必须使用一致 DB/keys/journal、匹配配置和客户端信任，
并考虑快照后新增的身份、注册和 ban 状态。

## 生产记录（2026-10-30，+08 时区）

rbw 解锁后完成生产切换。所有命令经已验证 SSH 执行，节点地址来自 registry。
本地证据目录：`~/.local/state/realm-ca-rollout/20261030T020715`。

1. **预分发过渡 bootstrap。**导出 eihort 当前公开 bundle，与长期 intermediate 合并去重
  （3 张证书，SHA-256 `a20e35cc…57ee`），原子安装到六台在线节点
  `eihort/nodens/abhoth/azasos/yidhra/hastur`，逐台校验哈希一致，原文件备份为
  `trust-bundle.pem` 及 `realm-ca-20261030/bootstrap-before.pem`。**Uubboo、Kaambl TCP 22 不可达，
  未预分发**；它们恢复后需先经管理渠道补发固定公共锚。
2. **一致恢复点。**停止 eihort Server 后完整复制其 StateDirectory（SQLite、keys、journal），
  记录原 generation 与 authority，再恢复运行；备份位于 eihort `/var/lib/realm-spire/realm-ca-20261030/`，
  `server-snapshot-complete` 标记成功。
3. **过渡 generation。**激活 `…jwpp07kj…`（保留 runtime bootstrap）。首次 systemd-run 因 PATH
  缺 `nix-env` 失败且几条长连接 Ghostunnel 在停止阶段排空超时（vaultwarden/loki-s3/synapse-s3），
  socket+service 重启后全部恢复；重新执行 switch 校验通过。旧 ACTIVE `4b54c14a…` 与数据库保留不变。
4. **prepare 与验收。**`localauthority x509 prepare` 得到 `4ffcd16a…`，其上游 SKI
  `4f8f784f7ba0…` 与长期 intermediate 匹配；旧 ACTIVE 未变。Server bundle 与六台 Agent 的
  Workload API bundle 均确认包含全部旧锚与长期锚后才进入激活。
5. **activate 与新链。**激活 `4ffcd16a…`。直接用 `upstream-ca.pem`（partial-chain）完成
  `[fdcc::3]:8081` TLS 握手，Server SVID `spiffe://nyaw.xyz/spire/server` 验证通过；
  Server 需重启一次才呈现新链（旧叶证书仍在有效期内）。
6. **Nodens canary。**部署 ARM 最终 generation（本机构建 `…ahag4m53…`）后，移走 Agent
  状态并冷启动：HTTP attestation 成功，Agent ID 保持 `…/agent/http_fqdn/nodens`，
  `rebootstrap_delay=30s` 生效；Alloy 本机与跨机 Loki 均恢复 HTTP 200，证书观测
  bootstrap/canary/workloads 全部为 1。
7. **其余节点。**Abhoth、Azasos、Yidhra、Eihort、Hastur 依次部署。每台确认
  `/run/current-system` 为目标 generation、Agent 健康且 bootstrap 指向 Nix store 固定 PEM
  （SHA-256 `ba37da9c…23c22`，仅 1 张证书）、无失败单元、身份观测恢复、
  systemd-networkd/sing-box/caddy 主 PID 未变。Hastur 的隔离 checkout 基线与在线系统存在
  服务差异，已按主分支工作区重建专属 generation（`…k3xb5sqq…`）部署，避免回退。
8. **业务验证。**在应用真实 UID/cgroup/netns 内：Azasos `subs.service` 公网 HTTPS 200
  （无代理变量）；Eihort Forgejo 公网与 OIDC HTTPS 200（经 Unix socket 健康检查）；
  三台 Alloy→Loki 均为 200；Eihort/Hastur Alloy 就绪。mautrix-telegram 持续接收 Telegram
  实时更新并写入 Matrix，CA 切换无回归（当前 generation 仍含 SOCKS 适配器，属预期）。

### 滚动重启验证（2026-10-30 21:30–21:50）

按用户指令依次重启 5 个节点：`eihort` → `nodens` → `yidhra` → `abhoth` → `azasos`。
每台重启后等待新 boot_id、systemd 就绪、SPIRE Agent/Server 健康、观察者指标恢复且无失败单元，才继续下一个节点。

| 节点 | 新 Boot ID | 重启耗时 | 验证耗时 | 状态 | 验证结果 |
|---|---|---:|---:|---|---|
| **eihort** | `2cda1dac-f97f-453f-82b5-ba07f6c34424` | 107.1s | 65.4s | 正常 | Server/Agent healthy，Active authority `4ffcd16a…`，无失败单元 |
| **nodens** | `3ba3fa55-5453-4d40-88f3-9c27a938f0e5` | 47.3s | 190.0s | 正常 | Agent healthy，Babel 路由收敛后 `[fdcc::3]:8081` 恢复，全部观测指标 1，无失败单元 |
| **yidhra** | `6fbcbba3-0c91-4fe3-b1fd-1c4d48dd4d3a` | 47.5s | 119.1s | 正常 | Agent healthy，全部观测指标 1，无失败单元 |
| **abhoth** | `70a04256-0066-4e99-a9d0-451d28ef0155` | 83.0s | 139.7s | 正常 | Agent healthy，全部观测指标 1，无失败单元 |
| **azasos** | `e4e646f4-82bc-4591-b4b1-75356d6446d5` | 67.0s | 279.0s | 正常 | Agent healthy，VXLAN/Babel 收敛后恢复，全部观测指标 1，无失败单元 |

重启后全集群 6 台在线节点（含 hastur）复查：
- 全部节点 `spire-agent healthcheck` 正常返回。
- 全部节点 `realm_bootstrap_bundle_server_trust_valid` 均为 1。
- 全部节点 `systemctl --failed` 均为 0（无任何失败单元）。
- eihort 的 `postgresql`、`redis-misskey`、`forgejo`、`mautrix-telegram` 均正常运行；SPIRE Server 活动 authority 保持 `4ffcd16a…`。

### 部署后状态

- 六节点 Agent 唯一信任锚为固定长期 intermediate；运行时动态 bundle 由 SPIRE 继续维护。
- SPIRE 内部签发 CA 仍为 24h 自动轮换，workload SVID 仍为 1h。
- `bundle show` / Workload API 当前包含旧自签锚与新 intermediate；旧锚按其生命周期自然退出。
- 生产未实测超过 24h 的离线重入；对应机制由迁移 VM（真实过期 + 自动重认证）覆盖。

### 待办

- Uubboo、Kaambl 恢复可达后，先经管理渠道安装固定公共锚（`just sync-trust-bundle <node>`），
  再部署各自最终 generation 并冷认证验证。
- 主工作区的 Envoy 清理、mautrix/Forgejo 代理移除及 Telegram Search 删除尚未提交部署；
  本轮 CA 刻意不夹带。提交后部署将同时移除 `realm-socks-mautrix-telegram`。
- 旧自签信任完全退出后（约 24h CA + 缓存 TTL），可复查各端 bundle 只含新锚。

### 回滚要点

仅切回旧 Nix generation 不能恢复旧 PKI（迁移 VM 已实测）。如需完整回滚，使用
`realm-ca-20261030` 的一致快照、当时配置与配套 bootstrap，并接受快照后新增注册/ban 状态丢失；
新链 SVID 依赖旧锚验证失败的业务需等待重新取证。
