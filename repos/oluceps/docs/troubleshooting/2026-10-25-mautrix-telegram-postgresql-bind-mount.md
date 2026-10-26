# Telegram 桥接丢失 PostgreSQL socket：2026-10-25

## 现象与原因

eihort 上 `mautrix-telegram.service` 显示 active，但 Telegram 群消息停止进入 Matrix。目标房间最后的消息时间是 2026-10-24 22:36:33 +08。检查时，matrix.org 没有联邦退避，Envoy 的 `accept_http_10` 也已启用。

PostgreSQL 在 2026-10-24 22:39 重启。桥接当时仍是 17:39 启动的进程。realm 隔离把 `/run/postgresql` 作为目录绑定挂载到桥接的文件系统。PostgreSQL 重启时删除并重建了这个目录，但旧进程仍挂载旧目录。

检查结果：

| 位置 | `/run/postgresql` inode | 数据库 socket |
| --- | --- | --- |
| 主机与 Synapse | 421243 | 存在 |
| 重启前的桥接 | 390424 | 不存在 |

桥接日志出现 `dial unix /run/postgresql/.s.PGSQL.5432: connect: no such file or directory`。本次日志没有出现之前的 `engine was closed`。这是数据库目录挂载故障，与更新队列死锁不同。

## 恢复

2026-10-25 17:15:29 +08 重启 `mautrix-telegram.service`。新进程挂载当前目录，数据库 socket 恢复可见。

重启后目标群开始补发积压消息。检查时已从昨晚 22:36 推进到 23:24。Synapse 向 matrix.org 的多笔事务返回 HTTP 200，目标房间的最新事件序号低于 matrix.org 的成功投递进度。此结果证明补发和联邦投递恢复，不代表所有积压已处理完毕。

## 防止重现

`mod/postgresql.nix` 保留 PostgreSQL 的运行目录：

```nix
systemd.services.postgresql.serviceConfig.RuntimeDirectoryPreserve = "yes";
```

使用 `yes`，而不是 `restart`。`yes` 在停止后也保留目录，因此覆盖重启、分开 stop/start 和异常退出后的自动恢复。目录中的 socket 可以替换，消费者通过原目录就能看到新 socket。主机重启仍会清空 `/run`，之后所有进程都会重新建立挂载。

`mod/mautrix-telegram.nix` 只保留弱启动依赖：

```nix
systemd.services.mautrix-telegram = {
  after = [ "postgresql.service" ];
  wants = [ "postgresql.service" ];
};
```

`wants` 在启动桥接时拉起 PostgreSQL，`after` 保证两者同时启动时的顺序。数据库停止或重启不会连带停止桥接。连接中断后，由应用连接池重连。保留目录解决挂载失效，无需通过重启桥接刷新挂载，因此移除先前的 `requires`、`partOf` 和 PostgreSQL 反向启动桥接的 `wantedBy`。

运行时配置为：

- `/run/systemd/system/postgresql.service.d/90-preserve-socket-directory.conf`
- `/run/systemd/system/mautrix-telegram.service.d/90-postgresql-lifecycle.conf`，内容仅为 `After` 和 `Wants`

先前创建的 `/run/systemd/system/postgresql.service.wants/mautrix-telegram.service` 已移除。这些配置通过 `daemon-reload` 生效，没有重启数据库或桥接。正式 NixOS 配置尚需部署，运行时覆盖在主机重启后消失。

## 其他服务的检查

检查了 eihort 运行中服务的 65 个现存 `/run` 绑定挂载，未发现其他主机路径与进程内路径的 inode 不一致。

| 路径或服务 | 检查结果与修改 |
| --- | --- |
| PostgreSQL 消费者 | Atuin、Forgejo、Grafana、Immich、Synapse、Synapse S3 上传任务、Telegram 桥、NCPS、Pocket ID、SeaweedFS、Vaultwarden 共 11 个消费者挂载 `/run/postgresql`。上传任务当时未运行，其余进程内目录均正常。保留生产者目录可共同避免挂载失效，无需让全部服务随数据库重启。 |
| Autopeer → BIRD | Autopeer 挂载 `/run/bird`，BIRD 原配置会在停止时删除该目录。`mod/bird.nix` 增加 `RuntimeDirectoryPreserve = "yes"`，eihort 也应用运行时覆盖，没有重启路由进程。 |
| Synapse → journald | 原配置直接挂载 `/run/systemd/journal/socket`。重建 socket 单元时仍可能留住旧 socket inode。改为挂载 `/run/systemd/journal`，其生产者已保留目录。这项挂载修改需要部署并重启 Synapse 才生效。 |
| systemd-resolved、Alloy | resolved 和 journald 都已设置 `RuntimeDirectoryPreserve=yes`。相关消费者挂载目录，未发现同类目录删除风险。 |
| realm 代理 socket | 父目录由 tmpfiles 管理。消费者挂载父目录，socket 在稳定目录内替换。未发现单元停止时删除父目录的配置。 |
| SPIRE | 相关代理在主机路径中重新查找 socket，没有绑定单个 socket 或该运行目录，未发现同类挂载失效路径。 |

源码检查包括共享 realm 模块和相关 socket 生产者，并对 eihort、abhoth 的合并配置求值。运行中 inode 检查仅覆盖 eihort，其他主机没有部署或重启。

## 验证范围

独立的临时 systemd 服务测试通过：

1. 保留目录时，生产者重启后目录 inode 不变，未重启的消费者仍能访问该目录。
2. 分开停止、启动生产者时，目录 inode 不变。
3. 另行测试的强依赖方案通过了显式重启、分开 stop/start 和 SIGKILL 自动恢复测试，但保留目录后不再需要此方案，最终配置未采用启停联动。

临时服务测试没有操作 PostgreSQL、BIRD 或 journald。没有用生产数据库重启来验证，避免中断其他客户端。

## 检查命令

先比较主机与桥接挂载中的目录 inode，再检查 socket：

```sh
ssh root@eihort 'ls -ldi /run/postgresql /run/postgresql/.s.PGSQL.5432'
ssh root@eihort 'pid=$(systemctl show -p MainPID --value mautrix-telegram.service); nsenter -t "$pid" -m ls -ldi /run/postgresql /run/postgresql/.s.PGSQL.5432'
```

若桥接挂载旧目录且 socket 缺失，在 PostgreSQL 正常运行后重启桥接。检查消息映射和联邦投递进度，不要只检查 systemd 的 active 状态。检查数据库时只读取事件时间与计数，不输出消息正文或凭证。
