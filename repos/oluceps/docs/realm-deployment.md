# Realm 首次部署

当前应按 **eihort → abhoth → eihort 业务验收 → hastur / uubboo → 其余节点** 的顺序切换。
eihort 提供 SPIRE Server 和主要业务；每个 Realm 节点提供本机 Internet Envoy，abhoth 提供 SMTP ingress。
这里的命令在仓库根目录、Bash 中执行，假设已有 `root@<hostname>` SSH 连通性。
每个 mesh 节点运行本地 CoreDNS，继续在 127.0.0.1:8600 提供发现域解析。ghostunnel 直接连接构建期 catalog 中的目标，不再通过 Caddy 解析 SRV。VXLAN mesh 必须可用，各 Agent 必须能连接 eihort 的 SPIRE Server TCP 8081。

## 每节点 Internet Envoy

先部署 eihort，更新各节点的 SPIRE 注册和 vmagent 抓取列表。然后逐节点部署并检查
`realm-internet.service`、`realm-observability.service` 和 Alloy。检查网关取得证书后，
再从应用的本地代理发起请求。服务启动和指标可抓取不能代替实际出网检查。

所有 `internet-proxy` 出口声明默认选择本机，包括容器手写的 `egress`。
现有 SPIFFE 许可名单、CONNECT 端口规则和主机公网路由保持原样。
网关故障时不会自动改为直连或切换到其他节点。SPIRE Server 仍在 eihort。

azasos 的 ntfy 和 subs 从 eihort 出口切换为本机出口。其 IPv4 默认路由走 WARP，
IPv6 走原生网络，验收时分别检查两类目标。其他已有出口调用方位于 eihort。
无法连接的节点保留待部署状态，不能仅凭 catalog 中存在记录就视为网关上线。

Alloy 从 `/etc/alloy/realm-internet.alloy` 采集网关日志，按 `host` 标记。
该文件通过 `environment.etc` 写入，已运行的 Alloy 重载看不到新文件，需要重启 `alloy.service`。
yidhra 只有 452 MB 内存，不启用 Alloy，网关日志只留在本机 journal。
新增节点后需要部署 vmagent，抓取列表由 Nix 配置生成。

## 从 Consul 迁移到 CoreDNS

每个节点的 zonefile 都来自同一套 flake；发布变动后需要部署到查询它的节点。
替换现有集群时先部署 Consul client 节点，再逐台处理 server 节点。
尚未切换的节点仍依赖 Consul，所以移除 server 前先执行 `consul leave`，
让 Raft 成员数随退出缩减，避免直接停止多个 server 导致旧节点失去 quorum。
CoreDNS 上线后检查 `systemctl is-active coredns`，并用下面的 dig 命令验证。

## 本轮身份与连接迁移

先部署 eihort，使 SPIRE 注册清单包含各节点的 `caddy-<hostname>` 身份。
再逐台部署 Caddy 调用节点和接收入口。旧 `service/caddy` 与新身份不互通，
因此分批切换期间可能出现短暂的业务中断。不要为避免中断而永久保留共享身份授权。
注册地址不变，但地址或端口变更仍需部署到使用该目标的客户端。

同机 PostgreSQL 客户端改用 Unix peer。Misskey 保留原配置中的本地 TCP 地址，
helper 直接连接挂载的 Unix socket，容器仍为 `network=none`。
Vaultwarden 的最后一份环境文件覆盖旧数据库 URL。其他秘密值不需要改动。
Garage 已从 eihort 的导入中移除，数据目录不删除。

## 切换前

- 保留 PostgreSQL 和应用数据的备份。系统 generation 回滚不会撤销应用的数据库迁移。
- Loki、Misskey 的加密配置已与本地修改后的配置核对一致，本轮无需再次修改 secret。
- `sec` 子模块新增的 Telegram Search 加密 cache 必须随部署源一起保留；若通过 Git 提交/拉取部署，先提交子模块中的加密文件，再提交主仓库的子模块指针和配置。
  本地部署也要确保新增文件已被 Git 跟踪。`plaintext-secret/` 继续保持 ignored，不能提交，也不要使用 `path:` flake 将其复制到 Nix store。
- 在 Immich 管理界面把持久化的 `machineLearning.urls` 改为 `[ "http://127.0.0.1:3003" ]`。
  当前保留 `settings = null`，仅改环境变量不能覆盖数据库里已保存的设置。
- 检查 Grafana 数据库中已有的 Loki datasource，地址应为 `http://127.0.0.1:13030`。
- 暂不启用 NCPS 本地 substituter；等 NCPS 业务验证完成后再按需启用。

先构建两个首批节点，构建完成不会切换远端系统：

```bash
nix build \
  .#nixosConfigurations.eihort.config.system.build.toplevel \
  .#nixosConfigurations.abhoth.config.system.build.toplevel \
  --no-link
```

本次检查修正了两个部署问题：Telegram Search 改用已检查空闲的 UID 1983，避免与现有 bird2 的 UID 983 冲突；
应用专用 `/etc/hosts` 会移除被覆盖域名的宿主机旧地址，避免 S3 / SMTP 仍选中宿主机 IPv6 地址。

## 1. 部署 eihort 并 enrollment

```bash
nixos-rebuild switch --flake .#eihort --target-host root@eihort
ssh root@eihort 'systemctl is-active spire-server.service realm-spire-register.service'

set -o pipefail
ssh -n root@eihort realm-enroll eihort |
  ssh root@eihort realm-install-enrollment

ssh root@eihort 'systemctl is-active spire-agent.service'
ssh root@eihort 'systemctl restart envoy.service'
```

首次 switch 时，Agent 尚未 enrollment，部分业务和代理可能启动失败，因此 switch 可能返回非零。
先确认系统已切换、SPIRE Server 和注册协调器正常，再执行 enrollment；构建、Vaultix 或 userborn 的错误需要先修复。
不要把所有 switch 错误都当作 enrollment 问题忽略。

`realm-install-enrollment` 会重启 Agent，并在启动检查中等待其健康。
enrollment JSON 含一次性 token，通过 SSH 管道直接传输；不要输出、保存或粘贴到日志。
业务 ingress 和 egress 大多会自动重试，触及启动次数限制的单元需要在 enrollment 后手动重启。

确认出口与关键入口有对应的 SRV 记录；记录存在不代表服务已经就绪：

```bash
ssh root@eihort 'dig @127.0.0.1 -p 8600 +short SRV internet-proxy.svc.mesh.nyaw.xyz'
ssh root@eihort 'dig @127.0.0.1 -p 8600 +short SRV loki.svc.mesh.nyaw.xyz'
ssh root@eihort 'systemctl --failed --no-pager'
```

CoreDNS 从整套 flake 配置生成节点 AAAA 和 ingress 的 AAAA/SRV，停止的服务仍保留记录。若记录为空，检查本机 coredns.service、/etc/coredns/mesh.zone 以及对应 ingress.service 声明；不要改为直接连接旧明文端口。服务增删或端口变化后，要把更新部署到相关客户端节点。ghostunnel 的目标来自构建期 catalog，运行时不查询 SRV。

## 2. 部署 abhoth 并 enrollment

```bash
nixos-rebuild switch --flake .#abhoth --target-host root@abhoth

ssh -n root@eihort realm-enroll abhoth |
  ssh root@abhoth realm-install-enrollment

ssh root@abhoth 'systemctl restart envoy.service realm-ingress-stalwart-submission.service'
ssh root@abhoth 'systemctl is-active spire-agent.service realm-ingress-stalwart-submission.service'
ssh root@eihort 'dig @127.0.0.1 -p 8600 +short SRV smtp-submission.svc.mesh.nyaw.xyz'
```

Stalwart 保留现有公网邮件监听；应用使用新增的 mTLS submission ingress。
abhoth 就绪后再验收 Forgejo、Vaultwarden 的实际发信。

## 3. 在 eihort 验收业务

查看失败单元和相关日志：

```bash
ssh root@eihort 'systemctl --failed --no-pager'
ssh root@eihort 'journalctl -u spire-agent.service -u envoy.service -u realm-spire-register.service -n 100 --no-pager'
```

按依赖方向处理失败单元：

1. PostgreSQL、Redis、Meilisearch。
2. SeaweedFS / S3、Internet gateway、相关 ingress。
3. Loki、Grafana、Misskey、Immich、Synapse、mautrix-telegram、Calibre、Telegram Search、Jellyfin、Vaultwarden、Forgejo、NCPS。
4. Caddy 对应业务路由、Alloy、vmagent 的采集。

正常依赖由 systemd 管理，无需逐个停止或重启所有服务。对仍失败的单元执行 `systemctl restart <unit>`；
例如 Forgejo / NCPS 若在首次 enrollment 前启动失败，可以单独重启 `forgejo.service ncps.service`。
首次从 DynamicUser 迁移到静态代理账户时，要重启 Caddy，使进程使用新的 UID/GID；仅 reload 配置不会更新进程凭据。
PostgreSQL 只接受 Unix socket。用 `runuser -u postgres -- psql -Atc "SHOW listen_addresses"` 检查空监听地址，并检查实际 HBA 配置。
SeaweedFS 的私有 `/tmp` 需要可写，它会在其中创建内部 gRPC Unix socket；只有 master 监听、没有 S3 监听时不能视为就绪。

验收实际使用的功能：

- 从公开域名访问应用，检查登录、数据读取和写入；Jellyfin 检查播放和转码。
- Misskey 检查发帖、远程抓取及媒体；Synapse 检查联邦；mautrix-telegram / Telegram Search 检查实际 Telegram 连接。
- Immich 检查模型下载与推理。容器 fixture 和 SPIFFE 连通性测试不能代替真实镜像与业务数据的验收。
- Forgejo / Vaultwarden 检查发信；Forgejo / NCPS 检查 S3 读写。
- 本地缓存适配器应返回 cache info：`ssh root@eihort 'curl -fsS http://127.0.0.1:18502/nix-cache-info'`。
  它的 `/metrics` 应返回 403；观测走独立 ingress。
- 在应用用户下通过 `/run/postgresql` 检查 peer 登录和错误角色拒绝。宿主机和私有 namespace 都不应有 TCP 5432 监听。跨主机仅保留 Autopeer 的 mTLS 入口 15438。

新配置的 Misskey、Telegram Search 都是 rootless Podman。检查容器时使用对应用户，例如：

```bash
ssh root@eihort 'runuser -u misskey -- podman ps'
ssh root@eihort 'runuser -u telegram-search -- podman ps'
```

若旧 rootful 容器仍存在，先确认已停止且无端口冲突；保留原数据，不要顺手删除卷。

## 4. 逐台部署其余节点

先部署 hastur、uubboo，再部署 azasos、kaambl、yidhra、nodens。
同一批内没有严格的主从顺序，但每台应完成 switch、enrollment 和观测验收后再继续。

普通 x86_64 节点以 hastur 为例：

```bash
nixos-rebuild switch --flake .#hastur --target-host root@hastur
ssh -n root@eihort realm-enroll hastur |
  ssh root@hastur realm-install-enrollment
ssh root@hastur 'systemctl restart envoy.service'
ssh root@hastur 'systemctl is-active spire-agent.service envoy.service'
ssh root@hastur 'systemctl --failed --no-pager'
```

nodens 是 aarch64，沿用仓库中的远端构建方式：

```bash
nixos-rebuild switch --flake .#nodens \
  --build-host elen@fdcc::8 --target-host root@fdcc::8
ssh -n root@eihort realm-enroll nodens |
  ssh root@nodens realm-install-enrollment
ssh root@nodens 'systemctl restart envoy.service'
```

yidhra 在 `util.nu` 中有单独部署流程；该流程会删除旧 generations、执行 GC 并停止部分基础设施服务。
首次迁移前检查是否仍需要这些历史步骤，不要直接批量调用该分支而丢失回滚版本。

每切换一个节点，都检查其 `observability-<hostname>` SRV 和 vmagent targets。
旧节点尚未部署时，新采集配置对应的观测目标暂时不可用；全部节点 enrollment 后应恢复。
最后确认集群没有本次迁移产生的失败单元，业务和观测均通过，再按需启用本地 NCPS substituter `http://127.0.0.1:18502`。

## 后续部署与状态保留

后续普通配置更新不需要重新 enrollment。保留各节点的 `/var/lib/spire`、`/var/lib/realm-spire`，
以及 eihort 的 `/var/lib/realm-spire-registrations`；这些是运行状态，不能加入 Git 或 Nix store。
长时间离线导致 Agent 身份过期时，重新生成 token 并 enrollment。

遇到故障优先查看失败单元日志、Agent 健康、本机 CoreDNS 和生成的 zonefile。需要系统回滚时使用保留的上一代 system profile；
数据库和应用文件的回退另按备份恢复处理。
