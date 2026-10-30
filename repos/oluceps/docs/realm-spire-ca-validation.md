# SPIRE 长期上游 CA 验证

验证日期：2026-10-29。SPIRE 1.15.3。仅本机隔离进程与 NixOS VM；未连接或部署生产节点。

2026-10-30 已补充保留旧 Server DB/keys/journal 的迁移 VM，包括过期缓存重新认证及完整回滚；
配置接线、测试证据和实际部署状态见[上游 CA 接入记录](realm-spire-upstream-rollout.md)。
旧的 fresh-upstream 测试与新迁移测试、生产部署结果需分别判断。

**当前状态：Internet gateway 已由 Caddy 替代 Envoy。** 后续完整 VM 回归确认，方案 3
（intermediate 直接作为锚）和方案 4（独立 root）都通过 HTTP/CONNECT、SPIFFE 身份授权、
自动/手工 CA 轮换、冷启动及重启。下文 Envoy 错误及“优先方案 4”的判断保留为切换前的
历史证据，不代表当前 Caddy 的限制。原 Milieuim Root 的 `pathLen=1` 约束仍然存在：
方案 3 的验证必须止于专用 intermediate。

## 两种候选结构

方案 3：

```text
Milieuim Root CA（P-256，pathLen=1）
    └── 新 Realm intermediate（P-384，pathLen=1）← Realm 直接信任这一张
            └── SPIRE 自动轮换 CA（P-384）
                    └── workload SVID（测试中为 P-384）
```

方案 4：

```text
独立 Realm root（P-384，pathLen=1）← Realm 信任锚
    └── SPIRE 自动轮换 CA（P-384）
            └── workload SVID（测试中为 P-384）
```

方案 3 的证书来源是既有 PKI，但工作负载验证链必须止于新的 intermediate。验证到原 Milieuim Root 会超过原根的路径长度约束。根签名不会让没有预置信任锚的消费者自动信任该 intermediate。

两种结构均使用原生 `UpstreamAuthority.disk`；长期上游 CA 不替代 SPIRE 的自动轮换签发 CA。没有采用不存在的 `ca.mode=external`、`include_upstream_bundle` 或离线 CA 导入流程。

## 新凭据

新材料保存在本机私有目录：

```text
/home/riro/Documents/cert-key/ecdsa/realm-spire-p384-20261029T053753Z/
├── root-anchored/   # 原根签发的新 intermediate
├── standalone/     # 独立自签 root
├── validate-spire.py
└── README.md
```

两个 case 均有 `ca.key`、`ca.csr`、`ca.cnf`、`ca.crt` 和单证书 `trust-bundle.pem`。目录权限 0700，新私钥权限 0600。证书于 2026-10-29 签发，有效至 **2036-10-26 05:37:53 UTC**。

| 证书 | SHA-256 指纹 |
| --- | --- |
| 根签 Realm intermediate | `5B:A6:E1:B6:9D:98:4D:66:A7:E1:32:3A:95:1E:7D:C2:50:C1:97:45:4C:7B:8F:5F:02:27:35:08:BF:41:55:40` |
| 独立 Realm root | `7F:33:B5:D3:7E:48:2F:78:E0:13:9C:E2:20:A5:74:7D:AA:00:8D:D7:4A:0B:99:A4:B7:DA:5A:A7:89:10:B9:90` |

原 `root.crt`、`root.key`、`root.srl`、`inter.crt`、`inter.key`、`inter.srl` 的 SHA-256 在签发前后保持一致。新证书使用随机 serial，没有更新既有 serial 文件。既有根保持 P-256；新 intermediate 的公钥是 P-384。独立 root 的公钥和签名密钥均为 P-384。

私钥没有进入仓库或 Nix store。真实凭据测试只挂载新 case 的私钥，未挂载原根私钥。VM 内使用运行时生成的临时 PKI。

## 真实凭据隔离测试

在 Bubblewrap 的独立 user、PID、mount 和 network namespace 中运行真实 SPIRE Server/Agent。工具链和输入凭据只读，环境仅使用显式变量，状态存放在有容量限制的临时 tmpfs。每次执行限制为 55 秒墙钟、40 秒 CPU、2 GiB 虚拟地址空间；具体限制及重跑入口见凭据目录的 README。

```sh
python3 /home/riro/Documents/cert-key/ecdsa/realm-spire-p384-20261029T053753Z/validate-spire.py root-anchored
python3 /home/riro/Documents/cert-key/ecdsa/realm-spire-p384-20261029T053753Z/validate-spire.py standalone
```

两种 case 均通过：

- disk 插件加载上游凭据，显式 bundle 只含长期信任锚。
- Agent 使用该静态信任锚 bootstrap，workload 获得预期 SPIFFE ID。
- 检查 workload 链中每一张证书的公钥，均为 P-384。
- 正确信任锚验证通过，另一 case 的无关信任锚验证失败。
- `localauthority x509 prepare/activate` 确实切换到不同签发 CA。
- 切换 CA 后，保持 bootstrap 文件不变，Agent 重启、Server 重启均正常。
- 删除 Agent 缓存和密钥后，新的 Agent 仍能使用同一 bootstrap 文件完成取证。
- SPIRE 分发的 bundle 包含长期信任锚。

这组快速测试在独立 namespace 中使用临时 join token，`rebootstrap_mode=never`。项目真实的 HTTP attestor、`rebootstrap_mode=always` 和代理互通由下面的 VM 测试覆盖。快速测试中的 `ca_ttl=90s`、SVID TTL=15s 只用于加速验证。

OpenSSL 的差异已经实测：

- 方案 4 使用普通 `openssl verify` 验证通过。
- 方案 3 需要 `openssl verify -partial_chain`，允许验证止于非自签的 intermediate。
- 方案 3 若改用原 Milieuim Root 验证 workload 完整链，得到预期错误 `error 25: path length constraint exceeded`。

每个 case 的 `spire-validation.json` 保存公开证书链和结果。短期测试 SVID 很快过期；重新执行脚本会生成新的测试状态，不影响长期 CA。

## HTTP 和代理集成

**历史记录：以下为切换前的 Envoy 集成。**

`tests/realm-spire-upstream-vm.nix` 复用 `tests/realm-vm.nix` 的实际服务与代理，并在 VM 启动时生成临时 PKI。独立检查两种候选，覆盖原生 HTTP attestation、固定 bootstrap、Ghostunnel、Caddy、Envoy、自动和手工 CA 切换、重新认证及重启。

当时观察到以下兼容性差异；本表不是当前 Caddy gateway 的验证结果：

| 消费者 / 验证方式 | 方案 3：intermediate 信任锚 | 方案 4：独立 root |
| --- | --- | --- |
| SPIRE Server / Agent | 通过 | 通过 |
| Ghostunnel 实际 mTLS | 通过 | 通过 |
| Caddy 身份验证及业务入口 | 通过 | 通过 |
| 当时的 Envoy Internet gateway | 拒绝证书链 | 通过 |
| OpenSSL 普通链验证 | 失败；需显式 `-partial_chain` | 通过 |

方案 3 的 Envoy 错误为：

```text
CERTIFICATE_VERIFY_FAILED: verify cert failed:
X509_verify_cert: certificate verification error at depth 2:
unable to get issuer certificate
```

同次运行的 Envoy `ssl.fail_verify` 计数也增长，初次为 `listener.[__1]_19328.ssl.fail_verify_error: 1`。SPIRE SDS 选用的是 `envoy.tls.cert_validator.spiffe`；这里的结论针对当时这条验证路径，不泛化为所有 Envoy 验证器。方案 3 的测试显式断言错误文本及计数，不能把该测试通过解读为 Internet 代理可用。未替换验证器或放宽验证策略。

因此，**当时优先采用方案 4**。该判断基于当时 Envoy 的验证路径；后续 Caddy 回归已确认两种方案均通过，见下文。把原 Milieuim Root 加回 bundle 仍会遇到 `pathLen` 限制。

## 最终集成结果与复现

**历史记录：本节结果与输出属于切换前的 Envoy，当前 Caddy 结果见下一节。**

两个隔离 VM 用例都已成功完成，分别约 195 秒。方案 3 的成功包含对 Envoy 不兼容的预期拒绝断言；**只有方案 4 通过完整 Ghostunnel、Caddy 和 Envoy 正向业务链路**。

两种 case 都通过：

- 原生 HTTP node attestation，使用唯一长期锚及 `rebootstrap_mode=always`。
- `ca_ttl=3m` 下的自动准备和激活，无时钟跳变，也没有用管理命令代替自动轮换。
- 手工 `localauthority x509 prepare/activate` 切换。
- 自动及手工切换后删除 Agent 状态，重新 HTTP 认证、Agent 重启及 Server 重启。
- 各阶段 bootstrap 文件 SHA-256 不变；工作负载链上每张证书的公钥均为 P-384。
- Ghostunnel 与 Caddy 实际业务流量，以及未授权和错误身份的拒绝。

方案 4 还通过现有完整 Internet gateway 用例，包括 HTTP、HTTPS CONNECT、SOCKS、IPv6、DNS 地址切换、目的地址限制和端口授权。各生命周期阶段都复查 Envoy 实际 TLS 访问。

以下命令和输出记录当时的 Envoy 运行。当前源码中的同名测试已使用 Caddy；直接运行会执行下文的 Caddy 用例，不会重现旧 Envoy 结果。

当时在仓库根目录执行：

```sh
nix build -L --impure --no-link --print-out-paths --option sandbox true --expr \
  '(import ./tests/realm-spire-upstream-vm.nix { nixpkgs = /nix/store/44zyg8i46md22kjs7hr3bdvia86rpd8p-source; }).case3'

nix build -L --impure --no-link --print-out-paths --option sandbox true --expr \
  '(import ./tests/realm-spire-upstream-vm.nix { nixpkgs = /nix/store/44zyg8i46md22kjs7hr3bdvia86rpd8p-source; }).case4'
```

该次使用的 nixpkgs 路径对应 `e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa`。成功运行的输出：

```text
/nix/store/aazhq62hxm82a438kshxbf7xarnkygmm-vm-test-run-realm-spire-upstream-case3
/nix/store/yiv8w4hhlazi5c16gd055ps3aphifgfr-vm-test-run-realm-spire-upstream-case4
```

本机完整日志：`/tmp/realm-upstream-validation/case3-verified.log`、`case4-verified.log`。成功运行后只修正了一条 Python 说明注释；已额外对比确认最终 VM 配置和执行脚本 AST 与上述成功输出完全相同。格式和 `git diff --check` 通过。

这些检查验证了缩短有效期后的真实自动轮换，没有实际等待默认 24 小时。真实新 CA 在 namespace 中验证，完整代理链路在同结构临时 CA 的 VM 中验证；未部署生产。

## 恢复 Caddy 后的回归

保留当前 Realm 模型和 SPIFFE v0.2.0 verifier，将历史固定版本的 `caddyserver/forwardproxy`
重新加入 `caddy-realm`。没有恢复静态 CA provider 或旧 Caddy CA 轮换补丁。

两种上游 CA 都运行了完整 Internet suite：HTTP、HTTPS CONNECT、原始 HTTP/1.0 CONNECT、
SOCKS、IPv4/IPv6、混合 DNS 答案、DNS 地址变更后的拒绝、私网/映射地址拒绝、默认端口和
Synapse 8448 例外。额外验证了 gateway SVID 更新不重启进程、原生及手工 CA 切换后保持
bootstrap 不变的 HTTP 冷认证，以及 Server/Agent 重启。

| 检查 | 结果 | 成功输出 |
| --- | --- | --- |
| 方案 3 全部链路 | 通过，约 198 秒 | `/nix/store/rns6ihv1qdkz26znxd75dq48xqf17jk6-vm-test-run-realm-spire-upstream-case3` |
| 方案 4 全部链路 | 通过，约 198 秒 | `/nix/store/z9bxicliqcyjwfn258pnjaj8z8zvqr4z-vm-test-run-realm-spire-upstream-case4` |
| 身份指标集成 VM | 通过，约 131 秒 | `/nix/store/6xxi7xf6dzgq7iiwhcszjxqj70mc8f8c-vm-test-run-realm-identity-metrics` |

身份指标 VM 检查 `realm-internet.service` 的实际 `caddy_loaded` 证书、剩余寿命和轮换，
确认轮换时 gateway PID 和重启计数不变。loopback `/metrics` 可抓取，配置 API 路径拒绝；
独立 TLS 1.3 状态入口只接受本机 observer SVID。

最终日志位于 `/tmp/realm-caddy-validation/final-case3.log`、`final-case4.log` 和
`final-identity-vm.log`。使用前述相同 build 命令即可运行当前 Caddy 用例；身份指标用例为：

```sh
nix build -L --impure --no-link --option sandbox true --expr \
  'import ./tests/realm-identity-metrics-vm.nix { nixpkgs = /nix/store/44zyg8i46md22kjs7hr3bdvia86rpd8p-source; }'
```
