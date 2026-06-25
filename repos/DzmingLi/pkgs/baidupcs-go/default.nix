{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "baidupcs-go";
  version = "4.0.1";
  src = fetchFromGitHub {
    owner = "qjfoidnh";
    repo = "BaiduPCS-Go";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AvwdAOjuQxdmhg+IJxQ9e9iMXqveLjoF/W7ntZZmES4=";
  };
  vendorHash = "sha256-oOZeBCHpAasi9K77xA+8HxZErGWKwb4OaWzWhHagtQE=";
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
