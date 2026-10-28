# Cisco Packet Tracer 6.3 简体中文版

`cisco-packet-tracer-6-zh` 使用 Linux i386 **6.3.0.0008** 压缩包，
默认加载中文翻译并跳过启动时的 NetSpace 登录窗口。
命令为 `packettracer6-zh`，可以与本仓库的 9.0.1 中文包同时安装。

## 构建与使用

将合法取得的 `PacketTracer63_linux.tar.gz` 导入 Nix store，然后在仓库根目录运行：

```sh
nix-store --add-fixed sha256 ~/Downloads/PacketTracer63_linux.tar.gz
nix build .#cisco-packet-tracer-6-zh
nix run .#cisco-packet-tracer-6-zh
```

安装可用 `nix profile install .#cisco-packet-tracer-6-zh`；长期使用可在
NixOS / Home Manager 中声明该包。传统 NUR 入口需启用 `config.allowUnfree = true`。

源压缩包采用 `requireFile`，SHA-256（SRI）固定为
`sha256-wB8F0xcDgYrDelHwk+gGmwfNEOb/ONYsSu3aRfpF+Cc=`。
它包含的程序版本是 **6.3.0.0008**，与本地另一个 6.3.0.0009 可执行文件不同；
本配方不混用两个版本的程序或登录补丁。独立构建机也需要导入同一压缩包，
或使用已有构建缓存。

启动器设置 `PT6HOME`、Qt 4 插件路径和库路径。包使用 Nix 的 32 位运行库，
并携带程序需要的旧版 OpenSSL 1.0.2g，无需额外调用 `steam-run`。
首次运行的用户目录初始化提示会保留。命令行也支持相对路径的 `.pkt` 文件。
安装时用压缩包自带的 `bin/Linux/zip` 和 `unzip` 替换顶层旧工具，
避免顶层 `zip` 依赖已经淘汰的 `libc.so.5`。

附带脚本扩展的签名证书已在 2016 / 2018 年到期。
默认将 `ClearTerminalAgent`、`LanMultiuserAgent`、`Marvel`、`PcSoftware`、
`WanMultiuserAgent` 以及依赖旧 Linux / Java 环境的 `upnp`、`ptaplayer` 移到
`share/cisco-packet-tracer-6-zh/disabled-extensions/`，避免启动时扩展报错。
这些扩展的功能默认不可用，核心拓扑功能继续使用；需要保留原加载方式时可设置
`override { enableLegacyExtensions = true; }`。该选项不修复旧扩展，也不改写其签名或绕过证书校验。

## 汉化方式与覆盖范围

构建时以 6.3 自带的 `LANGUAGES/default.ts` 为模板，合并两个固定来源：

- [Hu-Tao-0715/Cisco-PT_ZH-CN](https://github.com/Hu-Tao-0715/Cisco-PT_ZH-CN/tree/623eca36cfa16354f175c85610b94e122db356c8)
  的 `6.2/languages/6.2sv_CN.ts`，GPL-3.0-or-later。其全部 10,231 个消息键与本包 6.3 模板一致，优先使用。
- [Liu8Can/CiscoPacketTracerChinese](https://github.com/Liu8Can/CiscoPacketTracerChinese/tree/4309e76755ff88cd2d2ed72b0e5502785427b28c)
  的 9.0.1 中文 PTL，MIT；与新版包使用相同提交，用于补充旧翻译缺失的词条。

`merge-translations.py` 只匹配完整的 `(context, source, comment)`，
排除未完成、废弃、空翻译和 Qt 占位符不一致的条目，保留原作者署名并补回缺失助记键。
使用 Qt 的 `lconvert` / `lrelease` 生成可由程序自带 Qt 4 加载的 PTL。

当前结果为 **6,776 / 10,231 条非空完成翻译，其中 5,671 条含中文**。
这是部分汉化：主菜单和常用配置界面有中文，缺少翻译的内容仍显示英文。
生成的可编辑 TS 安装到 `share/cisco-packet-tracer-6-zh/Chinese-6.3.ts`，
两个翻译项目的许可证随包保存在 `share/licenses/cisco-packet-tracer-6-zh/`。

中文同时安装为 `LANGUAGES/default.ptl` 和 `Chinese-6.3.ptl`，
英文原件保留为 `English.ptl`。已有配置选择了其他语言时，可进入
「选项 → 首选项 → 界面」选择 `Chinese-6.3.ptl`，更改语言后重新启动。
包的构建和安装不会主动改写个人配置。

## 启动登录补丁

与新版包一样，`skipLogin` 默认为 `true`。仅使用汉化而保留原登录流程：

```nix
nur.cisco-packet-tracer-6-zh.override { skipLogin = false; }
```

补丁根据本压缩包 Linux ELF 的符号表和 GNU 反汇编定位，构建时先核对完整原件哈希和原指令：

- 原始 `bin/PacketTracer6` SHA-256：`09b2752c12323a5d19fb5a9d960f8e8f0c43881e1665c27080faf8b38fdc6106`。
- `oldMain(int, char**)` 中虚拟地址 `0x0813097c`，文件偏移 `0x000e897c`。
- 原指令：`0f 84 0d 05 00 00`，即 `je 0x08130e8f`。
- 替换指令：`e9 0e 05 00 00 90`，即 `jmp 0x08130e8f; nop`。

该跳转直接进入登录窗口构造、模态执行和释放之后的原有启动流程。
它不会生成账号、令牌或服务器会话；联网账号功能仍取决于服务端认证。
哈希、原指令不符或重复应用补丁都会使构建失败。
随后 `patchelf` 设置 Nix 的 32 位动态链接器和库路径，因此最终 ELF 的整体哈希会变化。
升级压缩包时需要重新确认版本、补丁位置、跳转目标和实际运行行为。

## 验证

已通过 `nix fmt`、受影响包的 Flake / 传统 NUR 一致性求值，
并成功构建默认包及 `skipLogin = false` 变体。
默认包的五个运行时可执行文件和十五个共享库 / 插件均通过动态依赖解析检查。

在断网的 Xvfb 会话和隔离用户目录中，已确认中文菜单、跳过登录、
添加 1841 路由器、保存 `.pkt`，再以相对文件路径启动最终包并重新载入相同路由器。
默认不自动加载旧扩展时没有启动扩展错误弹窗。
补丁检查确认 `.text` 仅在预期六字节指令范围内变化；
`skipLogin = false` 的 `.text` 与压缩包原件相同，错误版本、截断文件和重复打补丁均被拒绝。
部分 Qt 标准对话框和首次目录提示仍为英文。
