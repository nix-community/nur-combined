# Matrix Telegram 桥接停止同步：2026-10-23

## 已确认的故障

`mautrix-telegram` 0.2609.0 的一个 Telegram 登录停止同步，但 systemd 仍显示服务运行。

故障进程的 Go 堆栈显示更新队列互相等待：

1. 主更新循环通过 `getDifference`、`handleChannel` 调用 `channelState.Push`，等待频道队列腾出空间。
2. 同一频道的 `getDifference` 停在 `state_channel.go:275`，等待主更新循环处理结果。
3. 501 个 goroutine 停在 `internalState.Push`。51 个频道停在 `state_channel.go:275`。
4. `readLoop` 在退出时等待更新处理任务结束，导致旧连接无法完成退出，重连流程无法继续。

采集时，主更新循环等待约 27 分钟，频道补差等待约 28 分钟，连接退出等待约 11 分钟。更新队列阻塞早于网络连接关闭。

另有独立的 Synapse 注册故障：桥接请求通过 Unix socket，没有 `X-Forwarded-For`。注册接口读取客户端 IP 时返回 HTTP 500。相同请求加上该头后返回正常参数错误。`mod/synapse.nix` 改用私有 TCP 入口，并保留 realm 身份认证。补充 journal socket 后，Synapse 应用日志恢复。

## 代理路径

```text
mautrix Telegram 客户端
  -> gost SOCKS5 127.0.0.1:11080
  -> HTTP CONNECT 127.0.0.1:13128
  -> realm ghostunnel
  -> eihort realm-internet / Envoy
  -> sing-box TUN
  -> Hysteria2 出口
  -> Telegram
```

sing-box 日志确认 Telegram 流量经过 TUN。15:34 建立的连接使用 `ab-hy-dmit-tyo-6`，16:03 重建的连接使用 `yi-hy-pan-sgp-6`。代理看到的源进程用户是 `internet`。因此，按 mautrix 进程名称匹配的规则无法直接识别这段流量。

日志中没有找到可归因于这次故障的 Telegram 代理连接错误。当前证据支持客户端队列循环等待，不能据此认定 Hysteria2 出口故障。

## 恢复与检查范围

16:03:50 对卡住的 Go 进程发送 SIGQUIT，采集堆栈。systemd 随后重启桥接。新进程开始处理消息，原测试房间出现新消息映射。这只证明重启后有短暂进展，不能证明持续同步恢复。

原始诊断保留在 eihort：

```text
/var/lib/mautrix-telegram/diagnostics/stuck-invocation
/var/lib/mautrix-telegram/diagnostics/stuck-goroutines.log
```

诊断目录限本机访问。不要将原始日志、桥接运行配置或数据库内容提交到公共仓库。

## 后续检查

修复更新队列的循环等待后，检查有积压消息时的启动过程、连接断开后的重连，以及每个 Telegram 登录的双向消息流。不要只根据 systemd 存活、全局消息计数或另一个登录的活动判断恢复。
