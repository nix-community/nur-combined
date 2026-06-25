{ lib, steamguard-cli }:

# nixpkgs 把 steamguard-cli 的 meta.platforms 限成 linux，但它是纯 rust 包
# （nativeBuildInputs 只有 installShellFiles，无 dbus/openssl/libsecret 等 linux
# 专属依赖），darwin 上能正常构建。这里只补上 darwin 平台，让 mac 也能装。
steamguard-cli.overrideAttrs (old: {
  meta = old.meta // {
    platforms = lib.unique (old.meta.platforms ++ lib.platforms.darwin);
  };
})
