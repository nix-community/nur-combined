# 个人使用的 overlay
# 用于暴露一些包供其他包使用
self: super: {
  # 暴露 jportaudio，使其可以通过 pkgs.jportaudio 访问
  jportaudio = super.callPackage ../pkgs/by-name/jp/jportaudio/package.nix { };
  beatoraja = self.callPackage ../pkgs/by-name/be/beatoraja/package.nix { };
}
