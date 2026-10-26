# Helix 文件刷新插件

本地源码基于 [mtul0729/helix-file-watcher](https://github.com/mtul0729/helix-file-watcher) 的提交 `2f7bb7ea3c505009d88ae23c31e6965f7165ddd1`。原项目为 [mattwparas/helix-file-watcher](https://github.com/mattwparas/helix-file-watcher)。

保留构建所需的 Rust、Scheme、插件元数据和原始 `Cargo.lock`。构建入口是 `../by-name/helix-file-watcher.nix`。不包含上游的独立 flake、开发环境和 Zellij 测试脚本。

本地修改直接写入源码：

- Rust 非阻塞读取文件事件，Scheme 每 250 毫秒在编辑器线程检查事件，避免跨线程回调停顿。
- 发现外部修改后，默认等待 2000 毫秒再刷新。
- 跳过有未保存修改的缓冲区。
- 新打开和关闭文档时，更新监视的文件列表。

初始化入口：

```scheme
(require "helix-file-watcher/file-watcher.scm")
(spawn-watcher)
```

Rust 依赖仍由 `Cargo.lock` 和 Nix 包中的 `cargoHash` 固定。修改依赖后需要更新两者。后续同步上游时，直接比较本目录中的源码。
