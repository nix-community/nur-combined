# Realm 身份与证书可观测性

直接指标已部署到 Abhoth、Azasos、Eihort、Hastur、Nodens 和 Yidhra。
Eihort 先做试运行，Hastur 最后切换。Uubboo 和 Kaambl 未部署、未迁移。
本文包含 2026-10-28/29 的部署与验收记录，并按当前实现更新 Internet Caddy 监控说明；历史巡检数量不代表当前配置清单。

看板：[SPIFFE 证书与节点认证](https://gf.nyaw.xyz/d/realm-spiffe-identity/3211a3c)。
[Internet Caddy 看板](https://gf.nyaw.xyz/d/envoy-zero-trust-egress/envoy-zero-trust-egress-gateways)
沿用既有稳定 UID `envoy-zero-trust-egress`，以兼容外部链接；名称和查询已对应 Caddy。
两个看板的 JSON 位于 `dashboards/`，供审查和恢复；不是自动 Nix provisioning。
本次仅同步仓库文件，没有发布看板或远程部署；下文线上查询和视觉验收均为历史记录，不构成本次 JSON 的验收。

## 部署后的检查结果

2026-10-28 UTC 完成以下检查。这是当时的检查记录，不替代实时值。

- 六台节点的独立 WireGuard 抓取、SPIFFE 网关抓取、原生 Agent telemetry 和 attestation 指标均有数据。
- 六台 exporter 的所有已启用 collector 均成功；各自的 pinned bootstrap bundle 均能验证当前 Server TLS 链及精确 SPIFFE URI。
- Eihort 管理元数据确认六台实际 Agent 均有效，认证类型为 `http_fqdn`、未封禁且允许重新认证；六个稳定别名均符合预期。
- 按进程配置了 178 个证书观察目标。最终巡检时 101 个成功观察，77 个处于 inactive/dormant；后者不算证书观察成功，也不算故障。业务活动会改变这个分布。
- 六台均无 failed systemd unit；当前系统代与持久化 profile 一致；观测部署的自动回滚 timer 均已取消。
- Eihort 的 20/20 原生 workload UID、cgroup、网络命名空间策略探测通过。未登记 root 进程不能取得 SVID。
- Eihort Caddy→Misskey 和 Yidhra Caddy→Autopeer→PostgreSQL 探测返回 HTTP 200。启用 Alloy 的五台节点到 Loki `/ready` 均返回 HTTP 200。
- Nodens 的现有 adonbox、Caddy、BIRD 和网络配置被保留；没有部署工作区中尚未上线的容器、配额或路由变更。
- 新规则组的实时查询没有 pending 或 firing。此结论只针对本节新增的身份规则，不表示系统中没有其他告警。

| 节点 | 证书观察目标 | 集中身份日志 |
| --- | ---: | --- |
| Eihort | 92 | Alloy → Loki |
| Abhoth | 22 | Alloy → Loki |
| Azasos | 24 | Alloy → Loki |
| Nodens | 20 | Alloy → Loki |
| Yidhra | 7 | 仅本地 journal，见下文限制 |
| Hastur | 13 | Alloy → Loki |

## 直接指标与权限

`realm.spire.metrics.enable` 控制直接指标。默认关闭；集群模块只对本次六节点启用。
新 exporter 位于 `pkgs/realm-identity-metrics/`，独立于 SPIRE 的 systemd 启动依赖。
即使 Workload API 不可用，`/metrics` 仍响应；`/healthz` 只在全部已启用 collector 和非 dormant 目标通过时返回成功。

| 本地端口 | 数据源 |
| --- | --- |
| 18491 | Agent 外部 attestor |
| 18492 | Server 外部 attestor，仅 Eihort |
| 18493 | HTTP responder；启用指标时常驻，不必等待首次认证 |
| 18494 | 证书与身份元数据 exporter |
| 18495 | SPIRE Agent 原生 telemetry |
| 18496 | SPIRE Server 原生 telemetry，仅 Eihort |
| 18499 | 观测 Caddy 的 canary-only mTLS 证书观察入口 |
| 30000–39999 | 每个 Ghostunnel unit 的独立 loopback status 入口；按注册名稳定哈希分配 |
| 19329 | Internet Caddy 的 loopback HTTP `/metrics`；由 `realm.internet.adminPort` 配置 |
| 19330 | Internet Caddy 的 canary-only TLS 1.3 SVID 观察入口；由 `realm.internet.statusPort` 配置 |

上述入口只监听 loopback。新增 status 端口同时有非 loopback 入站丢弃规则。
status 端口由注册名的稳定哈希生成，新增或删除注册项不会移动其他 unit 的端口。
早期按注册顺序分配的 28xxx 端口会在新增 egress 时整体后移，导致激活期间新旧进程抢占端口；已改为稳定哈希。
哈希冲突会在求值时触发断言失败，此时调整 `statusPortBase`。

Exporter 的 Workload API 注册只允许精确身份：

```text
spiffe://nyaw.xyz/observer/identity/<node>
```

Selectors 同时要求 `systemd:id:realm-identity-metrics.service` 和 `unix:user:root`。
它不冒充业务 workload。它只在内存中使用自己的 canary 凭据进行受限 mTLS 观察，不输出私钥或完整 SVID 响应。

Eihort 额外通过本地私有管理 socket 读取配置清单中六台 Agent 的公开元数据和别名条目。
不开放管理 API，不读取 `agent-data.json`、Server 数据库或密钥文件。
Exporter 服务屏蔽 SPIRE 持久化状态路径，限制能力、任务、内存和 CPU；仅 Eihort 为连接私有管理 socket 保留受限能力。

## 四种不同的成功

不能把以下事件混为一谈：

1. **Agent 本地 proof 提交。** 已发布 proof，且 ready response send 成功。指标 reason 为 `proof_submitted`。
   SPIRE Core 在读取响应后可以正常取消插件流；这种后续取消不撤销本地提交结果。
2. **Server 插件完成。** 已验证 proof、通过配额检查，并成功发送 attributes。reason 为 `attributes_sent`。
   这仍不表示 Core 已接受或已签发证书。
3. **Core 成功签名。** 原生 `spire_server_server_ca_sign_x509_svid` 在成功创建 X.509 SVID 后递增。
   名称没有 `_total` 后缀，重启会重置。它不证明客户端已收到证书。
4. **进程的证书源已经加载。** 通过下列来源观察证书，不能从签名或 SDS context 更新次数直接推断。

Responder 的 HTTP 读取也不是 proof 验证，更不是证书签发。
近期没有认证请求时，事件序列可以不存在或不增长；这不应产生“续期失败”告警。

## 逐进程证书观察

清单按 `unit / identity / source` 标识目标，同一 SPIFFE ID 的多个进程分别列出。
只读 systemd 活动状态；不会为探测启动 dormant 服务，也不会请求 Ghostunnel 的 `/_status`。

| source | 实际检查 | 限制 |
| --- | --- | --- |
| `ghostunnel_status_watch` | mTLS GET `/_metrics/prometheus`；校验证书链、时间和精确 URI | Ghostunnel 1.10 的 status listener 有独立 Workload API watch，不能证明业务 watch 已接受轮换 |
| `caddy_loaded` | 对应 Caddy 进程的共享 SVID 源，通过专用 loopback mTLS listener 的 GET `/` 返回 204 | 分别观察观测 Caddy 和 Internet Caddy；不代表公共 Caddy 的 Ghostunnel 代理 |

TLS 观察使用 exporter 自己的 canary、当前 Workload API bundle 和 TLS 1.3。
Caddy 专用入口只允许本机 observer 身份。Internet holder 保持
`unit="realm-internet.service"` 和 `realm.workloads.internet.spiffeID`，来源改为 `caddy_loaded`，
地址为 `127.0.0.1:${realm.internet.statusPort}`（默认 19330）。该 listener 必须与业务 listener
在同一 Caddy 进程中共享实际 SVID automation source 和 expectedID，要求 TLS 1.3，
只允许 `spiffe://<trustDomain>/observer/identity/<hostname>`，GET `/` 返回 204。
不能把 plaintext `/metrics` 入口作为 holder 地址，也不能用 exporter canary 的身份替代 gateway 身份。
当前 holder 清单仅使用上述两种来源；Internet gateway 的实际加载证据来自 `caddy_loaded`。

`realm_workload_svid_last_rotation_timestamp_seconds` 表示本 exporter 观察到叶证书指纹发生变化的时间。
它不是精确续期次数；首次采集、尚无变化或 exporter 重启后可以没有该序列。
指纹不作为指标标签，也不记录私钥、token、nonce、challenge ID 或完整 proof。

## 信任、有效期与缺失数据

- `realm_bootstrap_bundle_server_trust_valid` 实际用 pinned bundle 验证当前 Server 的链、时间和 `spiffe://nyaw.xyz/spire/server` URI。
  文件存在、bundle 中有未过期 CA、或 bundle 最晚到期时间，都不能替代此检查。
- `realm_spire_agent_metadata_valid` 是管理元数据检查，不是实时 Agent TLS 握手。
- `realm_spire_alias_matches_expected` 检查稳定别名、实际父 Agent、唯一 selector 和有限条目的到期时间。
- 当前 SVID、当前激活签发 CA、包含历史根的 bundle 分开显示。不能用 bundle 中最早到期证书判断当前 SVID 失效。
- 原生当前 CA 指标为 `spire_server_manager_x509_ca_rotate_expiration`，值是 Unix epoch，不是 TTL。
  当前 telemetry 将域标签转为 `trust_domain_id="nyaw_xyz"`。
- 结果超过 65 秒未刷新或已知证书到期后，不再显示成功。缺失数据不补成零错误或健康。
- dormant 单独表示 inactive。failed、activating、状态缺失和探测失败不归入 dormant。

## 独立抓取路径

每台在自身 `10.9.8.<id+1>:18497` 提供公开元数据中继，转发至 loopback exporter。
只允许 `hts-0` 上来自 Hastur `10.9.8.1/32` 和 Eihort `10.9.8.3/32` 的连接，并设置 socket/service IP 限制。
该中继不暴露 Workload API 或管理 socket。

`realm-identity` job 走此 WireGuard 路径；`identity-spiffe` 读取同一 exporter，但经过 SPIFFE 网关。
查询和告警明确选 job，不能把两条副本相加。vmagent 的本地 remote-write 与 vmalert 的 datasource/write 地址使用本地 VictoriaMetrics，减少身份故障导致监控一起失效的情况。

独立路径目前只中继元数据 exporter。原生 SPIRE 和 attestation 指标仍经过 SPIFFE 观测网关；看板分别显示路径是否可用。
故障 VM 已验证：停止 Agent 后，独立 `/metrics` 仍响应，canary 变为失败，恢复 Agent 后重新成功。

## Internet gateway 的 Caddy 监控契约

Internet gateway 当前由原生 SPIFFE Caddy 和 forwardproxy 插件实现，已替代 Envoy。
实现见 [`lib/realm/caddy-internet.nix`](../lib/realm/caddy-internet.nix) 和
[`nixosModules/realm-internet.nix`](../nixosModules/realm-internet.nix)。
上面的 2026-10-28 巡检早于替换；Caddy 的独立 VM 回归范围见
[CA 验证记录](realm-spire-ca-validation.md#恢复-caddy-后的回归)，线上 `validate` 行为见
[故障记录](troubleshooting/2026-10-29-caddy-validate-spiffe-hang.md)。这些记录不证明每条业务路径或当前看板查询均已在线复验。

Gateway 模块注册唯一的 `realm.observability.endpoints.internet-gateway`，
`port = realm.internet.adminPort`（默认 19329），`path = "/metrics"`，后端为 `127.0.0.1` 的普通 HTTP。
保留 adminPort 选项不表示开放 Caddy 管理写接口；观测路径只中继 `/metrics`。
身份 exporter 使用独立的 statusPort（默认 19330），两者均只监听 loopback。
启用身份指标时，端口唯一性断言检查这两个端口与其他 metrics/status 端口，防火墙同时丢弃它们的非 loopback 入站连接。
Gateway 模块在身份指标关闭时仍保持 loopback 绑定；身份指标模块不会为指标关闭的节点添加观测规则。

`mod/prometheus.nix` 的 `internet-gateway` job 经现有 SPIFFE 观测路径抓取
`/internet-gateway/metrics`，只发现声明该 endpoint 的主机。原 `caddy` job 继续抓取观测 Caddy，
两者是不同的抓取目标；gateway 模块仅注册 `internet-gateway` endpoint，避免重复发现。
业务 server 命名为 `internet` 并启用 Caddy HTTP metrics；plaintext metrics server 命名为 `metrics`。

- `InternetGatewayDown`：`up{job="internet-gateway"} == 0` 持续 2 分钟，critical。
  这表示抓取路径失败，也可能是观测网关或 SPIFFE egress 故障；不等价于业务 CONNECT 探测。
- `InternetGatewayHighErrorRate`：5 分钟窗口内完成响应的 5xx 比例超过 5%，持续 5 分钟，warning。
  分子、分母均使用 `caddy_http_request_duration_seconds_count`，筛选
  `job="internet-gateway", server="internet", handler="forward_proxy"`，分子另加 `code=~"5.."`。
  按 instance 聚合，分母必须大于零；没有流量或缺失数据不伪造成零错误率。

[Caddy 官方指标文档](https://caddyserver.com/docs/metrics)说明请求 duration histogram 包含 `code`，
而 `caddy_http_requests_total` 不包含 `code`，`caddy_http_request_errors_total` 统计 middleware errors。
因此 5xx 告警使用 histogram count，不把 middleware error counter 当成 HTTP 状态码。
CONNECT 长连接通常在隧道结束后才进入完成响应统计；该规则不检查隧道内的上游应用响应，
4xx 策略拒绝也不计为 5xx。生成器使用上述 server/handler；本次文档同步未在线复验其全部状态码样本。

CONNECT 字节统计以包内 vendor 的 Caddy 2.11.4 源码为准：
`modules/caddyhttp/responsewriter.go` 的 `responseRecorder.Hijack()` 用 `hijackedConn` 包装连接，
跟踪读取和写入字节；`metrics.go` 的 responseSize histogram 观察 `wrec.Size()`。
因此不能笼统声称通用 Caddy size 指标不统计 CONNECT 隧道字节；响应 size 可以包含 hijack 后写向客户端的隧道字节。
既有 VM 记录中的 CONNECT access log 已观察到 `bytes_read=1737, size=3142`；这是日志样本，
不等同于已直接验证对应 Prometheus histogram 的数值。
另一方面，requestSize histogram 使用 `computeApproximateRequestSize(r)`，估算请求 URL、方法、协议、
headers、Host 和已知 ContentLength，并不使用 hijacked connection 的读取字节计数。
这些通用 HTTP 指标仍未提供按 SPIFFE identity 区分、双向对称的专用隧道字节指标，
不能将 request/response size histogram 当作完整的双向身份流量计量。

仓库中的 [`caddy-zero-trust-egress.json`](../dashboards/caddy-zero-trust-egress.json)
使用 Caddy HTTP 指标和 JSON 访问日志。其历史 UID 仅用于链接兼容，不表示仍使用旧网关。

## 日志覆盖与限制

`mod/alloy.nix` 增加身份 journal source，保留 host、unit、job 和 subsystem 标签。
已在 Loki 确认 SPIRE Agent、Server、注册协调器、观测 Caddy、exporter 和多个 Ghostunnel unit 的日志。
同一 `_SYSTEMD_UNIT` 字段的多个 journal match 形成 OR；线上计数已确认会读取多个 unit。

**Yidhra 保留集中日志缺口。** `mod/hosts/yidhra.nix` 因主机约 452 MB 内存显式 `mkForce false` 禁用 Alloy。
本次没有覆盖这个保护设置，没有部署无效的 Alloy 启用候选代。
该节点仍有本地 journal、直接指标和独立抓取，但没有 Alloy→Loki 身份日志。
集中日志本身仍依赖 SPIFFE egress；不能声称身份故障时 Loki 路径仍可用。

Chrony 记录规则最初只覆盖四台，Abhoth 和 Yidhra 的缺失在看板中单独显示。本次没有用身份指标冒充时钟同步检查。

## 告警与测试

`lib/realm/identity-alerts.nix` 生成 76 条 recording/alert rules，由 `mod/prometheus.nix` 接入 Eihort 和 Hastur 的 vmalert。
固定六节点清单独立于实时发现，因此节点或整组指标消失仍能告警。
所有节点的 `workloads` collector 都是必需项：当前模块要求观测 Caddy，并始终配置对应 holder。

规则覆盖独立抓取缺失、collector 缺失/失败/过期、bootstrap 信任、Agent/别名元数据、证书临近到期、逐进程失败/过期/部分字段缺失、原生 telemetry 和当前 CA、重复 proof 失败及容量压力。
多数规则要求持续 2–3 分钟；证书临近到期阈值为剩余 10 分钟。没有用“近期签发量为零”判断续期失败。

逐 unit 的历史清单可检测最近 15 分钟内消失的 holder。仅传入节点名的规则无法知道在这个窗口前就已被删除的 unit；配置生成清单仍需审查。
现有 `RealmScraperStalled` 保留，30 分钟窗口加 15 分钟持续时间仍可能接近 45 分钟，不作为直接身份检查的替代。
历史 `EnvoyDown` / `EnvoyHighErrorRate` 规则已由上述 Internet gateway 规则替代；本次没有执行部署。

以下是既有验收记录，不是本次文档与看板同步重新运行的结果：

- `tests/realm-identity-metrics.nix`：25 项 Nix 配置检查。
- `tests/realm-spire-http.nix`：42 项现有 HTTP 配置检查。
- `tests/realm-identity-alerts.nix`：promtool 76 条规则、53 个场景、1,484 项告警断言。
- `tests/realm-identity-metrics-vm.nix`：真实 SPIRE 签发、canary、链/别名、进程证书、轮换、独立抓取、来源限制、Agent 停止与恢复、空闲 responder 指标。
- `tests/realm-spire-http-vm.nix`：HTTP 认证回归。
- 看板 70 条 PromQL 语法与线上查询检查；缺少轮换事件、失败事件或延迟样本的序列保持空，不伪造零值。

## 看板验收状态

**历史记录（2026-10-29）。**

当时的身份看板已通过 MCP 发布，包含 63 个 panel、70 条查询。
当时已完成结构检查和线上查询。本次仓库 JSON 已移除旧证书来源查询，尚未重新发布或进行线上视觉验收。
当前保存的 All/多选变量使用 `${instance:regex}`，中央 Agent/别名按目标 `node` 筛选。

**浏览器视觉验收已完成。** 2026-10-29 使用 CDP 完成 Pocket ID OIDC 登录，Grafana 会话为 Generic OAuth，用户 `i@nyaw.xyz`。
看板在浏览器中渲染正常，证书、采集覆盖和逐进程 panel 均显示线上数据。
图像 renderer 仍返回 HTTP 500，因此验收使用真实浏览器截图，而不是 renderer 输出。

此前登录失败的根因不是 OIDC URL 或凭据，而是 Grafana 缺少访问 `oidc.nyaw.xyz` 的 Realm HTTPS 网关声明：
主机把该域名解析到 `fdcc::3`，realm-agent 拒绝未声明的 ULA 目标，连接在 TLS 握手前被关闭，Grafana 报 `token exchange ... EOF`。
`mod/grafana.nix` 已按 Vaultwarden/Forgejo 的模式声明 `http.gateway.ref = "eihort"` 和 `resolveHosts = [ "oidc.nyaw.xyz" ]`。

首次部署该修复时，`switch-to-configuration` 返回 `4/NOPERMISSION`：新增 egress 使按顺序分配的 status 端口整体后移，
旧进程仍占用新端口，多个 ghostunnel 反复启动失败。端口改为稳定哈希后激活成功。
Socket 激活可能让个别 change 的 proxy 用旧 unit 定义启动；部署后必须核对运行参数与当前 unit 一致，必要时重启对应 unit。
