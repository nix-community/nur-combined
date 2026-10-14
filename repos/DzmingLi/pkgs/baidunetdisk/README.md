# 百度网盘

官方 Linux 桌面客户端 8.7.0，支持 `x86_64-linux`。本包替代原来的
`baidupcs-go`；配置中的包名需要改为 `baidunetdisk`，并允许非自由软件。

基于 [xddxdd 的 NUR 打包](https://github.com/xddxdd/nur-packages/blob/f7aa179dbae42b567c2a3c6e20ca41a3c4a1b05c/pkgs/uncategorized/baidunetdisk/default.nix)，
使用[官网](https://pan.baidu.com/download)提供的 HTTPS 安装包。

保留官方自带的 Electron。实测 nixpkgs 的 Electron 43.7.7 启动失败：
`@baidu/electron-panel-window` 要求 `NODE_MODULE_VERSION 110`，新版运行时使用
`148`。因此不能只替换 Electron 依赖；升级运行时还需要重编译相应原生模块。

原生引擎会校验库文件内容；自动修改 RPATH 或剥离符号会导致初始化时退出。
本包只修补可执行文件的 ELF 加载器，保留原生库字节，通过启动脚本提供依赖路径。

`gtkmm2.nix` 从 nixpkgs 25.11 移植，为官方浏览器引擎提供旧 GTK C++ ABI；
其许可见 `COPYING.nixpkgs`。
