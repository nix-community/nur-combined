{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchurl,
  fuse,
  stdenv,
  installShellFiles,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "alist";
  version = "3.43.0";

  src = fetchFromGitHub {
    owner = "AlistGo";
    repo = "alist";
    rev = "fef483af94284e0c150d95514bfe4b3cf3883553";
    hash = "sha256-3qDfeOZo/ruxHU4Vrycq2ejOSMKJfumQ3CCHjhfQAro=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # '0000-00-00T00:00:00Z'
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };
  web = fetchurl {
    url = "https://github.com/AlistGo/alist-web/releases/download/${version}/dist.tar.gz";
    hash = "sha256-ItH8vRCvIlcCnGWt0ApYkgH6v5UJ6ldJSm0Ii3ak6KI=";
  };

  proxyVendor = true;
  vendorHash = "sha256-MiIOKBwh4xD+sjMye4H+QDcWGMnUVsi7uuZwjxhNVaU=";

  buildInputs = [ fuse ];

  tags = [ "jsoniter" ];

  ldflags = [
    "-s"
    "-w"
    "-X \"github.com/alist-org/alist/v3/internal/conf.GitAuthor=Xhofe <i@nn.ci>\""
    "-X github.com/alist-org/alist/v3/internal/conf.Version=${version}"
    "-X github.com/alist-org/alist/v3/internal/conf.WebVersion=${version}"
  ];

  preConfigure = ''
    # use matched web files
    rm -rf public/dist
    tar -xzf ${web}
    mv -f dist public
  '';

  preBuild = ''
    ldflags+=" -X \"github.com/alist-org/alist/v3/internal/conf.GoVersion=$(go version | sed 's/go version //')\""
    ldflags+=" -X \"github.com/alist-org/alist/v3/internal/conf.BuiltAt=$(cat SOURCE_DATE_EPOCH)\""
    ldflags+=" -X github.com/alist-org/alist/v3/internal/conf.GitCommit=$(cat COMMIT)"
  '';

  checkFlags =
    let
      # Skip tests that require network access
      skippedTests = [
        "TestHTTPAll"
        "TestWebsocketAll"
        "TestWebsocketCaller"
        "TestDownloadOrder"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd alist \
      --bash <($out/bin/alist completion bash) \
      --fish <($out/bin/alist completion fish) \
      --zsh <($out/bin/alist completion zsh)
  '';

  doInstallCheck = true;

  versionCheckProgramArg = "version";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "File list/WebDAV program that supports multiple storages";
    homepage = "https://github.com/alist-org/alist";
    changelog = "https://github.com/alist-org/alist/releases/tag/v${version}";
    license = with lib.licenses; [
      agpl3Only
      # alist-web
      mit
    ];
    maintainers = with lib.maintainers; [ moraxyc ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # alist-web
      binaryBytecode
    ];
    mainProgram = "alist";
  };
}
