# Realm HTTP 节点身份迁移

当前节点认证只使用原生 `http_fqdn` 插件。仓库不再提供 join-token 插件配置、生成命令或安装命令。
本次部署范围是 eihort、abhoth、azasos、nodens、yidhra、hastur。跳过 uubboo 和 kaambl，hastur 最后迁移。
源码配置完成不代表节点已经部署。逐台记录实际 generation、Agent ID、业务检查和回滚状态。

## 1. 检查管理通道和 mesh

用现有 SSH host key 或 CA 检查目标主机身份。不要关闭 SSH host-key 检查，也不要把未知服务器的 key 当作可信配置。
确认本地 SSH agent 能签名，远端 root 管理命令可用。仅 TCP 22 可连接不表示 SSH 认证成功。

当前控制通道是 `eihort.nyaw.xyz:8081`。Realm 配置将它固定映射到 `fdcc::3`。
节点的 HTTP 证明地址由 registry 固定，例如 `abhoth.nyaw.xyz` 对应 `fdcc::5:18091`。
Server 直接拨号到登记 IP，不查询公网 DNS或使用 NSS。FQDN 仍用于精确允许列表和 HTTP Host。

先检查 WireGuard、VXLAN 和路由。HTTP 证明依赖这条管理认可的可信路径，普通域名解析或 mesh 可达性本身不能提供节点密码学证明。
不要把 bootstrap 流量改接到依赖 SPIRE 身份的 Caddy 或 Realm gateway。

## 2. 保留并更新公共信任 bundle

保留现有 SPIRE Server 签名密钥、数据库和信任域。本次不轮换根 CA，不删除 Server 状态。
从 Eihort 已验证的管理通道导出公共 bundle：

```sh
ssh -n root@eihort.nyaw.xyz \
  'spire-server bundle show -socketPath /run/spire/server/private/api.sock' \
  > /tmp/realm-spire-public-bundle.pem
openssl x509 -in /tmp/realm-spire-public-bundle.pem -noout -dates -fingerprint -sha256
```

这份文件只能包含公共证书。先检查证书和指纹，再通过 SSH 安装到本轮目标节点的
`/var/lib/realm-spire/trust-bundle.pem`，由 root 管理。现有目录可以继续持久化。
不要从未验证的 HTTP challenge 端点下载初始根，也不要把 CA 私钥放入 Nix store。

同样的分发可以用 `just sync-trust-bundle` 完成：它从 Eihort 读取 `bundle show`
的输出，拒绝包含私钥的内容，校验 SHA-256 后以 0600 root 原子安装到
Eihort、Abhoth、Azasos、Nodens、Yidhra、Hastur；旧文件保留为
`trust-bundle.pem.before-sync`。`REALM_TRUST_BUNDLE_DRY=1` 只做取回与校验。
该文件是 bootstrap 材料：运行中的 Agent 会继续从 Server 同步 bundle，
所以更新后无需重启，只有 Agent 冷启动才读取此文件。

这个路径保留的是可信公共材料，不是旧 token 协议。新节点也可以用模块的
`trustBundle.path` 或 `trustBundle.text` 分发同一份公共 bundle。
Server CA 正常轮换后，长期离线节点仍可能需要更新 bootstrap bundle。

## 3. 准备 Server 和每台机器的回滚材料

先构建目标 generation，检查激活差异。保留上一代 system profile 和能到达它的 SSH 管理路径。
Nodens 使用 aarch64 构建器。Yidhra 内存较小，不进行无关 GC，不删除上一代 generation。

网关的 `ExecStartPre` 会调用 `caddy validate`。该命令在 unit 之外手动执行会一直挂起，
因为 SPIFFE 注册要求 `systemd:id` 与 `unix:user` 两个 selector 同时命中；详见
[docs/troubleshooting/2026-10-29-caddy-validate-spiffe-hang.md](troubleshooting/2026-10-29-caddy-validate-spiffe-hang.md)。
验证网关只能看运行后的端口与指标，不要依赖手动 validate。

先让 Eihort 的 Server 加载 `http_fqdn`，生成节点允许列表和稳定别名注册。Server 继续使用现有状态目录。
切换 Eihort 本机 Agent 也需要下面的缓存迁移步骤。不要假定改了插件名称就会得到新身份。

每台机器在切换前记录：

- 当前 `/run/current-system`、Agent 实际 `StateDirectory` 和健康状态。
- 当前实际 Agent ID，以及它关联的稳定别名注册。
- 当前失败单元，避免把原有故障误算为本次迁移。
- 本次授权的原生节点 ID，例如 `spiffe://nyaw.xyz/spire/agent/http_fqdn/abhoth`。

这些记录放在 root-only 迁移目录，不收集应用秘密或完整环境变量。

## 4. 逐节点强制一次原生 HTTP attestation

顺序是 Eihort Server 准备、Abhoth 试点、其他可用节点、Hastur 最后。
Eihort 本机 Agent 在 Server 和本机 responder 就绪后迁移。不要触碰 Uubboo 或 Kaambl。

每台机器使用维护窗口。Agent 的依赖代理可能重启，现有连接可能中断。
先激活新 generation，保留现有 Agent 缓存，让 Server、独立 responder 和新注册条目就绪。
确认 responder 只监听该节点的 mesh 地址。确认 Server 能访问对应 `18091`，并确认节点能认证 Server 的 TLS 身份。

代理的 `Upholds` 依赖可能自动拉起 Agent，直接停止它可能被取消。
强制重新认证时，先对 Agent 做临时 runtime mask，再用不可取消的 stop job 停止它。
将实际 Agent 状态保存到 root-only 备份目录，清空运行目录，然后解除 mask、重新加载 unit 并启动 Agent。
默认目录是 `/var/lib/spire/agent`，但必须以该机器 unit 的 `StateDirectory` 为准。
恢复代理时，先清除相关 socket 的启动限制并启动 socket，再启动代理 service。
不要复制或清理 `/var/lib/spire/server`、Server 密钥或注册协调器状态。
保留旧 Agent 状态用于退役前的回滚，不输出其中的私钥。
逐台验收后取消该节点的自动回滚定时器，再继续下一台。

验收必须检查：

- Server 记录的实际 ID 是 `.../spire/agent/http_fqdn/<hostname>`，认证类型是 `http_fqdn`。
- `.../agent/<hostname>` 稳定别名指向新实际 Agent，workload 仍使用原来的父身份。
- Agent、responder 和依赖代理工作正常，实际 workload 能取证并访问获准服务。
- 未授权身份继续被拒绝，业务和观测没有本次新增的失败。
- 普通 Agent 重启复用有效身份。需要重新 attestation 时，仍能经新协议完成。

`active` 状态本身不够。有效的旧缓存可能绕过新 attestation，所以必须检查实际 Agent ID。

业务检查只做本次授权范围内的操作，不发送测试邮件、消息或执行无关的数据写入。
对 eihort 检查 PostgreSQL、Redis、S3、业务入口、Internet gateway、Loki 和指标链路。
对 abhoth 检查 Stalwart 入口和 rustypaste。对其余节点检查本机 workload、Alloy 或网关。
从应用实际 UID、cgroup、namespace 和 hosts 视图检查连接，不能只用宿主机 root 的 curl 代替。

## 5. 退役旧身份并记录结果

单个节点验收通过后，封禁它的旧实际 Agent ID，并删除该旧身份关联的自动别名。
保留新的 HTTP 别名和 workload 注册。不要仅按稳定 SPIFFE ID 批量删除所有同名条目。
不要封禁跳过节点的旧身份。

旧 token 文件可以在本节点成功迁移后删除。公共 trust bundle、Agent 私钥持久化和 Server 状态仍需保留。
关闭旧插件不等于撤销已签发的证书，也不会终止现有 TLS 连接。需要紧急撤销时单独处理相关连接和进程。
跳过节点仍保留已有身份记录，但以后失去身份时需要明确迁入新协议。

旧身份退役前，如果新认证失败，保留日志并停止新 Agent。恢复之前的 generation 和 Agent 状态，再检查实际业务。
旧身份退役后，不再恢复已封禁的旧 Agent 缓存。业务回滚必须保留 HTTP attestor 和当前 Agent 状态，或重新做 HTTP 认证。
成功后的 HTTP Agent 状态同样保存在 root-only 恢复目录。已退役操作的旧回滚脚本必须阻止旧身份恢复。
不要通过关闭证书检查、接受任意 IP 或重新引入 token 代码来绕过失败。
系统回滚不会回滚数据库迁移、应用数据或已经泄露的秘密。

在部署记录中列出每个节点的结果。没有 SSH 认证、bundle、路由或测试前提的节点标为阻塞，不能记作部署成功。
