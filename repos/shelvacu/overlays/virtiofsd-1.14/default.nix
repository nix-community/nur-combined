final: prev: {
  # 1.14.0 has https://gitlab.com/virtio-fs/virtiofsd/-/commit/c581eba; without it, chown of a
  # symlink in a guest using --xattrmap fails with EPERM, which breaks nix builds
  virtiofsd =
    if prev.virtiofsd.version == "1.13.3" then
      prev.virtiofsd.overrideAttrs (
        finalAttrs: oldAttrs: {
          version = "1.14.0";
          src = oldAttrs.src.override {
            rev = "v${finalAttrs.version}";
            hash = "sha256-NeqeSqPeD3hjAcbck+g8bmarbUL1Nks8AMAi/WxwzwY=";
          };
          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) pname version src;
            hash = "sha256-7byiMT2/jf0R7zHr/HBeXKk2T+OQhlVhZ9QJHlEY/Ao=";
          };
        }
      )
    else
      prev.virtiofsd;
}
