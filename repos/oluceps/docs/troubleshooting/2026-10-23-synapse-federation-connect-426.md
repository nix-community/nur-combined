# Synapse 联邦入站停在 Loading：2026-10-23

## 已确认的故障

matrix.org 上的账号加入 `#daeuniverse:nyaw.xyz` 时，Element Web 停在 Loading。别名指向的房间在本机存在。故障不在别名解析之后的加入流程。

入站联邦请求在验证 matrix.org 的签名密钥时失败，Synapse 返回 401。客户端收不到别名查询结果，所以界面一直等待。

直接原因是出站 CONNECT 被本机 Envoy 拒绝：

1. Synapse 的联邦客户端和 `.well-known` 客户端都经过 `HTTPConnectProxyEndpoint`。
2. 该实现使用 Twisted `HTTPClient.sendCommand`。这个方法把请求行写成 `HTTP/1.0`。
3. `realm-internet` 的 Envoy 没有打开 `accept_http_10`。它对这条 CONNECT 固定返回 `426 Upgrade Required`。
4. 同一条连接上的 `HTTP/1.1` CONNECT 返回 `200`。加上 `Host` 头不能改变 HTTP/1.0 的结果。

在 eihort 的 Synapse 网络命名空间里，对 `127.0.0.1:13128` 的对照结果是：

```text
CONNECT matrix.org:443 HTTP/1.0          -> HTTP/1.1 426 Upgrade Required
CONNECT matrix.org:443 HTTP/1.1          -> HTTP/1.1 200 OK
```

`.well-known` 日志直接记录 `Unexpected status on CONNECT: b'426'`。密钥请求常常记成 `TimeoutError('Timed out after 10s')`，事务发送记成 60 秒超时。这些超时是 426 之后的等待，不是出口链路本身用满了 10 秒。手动走同一代理拉取 `matrix-federation.matrix.org:443` 的密钥，完成时间不到 1 秒。

## 失败如何变成长时间封锁

一次密钥拉取失败后，Synapse 把目标写入 `destinations`，并按指数增加 `retry_interval`。matrix.org 在这次故障里的记录是：

```text
failure_ts      2026-10-23 01:15:49 +08
retry_last_ts   2026-10-23 13:44:06 +08
retry_interval  39692188 ms，约 11 小时
```

退避窗口内，Synapse 不再向 matrix.org 发请求，入站签名校验直接失败。清空这行之后，下一次 10 秒超时又把间隔设成 600000 ms。因此，代理恢复之前反复清空退避没有用。

本机缓存的 `ed25519:a_RXGa` 有效期到 2026-10-22 17:15:04 +08。10 月 23 日的入站请求必须重新拉取密钥，不能只用旧缓存完成校验。

## 已执行的恢复

1. 给正在运行的 `realm-internet` 配置加上 `http_protocol_options.accept_http_10 = true`。配置在 `/run/realm-internet-http10.json`。临时单元覆盖在 `/run/systemd/system/realm-internet.service.d/http10.conf`。
2. 重启 `realm-internet` 后，HTTP/1.0 CONNECT 返回 `HTTP/1.0 200 OK`。随后的 TLS 密钥请求返回 `HTTP/1.1 200`。
3. 重启 `matrix-synapse`，丢掉修复前占用连接池的失败连接。
4. 用一条签名长度不合法的 matrix.org 联邦请求探测。Synapse 在 0.01 秒内返回签名长度错误。这说明密钥已经取回，请求不再停在 401 的密钥查找上。

同一时间，其他服务器的 `.well-known` 开始返回正常的 `m.server`。修复前这些请求记录的是 426。

`lib/realm/envoy-internet.nix` 已写入 `accept_http_10`。这次只改了源码，还没有通过正常部署生效。`/run` 里的临时配置在主机重启后消失。重启之后、完成部署之前，426 会恢复。

## 排除过的路径

Synapse 网络命名空间只有 `lo`，没有 `/etc/resolv.conf`。`getaddrinfo("matrix.org")` 在 0.01 秒内失败。这不是 10 秒超时的原因。联邦 CONNECT 把主机名交给 Envoy，由 Envoy 解析。

同一条到代理的 TCP 连接上，第二次 CONNECT 返回 400。这不能解释日志里的 426。426 只在请求行是 HTTP/1.0 时稳定出现。

空闲隧道、并行密钥请求和 ghostunnel 管道时长都不能复现这批失败。失败请求往往没有对应的新出站隧道，因为 Envoy 在 CONNECT 握手阶段就已经拒绝。

## 后续检查

部署包含 `accept_http_10` 的配置后，删除 `/run` 里的临时单元覆盖，并确认 `realm-internet` 使用部署后的配置。然后检查新的联邦请求不再出现 `Unexpected status on CONNECT: b'426'`。

不要把原始 Synapse 日志、访问令牌或联邦请求正文提交到公共仓库。
