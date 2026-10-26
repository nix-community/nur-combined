# yidhra：切根后 initramfs 占用约 93 MiB 不可驱逐内存

## 已验证的结论

yidhra 的约 99.31 MiB `Unevictable` 中，约 93.09 MiB 来自启动 initramfs 的
ramfs 文件页。`nixos-init` 正常调用 `systemctl switch-root`；systemd 261.2
在 `pivot_root()` 成功后跳过旧根目录的递归清理。在本机 Linux 7.2.8 隔离虚拟机中，
这条路径可稳定复现旧 initramfs 文件页驻留。

后续核查上游确认：这是 Linux nullfs 切换后旧 initramfs 被内核引用固定的问题，
已有上游修复，详见文末。systemd 递归清理补丁能释放文件页，但属于 workaround，
不能据此把根因归到 systemd 或 nixos-init。

让成功分支也执行原有的临时根清理后，同一内核和实际 nixos-init 的测试中，
切根后的 `Unevictable` 降为 0，systemd 的状态序列化与恢复仍然完成。
本轮没有部署补丁或重启服务器。

## 版本基准

| 对象 | 版本 / revision |
| --- | --- |
| 本仓库真正的 nixpkgs pin | `e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa` |
| `../nixpkgs` 调查时的 HEAD | `f840a54a16862c4b0bd7df946b35f1f8d45bf778` |
| yidhra 启动版本 | `26.11.20260926.e158d9e` |
| 内核 | `7.2.8` |
| systemd | `261.2` |
| nixos-init | `0.1.0` |

锁文件需要从 `nodes.root.inputs.nixpkgs` 解析到 `nodes.nixpkgs_28`。
直接读取 `nodes.nixpkgs` 会得到另一个输入的 revision。

使用本地 Git 对象的 `git show <pin>:<path>` 查看 pin 的源码，未切换本地 checkout。
已核对两个 revision 的以下相关路径没有差异：

- `pkgs/by-name/ni/nixos-init/`
- `nixos/modules/system/boot/systemd/initrd.nix`
- `pkgs/os-specific/linux/systemd/default.nix`

本轮 Nix 求值使用的 pin 源码为：
`/nix/store/44zyg8i46md22kjs7hr3bdvia86rpd8p-source`。
systemd 261.2 的原始源码为：
`/nix/store/kmjp175p5kwpaab5vcvs97i3xcmay856-source`。

## 线上页级证据

只采集了 `/proc/kpageflags`、`/proc/kpagecgroup`、内存计数和文件大小元数据，
没有采集物理页内容或输出 secret 内容。

| 项目 | 大小 |
| --- | ---: |
| 全部 Unevictable | 99.3086 MiB |
| 根 cgroup 的主要非 swap-backed 文件页 | 93.0938 MiB |
| udev cgroup 的不可驱逐共享页 | 3.9063 MiB |
| 其余锁页等 | 约 2.31 MiB |

对实际启动 initrd 执行仅列元数据的 `cpio -itv` 后，按 4 KiB 页取整：

- 953 个普通文件：88.3594 MiB。
- 1,211 个符号链接：4.7305 MiB。ramfs 使用页存储符号链接内容。
- 合计：93.0898 MiB，与根 cgroup 的对应物理页仅差一页。

进程 `mlock` 不是这 93 MiB 的解释。线上 PID 1 的 systemd-executor 文件描述符也已核对：
它与真实磁盘上的 executor 具有相同设备号和 inode，没有发现它引用旧 ramfs 的证据。

## 源码调用链

1. `nixos/modules/system/boot/systemd/initrd.nix` 的 nixos-init 分支启动 `initrd-init`。
2. `pkgs/by-name/ni/nixos-init/src/initrd_init.rs` 完成新根初始化。
3. `src/switch_root.rs` 对 NixOS 调用 `systemctl --no-block switch-root /sysroot ""`。
4. systemd `src/core/main.c:do_reexecute()` 在 `MANAGER_SWITCH_ROOT` 下传入
   `SWITCH_ROOT_DESTROY_OLD_ROOT`。
5. systemd `src/shared/switch-root.c:switch_root()` 打开旧根 fd，尝试
   `pivot_root(".", ".")`，然后 `umount2(".", MNT_DETACH)`。
6. 261.2 的第 190–199 行仅在 pivot 失败、改用 MS_MOVE 的分支中调用
   `rm_rf_children(old_root_fd, ...)`。成功分支第 202–205 行明确假定卸载足以释放旧根。

Linux 7.2.8 的 `fs/namespace.c:init_mount_tree()` 将可变 rootfs 挂在 nullfs 上，
允许这一 pivot 成功。`root=fstab` 且没有 `rootfstype=tmpfs` 时，
`init/do_mounts.c:init_rootfs()` 选择 ramfs。

本地实验确认了成功 pivot 后仍有旧根文件页，以及显式删除可回收它们。
实验本身没有定位内核中的最后引用；后续上游调查已给出内核根因与修复，见文末。

对应上游源码：

- [nixos-init，固定 revision](https://github.com/NixOS/nixpkgs/blob/e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa/pkgs/by-name/ni/nixos-init/src/switch_root.rs)
- [systemd 261.2 switch-root](https://github.com/systemd/systemd/blob/v261.2/src/shared/switch-root.c)
- [Linux 7.2.8 mount namespace](https://github.com/gregkh/linux/blob/v7.2.8/fs/namespace.c)
- [Linux 7.2.8 rootfs 选择](https://github.com/gregkh/linux/blob/v7.2.8/init/do_mounts.c)

## 隔离复现与对照

调查工作目录为 `/tmp/initramfs-investigation/`，保留了 `probe.c`、
`build-initrd.py`、`run.py`、三个最终日志及机器可读的 `results.json`。
QEMU 使用 TCG、768 MiB RAM、`-nic none`，没有挂载宿主机目录或生产磁盘。

基础镜像和内核直接使用 yidhra 的实际启动构建产物：

```text
/nix/store/1n58bxk64hf9a15ai9nyw87x12f0g7w5-initrd-linux-7.2.8/initrd
/nix/store/k5jfbbjs1wprcyph1pgsvp0clcbvd5zw-linux-7.2.8/bzImage
```

fixture 仅替换启动入口与目标服务，在 tmpfs 新根中准备最小 bootspec、新根文件和
`/run` 的递归 bind mount，然后调用 initrd 中真正的 nixos-init。
新根再次运行 systemd，通过服务读取内存计数，并在 3 秒后再次采样。
每组日志均检查到 NixOS 初始化、使用内置 systemd、状态序列化、状态恢复和正常关机。

| 测试 | 切根前 Unevictable | 切根后 | 等待 3 秒后 |
| --- | ---: | ---: | ---: |
| 原版 261.2，pivot 成功 | 96,156 KiB | 96,160 KiB | 96,160 KiB |
| 原版，guest-only seccomp 强制 pivot 返回 EINVAL | 96,156 KiB | 0 KiB | 0 KiB |
| 补丁版，pivot 仍然成功 | 106,804 KiB | 0 KiB | 0 KiB |

补丁镜像额外包含补丁版 systemd 的二进制与私有库，因此起始数值较大。
验证指标是每组自身切根前后的不可驱逐页，不把不同镜像的空闲内存直接作等量比较。
seccomp 仅用于隔离虚拟机的因果对照，不是生产配置建议。

最终命令（工作目录及 store 输入仍存在时可重跑）：

```bash
PROBE_INITRD=/tmp/initramfs-investigation/original-initrd \
  python3 /tmp/initramfs-investigation/run.py nixos-init-baseline \
  root=fstab probe_nixos_init init=/probe-system/init

PROBE_INITRD=/tmp/initramfs-investigation/original-initrd \
  python3 /tmp/initramfs-investigation/run.py nixos-init-fallback \
  root=fstab probe_nixos_init init=/probe-system/init probe_force_fallback

PROBE_INITRD=/tmp/initramfs-investigation/patched-initrd \
  python3 /tmp/initramfs-investigation/run.py nixos-init-patched \
  root=fstab probe_nixos_init init=/probe-system/init
```

## 已验证的临时 workaround

[补丁](../../patches/systemd/261.2-clean-old-root-after-pivot.patch) 将已有的
`istmp > 0` 递归清理移到 pivot 成功/失败分支之后。保留原有的临时文件系统检查、
设备号限制、挂载点边界和 `SWITCH_ROOT_DESTROY_OLD_ROOT` 开关。
没有增加对真实磁盘文件系统的递归删除。

补丁版构建输出：`/nix/store/mbcbznwbmfrnhzhnbz6kbmlp3pdy5wgj-systemd-261.2`。
构建使用本仓库 pin 和原有 NixOS systemd 补丁集，追加本补丁；未运行完整 systemd
单元测试集，完成了构建及安装检查、上述原版/强制 fallback/补丁版 QEMU 对照。

这是调查得到的临时 workaround，尚未接入 NixOS 模块或提交上游。
完整 NixOS 启动、存储服务跨切根存活和 shutdown-initramfs 行为仍需在采用前覆盖。
它也不会自动清理已经完成切根的线上实例；线上约 93 MiB 的回收需要另行安排
带修复的启动验证。

## 上游核查（2026-10-20）

这不是本仓库或 nixos-init 独有的问题。[systemd #43911](https://github.com/systemd/systemd/issues/43911)
已有 Arch Linux 和 NixOS 用户报告，覆盖 x86_64/aarch64、systemd 260.4/262、
Linux 7.1/7.2；6.18 对照不受影响。ramfs 的残留计入 Unevictable，改成 tmpfs
则计入 Shmem，不能以 Unevictable 下降判断内存已回收。

同样恢复递归清理的 [PR #44144](https://github.com/systemd/systemd/pull/44144)
已关闭且未合并。维护者认为应修内核；最新 systemd main 与 v262 仍保留成功 pivot
时不递归清理的行为。内核上游已说明两个引用来源：

1. Linux 7.0–7.2 的 devtmpfsd 复制初始挂载命名空间，其中仍有 initramfs mount。
   [66d2faeccbff](https://github.com/torvalds/linux/commit/66d2faeccbff262164495b5cd8bcdc5b45ad5af0)
   改用私有空挂载命名空间，包含于 v7.3。
2. 次级 CPU 的 idle 线程复制 PID 1 的 fs_struct，保留旧根和工作目录引用；
   idle 线程不在普通任务列表中，pivot_root 不会更新它们。
   [d2bdb9b61b42](https://github.com/torvalds/linux/commit/d2bdb9b61b42766ed66eef822370ad44435f40fe)
   改为共享 init_fs，已包含于 v7.3。7.2 需要不同回移，不能直接套用主线补丁。

[合并说明](https://github.com/torvalds/linux/commit/a7064be65fda06712a73f858561e04591af74494)
明确解释：递归删除只能回收文件内容，无法解除 mount/superblock 的内核引用。
本地单 CPU QEMU 测试可覆盖 7.2 的 devtmpfsd 路径，未覆盖次级 idle 线程路径。

实时读取并固定 revision 的结果：

| 来源 | revision | linuxPackages_latest | 状态 |
| --- | --- | --- | --- |
| 本仓库 pin | e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa | 7.2.8 | 本地已复现 |
| nixos-unstable | 09063bd1f2b36fd9fd793c36dfade7bd40a93dfc | 7.2.11 | 源码仍含 devtmpfsd 旧路径，未包含完整修复 |
| nixpkgs master | 1af2d89b848f83a19c5add8ead6e37ce71b05961 | 7.3 | 源码包含两项修复，尚未做本地启动验证 |

版本映射来自对应 revision 的 `pkgs/top-level/linux-kernels.nix` 和
`pkgs/os-specific/linux/kernel/kernels-org.json`，未将本地 sibling checkout 当成最新。
GitHub API 原始查询保存在 `/tmp/initramfs-investigation/upstream/`。

建议优先验证包含完整修复的内核；不重复提交同一 systemd 清理补丁。
后续可贡献旧稳定分支回移、NixOS 回归验证，或在修复后仍复现时补充现有 issue。
此处上游状态来自源码与提交历史核查，不等于已经在 yidhra 验证 Linux 7.3。
