{
  lib,
  pkgs,
  fetchFromGitHub,
}:

let
  version = "0.4.4";

  # 上游自带 flake.nix，其中已经维护了 vendorHash、语音 helper 的原生库构建和
  # Qt 浮层打包，并由其 CI 的 nix job 持续验证。这里直接复用它的 outputs，
  # 避免重复实现，也避免 vendorHash 随 Go 代理返回的元数据漂移。
  src = fetchFromGitHub {
    owner = "TarocchiLive";
    repo = "arcana-world";
    tag = "v${version}";
    hash = "sha256-hNfrr2mIH2reXM98qBHNWa5UGRRoFnaH0/Phe23y9ek=";
  };

  # 把本仓库的 pkgs 作为上游 flake 的 nixpkgs 输入，让依赖都来自本仓库固定的
  # nixpkgs，而不是上游 flake.lock 里的那个。
  upstream = (import (src + "/flake.nix")).outputs {
    self = upstream;
    nixpkgs = {
      outPath = pkgs.path;
      lib = pkgs.lib;
    };
  };
in
(upstream.packages.${pkgs.stdenv.hostPlatform.system}.arcana-world).overrideAttrs (old: {
  meta = old.meta // {
    maintainers = [
      {
        name = "lorlike";
        github = "lorlike";
        githubId = 47685593;
      }
    ];
  };
})
