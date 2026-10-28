# Cisco Packet Tracer 简体中文版

`cisco-packet-tracer-zh` 固定使用官方 Linux x86-64 **9.0.1** 安装包，
默认加载简体中文，并在构建时应用跳过启动登录窗口的补丁。
命令为 `packettracer9-zh`，应用菜单显示「Cisco Packet Tracer（简体中文）」。

## 构建与使用

先从 [Cisco Networking Academy](https://www.netacad.com/resources/lab-downloads)
取得 `CiscoPacketTracer_901_Ubuntu_64bit.deb`，再导入 Nix store：

```sh
nix-store --add-fixed sha256 ~/Downloads/CiscoPacketTracer_901_Ubuntu_64bit.deb
nix build .#cisco-packet-tracer-zh
nix run .#cisco-packet-tracer-zh
```

上面的命令在仓库根目录执行。安装可用 `nix profile install .#cisco-packet-tracer-zh`；
长期使用时，在 NixOS / Home Manager 中声明该包。
传统 NUR 入口需要调用方启用 `config.allowUnfree = true`。
官方安装包采用 `requireFile`，不会由包配方自动从登录站点下载；在独立构建机或
CI 上重建也需要提供此文件，或使用已构建的缓存。

默认启动语言对应中文。已有用户如果选择过其他语言，可在
「选项 → 首选项 → 界面」的语言列表中选择 `Chinese-9.0.1.ptl`，点击更改语言并重启。
`English.ptl` 保留英文界面。
如需接近旧版截图的配色，在同一页底部将配色方案选为 **Classic / 经典**。
9.0.1 的工具栏布局和图标仍与旧版本存在差异。部分 Qt 标准文件对话框仍保留英文。

只使用汉化、保留登录流程：

```nix
nur.cisco-packet-tracer-zh.override { skipLogin = false; }
```

该包使用 Packet Tracer 自身的用户配置；包安装不会主动改写用户配置或关闭现有程序。

## 语言包来源与 Linux 路径修复

中文文件来自 [Liu8Can/CiscoPacketTracerChinese](https://github.com/Liu8Can/CiscoPacketTracerChinese)
的提交 `4309e76755ff88cd2d2ed72b0e5502785427b28c`，
文件名为 `哔哩哔哩 沧浪同学 中文汉化包.ptl`。
仓库以 MIT 许可证发布，许可证随包安装在 `share/licenses/cisco-packet-tracer-zh/`。
Cisco 程序本体为非自由软件。

Linux 9.0.1 的 `CLanguageHandler` 从程序目录的 `../LANGUAGES/` 加载翻译，
而官方 AppImage 提供小写 `languages`；配方补充大小写兼容链接。
中文文件同时安装为 `default.ptl` 和 `Chinese-9.0.1.ptl`，英文原件保留为 `English.ptl`。

## Linux 登录补丁维护

补丁根据官方 Linux ELF 的符号表和反汇编定位，不使用 Windows 补丁的偏移或特征码。
校验目标：

- 官方 DEB SHA-256（SRI）：`sha256-NoPdh+d5iFNyrpo1wabllNEvST5knnxpdAhynBRZR5s=`。
- 原始 `opt/pt/bin/PacketTracer` SHA-256：`3e871b6463798076e4c26adfc2bb4820b9a7822b18bf1cdb33d949048fd3a9db`。
- ELF `.text` 中该地址与文件偏移相同：`0x42e9a4e`。
- 原指令：`0f 85 0e 0f 00 00`，即 `jne 0x42ea962`。
- 新指令：`e9 0f 0f 00 00 90`，即 `jmp 0x42ea962; nop`。

该分支位于 `oldMain(int, char**)`：补丁跳过 `CNetspaceLogin` 的构造与模态窗口，
进入现有的 `CAppWindow::setLoginState` 路径（`esi = 2`），随后启动应用事件循环。
它不会产生 Cisco 账户、令牌或服务器会话；需要账户的联网功能仍取决于服务端认证。

`patch-login.py` 在写入前核对整个原始 ELF 的摘要和六字节原指令；版本变化、
二次打补丁或输入文件不符会使构建失败。更新 Cisco 版本时必须重新核对 ELF、
跳转目标及运行行为，同时更新固定版本、下载哈希和补丁校验值。

## 验证

已通过 `nix fmt`、受影响包构建及传统 NUR / Flake 一致性求值；
在隔离的 Xvfb 会话与全新用户目录中确认默认中文、跳过登录、
添加路由器、保存 `.pkt` 并重启重新打开。
同时确认仅六字节指令发生替换、错误输入被拒绝，
`skipLogin = false` 的 ELF 与官方原件逐字节一致。
