{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "sqlmux";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "kackerx";
    repo = "sqlmux";
    tag = "v${version}";
    hash = "sha256-GkxoPhFXFe9DB5DDs0LdnY2Ip1ooLbuDdReuYc/sr6s=";
  };

  vendorHash = "sha256-myRwEdvsGiwz/RtcRXAFdbkYAzZ1Egi9pwJYRsyfn8g=";

  subPackages = [ "cmd/sqlmux" ];

  env.CGO_ENABLED = "0";

  # 与上游 goreleaser 保持一致的版本信息：注入 v 前缀的版本号（commit/date 依赖 git 元数据，
  # 源码包里有 .gitattributes，导出时没有仓库信息，这里只注入版本）。
  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  # 上游的 TestNoChineseOutsideT 会遍历整个源码树，找没有走 i18n.T 的中文字面量。
  # 本包用 proxyVendor 生成 vendor/（上游源码树里没有它），其中的第三方代码会被误报，
  # 所以让该测试也跳过 vendor/。replace-fail 会在上游改掉这一行时直接报错。
  postPatch = ''
    substituteInPlace internal/i18n/i18n_test.go \
      --replace-fail 'strings.HasPrefix(rel, "e2e")' \
      'strings.HasPrefix(rel, "e2e") || strings.HasPrefix(rel, "vendor")'

    # 测试里的假 keychain 脚本用 #!/bin/bash，而 Nix 构建沙箱里只有 sh；脚本本身完全是 POSIX。
    substituteInPlace internal/app/connform_test.go \
      --replace-fail '#!/bin/bash' '#!/bin/sh'
  '';

  # 集成测试（-tags integration）需要真实的 PostgreSQL / MySQL / Redis / SQL Server，
  # 上游 CI 也只跑默认构建标签的单元测试。
  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 LICENSE "$out/share/licenses/sqlmux/LICENSE"
  '';

  meta = {
    description = "A tmux-like TUI database client for PostgreSQL, MySQL, SQLite, SQL Server and Redis";
    homepage = "https://github.com/kackerx/sqlmux";
    changelog = "https://github.com/kackerx/sqlmux/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "sqlmux";
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "lorlike";
        github = "lorlike";
        githubId = 47685593;
      }
    ];
  };
}
