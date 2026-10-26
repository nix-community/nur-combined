# hjem-activate@riro 反复失败：陈旧状态清单与 atuin 配置文件冲突

## 已确认的故障

`hjem-activate@riro.service` 每次启动都失败：

```text
ERROR Failed to deactivate file: '/home/riro/.config/atuin/config.toml'
File is not the same as expected
ERROR hjem failed error=built-in linker activation failed: 1 file(s) failed to activate/deactivate
```

失败后 `hjem-reload@riro.service` 与 `hjem-update-state@riro.service` 因 `Requires=` 依赖一起失败。`/var/lib/hjem/manifest-riro.json` 因此永不更新，故障在每次 rebuild 与每次开机时重复。

## 两个独立原因

### 1. 状态清单陈旧

`home/default.nix` 递归遍历 `home/`，把每个文件映射成 `hjem.users.riro.xdg.config.files` 的符号链接条目。

提交 `ce9e2903`（2026-10-23 01:13）删除 `home/atuin/config.toml`。但 `/var/lib/hjem/manifest-riro.json` 写于 01:02，仍保留该条目：

```json
{"type":"symlink","source":"/nix/store/p6wil8r5y7pahc6xs809204rr75byk3q-config.toml",
 "target":"/home/riro/.config/atuin/config.toml","clobber":false}
```

新清单已无此条目。`Manifest::diff()` 于是调用 `deactivate()` 删除旧符号链接。

`hjem internal update-state` 只能由 `hjem-update-state@riro.service` 执行。该单元 `Requires=hjem-reload@%i.service`，后者 `Requires=hjem-activate@%i.service`。激活失败即断链，状态清单无法自愈。

### 2. 目标文件被 atuin 替换成普通文件

`/home/riro/.config/atuin/config.toml` 现在是普通文件（0600、16094 字节、401 行），与 atuin 自带的 `crates/atuin-client/config.toml`（`EXAMPLE_CONFIG`）逐字节相同。

`Settings::get_config_path()` 的行为：

1. 无条件 `create_dir_all(config_dir())`，`config_dir()` 是 `$XDG_CONFIG_HOME/atuin`，默认 `~/.config/atuin`。
2. 若 `ATUIN_CONFIG_DIR` 存在则用该目录，否则用上一步目录。
3. 若配置文件不存在，写入 `EXAMPLE_CONFIG`。

`mod/dev.nix` 的 `programs.atuin.settings` 由 nixpkgs 写到 `/etc/atuin/config.toml`，并导出 `ATUIN_CONFIG_DIR=/etc/atuin`。因此在常规登录会话里 atuin 只读 `/etc/atuin`。但只要某个进程环境缺 `ATUIN_CONFIG_DIR`，atuin 就会在 `~/.config/atuin/config.toml` 生成默认模板。目录本身在任何情况下都会被创建。

## 为何符号链接被替换

`File::deactivate()` 先调用 `check()`。对 `symlink` 条目，目标不是符号链接时 `check()` 返回 `false`，于是 `deactivate()` 返回错误，拒绝删除用户改动过的文件。

`File::activate()` 走另一条路径：`clobber=false` 且目标不是悬空链接时直接 `return Ok(())`，静默跳过。所以条目仍在两边清单时激活“成功”，条目从新清单消失后立刻变成硬错误。

已用同一 `hjem-cli` 二进制复现：

```bash
# 状态清单有 symlink 条目，目标被换成普通文件，新清单去掉该条目
$ hjem internal activate --manifest m2.json --state manifest-riro.json --skip-state-update --prefix .backup- --json
ERROR Failed to deactivate file: '.../target'
File is not the same as expected
# exit 1

# 删除该普通文件后重试
$ hjem internal activate --manifest m2.json --state manifest-riro.json --skip-state-update --prefix .backup- --json
{"mode":"incremental","actions":[]}
# exit 0
```

## 修复

普通文件就是 atuin 默认模板，不含用户配置。真实配置在 `/etc/atuin/config.toml`。

1. 备份并删除该文件：

   ```bash
   cp /home/riro/.config/atuin/config.toml /tmp/atuin-config.toml.bak
   rm /home/riro/.config/atuin/config.toml
   ```

2. 以 root 重新执行 hjem 链路，让 `update-state` 写回新清单：

   ```bash
   systemctl start hjem-update-state@riro.service
   ```

3. 确认状态清单已无 atuin 条目：

   ```bash
   jq -r '.files[].target' /var/lib/hjem/manifest-riro.json | grep atuin
   ```

   `grep` 无输出即修复完成。

若无法执行第 2 步，重启系统等效，`hjem.target` 会在开机时重跑链路。

## 防止复发

- 不要让 hjem 与 `programs.atuin.settings` 同时管理 atuin 配置。atuin 客户端配置只保留在 `mod/dev.nix`，写入 `/etc/atuin`；`home/` 下不要再放 `atuin/config.toml`。
- 从 `home/` 删除任何文件前，先确认它会从状态清单移除。hjem 只删除仍与清单完全一致的符号链接，被应用改写过的文件会让激活永久失败。
- 需要 hjem 强制覆盖时，在条目上设 `clobber = true`。此时 `activate()` 会走 `atomic_activate()` 或备份路径，而不是静默跳过。
- `~/.config/atuin` 目录由 atuin 自己创建，删除后会被重建。这是 atuin 的行为，不是 hjem mapping。
