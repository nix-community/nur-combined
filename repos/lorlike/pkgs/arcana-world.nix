{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "arcana-world";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "TarocchiLive";
    repo = "arcana-world";
    tag = "v${version}";
    hash = "sha256-hNfrr2mIH2reXM98qBHNWa5UGRRoFnaH0/Phe23y9ek=";
  };

  # 与上游 flake.nix 中的同名派生保持一致：依赖走 Go module proxy 拉取后再算
  # vendor 哈希，所以这里的 vendorHash 可以直接沿用上游（其 CI 每次 push 都会
  # 构建 .#default 来校验它）。
  proxyVendor = true;
  vendorHash = "sha256-pczP2+cgD4jM1R+HnSOEL9PqIaquqJ8yU9LT3PIhtlI=";

  subPackages = [ "cmd/arcana-world" ];
  env.CGO_ENABLED = "0";
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 LICENSE "$out/share/licenses/arcana-world/LICENSE"
  '';

  meta = {
    description = "A lightweight TUI alternative to bilibili LiveHime";
    homepage = "https://github.com/TarocchiLive/arcana-world";
    license = lib.licenses.gpl3Only;
    mainProgram = "arcana-world";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = [
      {
        name = "lorlike";
        github = "lorlike";
        githubId = 47685593;
      }
    ];
  };
}
