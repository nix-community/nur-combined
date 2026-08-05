# Wayland 与输入法问题

## 适用范围

本文记录上游 NyaTerm `v1.2.0` x86_64 AppImage 在
`nyaterm-x86_64-linux-bin` 包中的已知问题。

该问题于 2026 年 8 月 5 日在使用 Fcitx5 的 Wayland 会话中完成调查。

## 问题现象

- NyaTerm 通过 XWayland 运行，而不是使用原生 Wayland 后端。
- Fcitx5 输入法无法在应用程序中使用。
- 从源码构建的 MeatShell 及其 AppImage 包均没有相同问题。

调查时的会话环境如下：

```text
XDG_SESSION_TYPE=wayland
WAYLAND_DISPLAY=wayland-1
DISPLAY=:0
XMODIFIERS=@im=fcitx
GTK_IM_MODULE=
```

## 已确认的原因

NyaTerm 使用 Tauri 构建，并在 Linux 上使用 GTK3/WebKitGTK。上游 AppImage
包含一个 `linuxdeploy-plugin-gtk.sh` AppRun hook，其中有以下内容：

```bash
export GDK_BACKEND=x11
export GTK_IM_MODULE_FILE="$APPDIR/usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache"
```

第一个赋值无条件选择 GTK 的 X11 后端，即使当前桌面会话是 Wayland。上游注释
说明这是用于规避 Tauri Wayland 崩溃问题的措施：

<https://github.com/tauri-apps/tauri/issues/8541>

第二个赋值强制 GTK 使用 AppImage 内置的输入法模块缓存。该缓存包含 GTK 的
XIM 和 Wayland 模块，但不包含 Fcitx5 GTK 模块（`im-fcitx5.so`）。因此，
应用程序无法发现 NixOS 安装的 Fcitx5 GTK 模块。

这是上游 AppImage 的打包决策，并不表示所有 Tauri 应用程序都必须使用 X11。

## 临时绕过方案

内置缓存包含 GTK 的 XIM 模块，因此在 Fcitx5 XIM 前端可用时，可以尝试：

```console
GTK_IM_MODULE=xim nix run path:.#nyaterm-x86_64-linux-bin
```

该方法不会启用原生 Wayland，并且依赖正常工作的 XIM 服务，不能视为完整修复。

## 可能的打包修复方案

可以在 Nix 包中使用修补后的 AppImage 内容：

1. 使用 `appimageTools.extractType2` 解包 AppImage。
2. 修补 `apprun-hooks/linuxdeploy-plugin-gtk.sh`。
3. 删除无条件设置的 `GDK_BACKEND=x11`，或者改为优先 Wayland、回退 X11 的
   `wayland,x11`。
4. 不再无条件覆盖 `GTK_IM_MODULE_FILE`。
5. 如果仍需要 GTK Fcitx 模块，将 `fcitx5-gtk` 加入 FHS 环境。
6. 使用 `appimageTools.wrapAppImage` 包装修补后的内容。

将原生 Wayland 设为默认值之前必须进行实际测试。上游 hook 是因为维护者遇到
Tauri Wayland 崩溃而有意强制使用 X11，因此移除该规避措施后，部分系统可能
重新出现渲染或启动问题。

## 版本升级检查清单

每次更新 NyaTerm AppImage 时：

1. 检查 `apprun-hooks/linuxdeploy-plugin-gtk.sh`。
2. 检查 `GDK_BACKEND` 是否仍被强制设置为 `x11`。
3. 检查 `GTK_IM_MODULE_FILE` 指向的内置缓存中是否存在 Fcitx 或 IBus 模块。
4. 测试应用程序能否通过原生 Wayland 启动。
5. 使用 Fcitx5 测试文本输入和候选词窗口。
6. 重新评估是否仍需要 Nix 侧的修补。
