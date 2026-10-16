# hastur：oo7 与 host 模式的 systemd credentials

## 范围

此配置只由 `hastur` 导入。其他 Niri 主机继续使用 GNOME Keyring。

LUKS 继续负责现有 TPM2／FIDO2 解锁。oo7 的凭据使用 `--user --with-key=host`，不增加 TPM 或 PCR 依赖。凭据名是 `oo7.keyring-encryption-password`。

以下数据必须保留在加密持久存储中：

- `/var/lib/systemd/credential.secret`：systemd 的主机秘密。
- `~/.config/credstore.encrypted/oo7.keyring-encryption-password`：加密的密钥环密码。
- `~/.local/share/keyrings/`：实际密钥环。

host 模式不防本机 root，也不防能同时取得主机秘密和 credential blob 的人。保留原密钥环密码和独立备份，不把自动解锁作为唯一恢复方式。

## 配置与启动顺序

- `mod/oo7-session.nix`：服务、凭据导入与只读就绪检查。
- `mod/hosts/hastur.nix`：选择 `Default_Keyring`，要求 `login` 也存在且已解锁。
- `script/oo7-session.py`：登记、备份和就绪检查工具，不读取 Secret Service 中的秘密值。

```text
Ly 登录 → niri.service → graphical-session.target
                               │
                               ▼
                         oo7-daemon.service
                               │
                          导入 credential
                               │
                          解锁既有 collection
                               │
                        检查默认 alias 与锁状态
                               │
                               ▼
                       vicinae-server.service
```

oo7 由 `niri.service` 拉起，但排在图形 target 之后。不要把它同时设为该 target 的 WantedBy 和 After，否则 target 的默认排序可能形成循环。

D-Bus 的 `dbus-org.freedesktop.secrets.service` 必须是 `oo7-daemon.service` 的同级别名。模块通过 `aliases` 显式生成这个链接。包内别名会被 NixOS 展开成独立的 store 文件链接，可能绕过正式 unit 的 drop-in。不能只检查两个链接最终是否指向相同文件。

登录前的 D-Bus 激活会检查图形 target 状态。没有活动图形会话时不启动 daemon。退出图形会话会停止 oo7 和 Vicinae。即使用户启用 linger，也不直接随 `default.target` 启动 oo7。

Vicinae 与 oo7 的生命周期绑定，并在每次启动前重新检查就绪状态。oo7 活动时通过 Upholds 恢复 Vicinae。若要持续停止 Vicinae 进行维护，先停止 oo7。不存在持久 ready 标记。

## 锁定版本的迁移保护

仓库的 oo7-server 是 0.6.0。此版本在迁移成功后会删除原 `.keyring` 文件，与较新源码的行为不同。

模块对这个版本增加迁移保护：

1. 根据配置的文件名选择默认 collection，避免把原默认 `Default_Keyring` 改成 `login`。初始化时也会将标准默认 alias 路径绑定到正确 collection。
2. 禁用自动创建空的默认 collection。密码错误或迁移失败时，不创建替代的空默认库。
3. 不再忽略密钥环加载错误。只有库已解锁、默认库存在且初始化完成后，才发布公共 Secret Service 名称。服务显式使用 Type=dbus，避免其他客户端在初始化窗口误判条目不存在。

升级 oo7 时，版本断言会要求重新核对补丁。替换操作使用 `--replace-fail`，源码改变时不会静默忽略补丁。

启动前会拒绝已有 Secret Service，以及旧目录与 v1 目录同名库并存的状态。遇到这些情况，应人工核对，不强制覆盖。

首次迁移前，工具会把整个 keyrings 目录复制到 `~/.local/state/keyring-backups/before-oo7-*/`。它会检查复制前后原件以及副本的摘要。只有检查通过的备份才有 `manifest.json`。原文件没有变化但迁移失败时，保留备份，不自动恢复或删除数据。

两个 collection 必须能用同一个密码解锁。如果 `Default_Keyring` 与 `login` 密码不同，当前配置会停止在就绪检查，不会自动统一密码。修改密码需要另行确认。

## 切换前：登记凭据

先确认原密码能解锁这两个 collection。将已有备份另存到独立的加密存储。同盘副本不是磁盘故障恢复方案。

下面的命令使用 `path:.`，因此新建但未提交的配置文件也会参与构建。它们不会切换系统或重启服务。

1. 在仓库根目录再做一次备份：

   ```sh
   nix run 'path:.#nixosConfigurations.hastur.config.services.oo7-session.package' -- backup
   ```

2. 以 `riro` 身份登记凭据，不要给整条命令加 sudo：

   ```sh
   nix run 'path:.#nixosConfigurations.hastur.config.services.oo7-session.package' -- enroll
   ```

   工具会要求输入两次原密钥环密码，不是硬件密钥 PIN。密码只经过管道和进程内存，磁盘只保存加密输出。systemd 可能另外请求权限认证。如果权限策略拒绝，不要放宽 TPM 设备权限或任意添加 Polkit 授权。

3. 只有需要更新已存在的凭据时，才使用：

   ```sh
   nix run 'path:.#nixosConfigurations.hastur.config.services.oo7-session.package' -- enroll --replace
   ```

   登记工具不会检查该密码是否真的匹配密钥环，也不会自动重启 daemon。collection 解锁结果由启动后的就绪检查确认。不要仅因两次输入相同就宣称验证成功。

## 首次切换

不要在仍运行 GNOME Keyring 的同一会话中直接启动 oo7，也不要使用 `--replace` 强行接管 D-Bus。

1. 完成备份与凭据登记后，构建下一次启动配置：

   ```sh
   sudo nixos-rebuild boot --flake 'path:.#hastur'
   ```

2. 在确认构建成功、恢复方式可用后，正常重启。通过 Ly 登录 Niri。
3. 检查服务和就绪状态：

   ```sh
   systemctl --user status oo7-daemon.service vicinae-server.service
   oo7-session ready
   journalctl --user -b -u oo7-daemon.service -u vicinae-server.service
   ```

就绪检查只读取 D-Bus 元数据。它检查服务 owner 的 PID、所需 collection、默认 alias、解锁状态，以及默认库中的 Vicinae 主密钥属性。它不调用 GetSecret，也不创建、解锁或修改条目。

## 验收

- 默认 collection 是 `Default_Keyring`，不是新空库。
- `Default_Keyring` 与 `login` 都存在且已解锁。
- 新增测试秘密在 daemon 重启后仍存在。
- oo7 重启时 Vicinae 会停止，并在就绪检查重新通过后恢复。
- 退出图形会话会停止服务。启动前、错误或缺失 credential 不会新建空默认库。

自动重启有次数限制。修正密码或凭据后，可以在图形会话内执行：

```sh
systemctl --user reset-failed oo7-daemon.service
systemctl --user restart oo7-daemon.service
```

## D-Bus 别名检查

```sh
systemctl --user show oo7-daemon.service dbus-org.freedesktop.secrets.service \
  -p Id -p Names -p MainPID -p DropInPaths
```

两个名字必须显示相同的 `Id=oo7-daemon.service`、非零 MainPID 和 drop-in 路径。若 D-Bus 别名独立运行，而正式 unit 报告已有 Secret Service，不要重新登记密码或删除 keyring。先修正激活入口。

若临时恢复使用 `/run/user/1000/systemd/user.control/` 中的别名，该修复只对本次开机有效。将修正后的 Nix 配置构建为下一次启动配置，避免重启后再次使用旧入口。普通的运行时 `systemd/user/` 目录排在 `/etc/systemd/user/` 后面，不能覆盖此处的 NixOS unit。

## 回滚

1. 暂停使用者并停止 oo7，避免两个提供者竞争。
2. 单独保存迁移后新增的秘密。原 GNOME 备份不包含这些新增数据。
3. 选择迁移前的系统 generation，或撤销 hastur 的 `oo7-session` 导入后构建恢复配置。
4. 将迁移后的 keyrings 目录移到另一个私有位置，再从已检查的备份恢复原目录。不要直接删除迁移结果。
5. 重启到原配置，检查原默认 alias、秘密和 Vicinae，再恢复使用。

`user.keystore` 随整个目录一起备份，但不属于 oo7 的 collection 迁移范围。不要因 collection 迁移完成就删除它。

## 开发检查

```sh
nix eval --raw 'path:.#nixosConfigurations.hastur.config.system.build.toplevel.drvPath'
git diff --check
```

测试不使用真实 keyring、真实 credential 或真实 Secret Service。系统求值与包构建不等于实际登录迁移验收。
