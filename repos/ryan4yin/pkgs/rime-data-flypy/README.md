# rime-data-flypy

小鹤音形 (flypy) 鼠须管 rime schema data, packaged for `fcitx5-rime` (Linux) and
Squirrel (macOS).

## Source

Vendored snapshot from 小鹤网盘:

- 官网：<https://flypy.cc/>
- 网盘地址：<http://flypy.ysepan.com>
- 路径：**第三方平台挂接文件 → 音形码 → 小鹤音形“鼠须管”for macOS.zip**（rime 系通用，2.6MB）
- 版本：`10.9.4`（取自 `flypy.schema.yaml` 的 `schema.version`）
- 快照时间：约 `2019-06-23`（`default.custom.yaml` 的 `distribution_version`）

## Layout

Installs the schema data to `$out/share/rime-data`, matching the layout expected
by nixpkgs' `rime-data` and `fcitx5-rime`'s `rimeDataPkgs`.

`flypy_user.txt` ships as an empty upstream template. The personal user
dictionary lives in the consuming configuration, which overlays its own copy on
top of this package.
