# VType 独立输入法包

当前固定上游 `zhl-HFUT/vtype-linux` 的 `03b011c359a354bd8a790e24ae6e1552ae788359`
（2026-10-16），包含正式合入的 Nix 支持、小鹤双拼、19 组模糊音、
自定义翻页键、输入框内显示拼音及始终使用英文标点等设置。
上游已包含双拼、云响应时限与 Nix 运行时修复，移除对应旧补丁；
仅保留云候选请求等待身份锁最多 300ms 的补丁，减少后台同步时丢失云候选。

云候选有效期直接使用上游 [d617b635](https://github.com/zhl-HFUT/vtype-linux/commit/d617b63541121ffd5a99516fc15573cb6dee7410)
的实现：启用云功能时默认 1500ms，可在 `cloud.json` 中设置 `cloud_timeout_ms`
（200–5000 的整数）；网络请求本身仍使用上游的 1.2 秒超时。
`cloud-latency.patch` 仅调整身份锁竞争，不再修改候选有效期或 JNI 参数。
仓库的 `tests/vtype-linux/test-cloud-identity-lock.py --source <打补丁后的源码目录>`
离线验证短暂占锁后继续查询、持续占锁时有界退出，不读取用户账户或访问网络。

```sh
nix profile install github:lihaoze123/nur-packages#vtype-linux
wetype-setup
wetype-check
```

已经安装过同名包时用 `nix profile upgrade vtype-linux`。
首次初始化校验并提取官方 APK。升级运行目录前先退出 Fcitx5；初始化备份旧目录，
保留预置词库和个人学习数据。旧手动插件遮蔽时使用 `wetype-setup --migrate-fcitx`。

启动 Fcitx5 后，在“微信拼音”的设置中选择“小鹤双拼”；模糊音、翻页键、
应用内预编辑和英文标点也在同一设置界面调整。云功能需关联官方客户端，
再执行 `wetype-cloud enable`；定时刷新可另加 `--timer`，剪贴板同步单独启用。

`运行时缺少 cloud_proxy.py` 表示尚未执行新版 `wetype-setup`，或 `WETYPE_ENGINE_DIR`
指向了旧运行目录。初始化不关联设备，不自动启用云功能或重启 Fcitx5。
