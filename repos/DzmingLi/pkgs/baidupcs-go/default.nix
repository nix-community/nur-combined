{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "baidupcs-go";
  version = "4.0.2";
  src = fetchFromGitHub {
    owner = "qjfoidnh";
    repo = "BaiduPCS-Go";
    rev = "v${finalAttrs.version}";
    hash = "sha256-o0Oh6zLJT25+smEgWy7E8fTigJ2FLpBXoaZSYCRFvic=";
  };
  vendorHash = "sha256-3kvB5QxtWuElhDIFFr3Awf5myf6l2Hx0M2k53ltQYeQ=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  postInstall = ''
    rm -f $out/bin/AndroidNDKBuild
  '';

  postVersionCheck = ''
    rm -f $out/bin/pcs_config.json
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "BaiduPCS-Go";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "仿 Linux shell 文件处理命令的百度网盘命令行客户端";
    homepage = "https://github.com/qjfoidnh/BaiduPCS-Go";
    license = lib.licenses.asl20;
  };
})
