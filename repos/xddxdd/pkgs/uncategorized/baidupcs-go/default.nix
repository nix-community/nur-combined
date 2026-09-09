{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "baidupcs-go";
  version = "4.0.2-unstable-2026-09-09";

  src = fetchFromGitHub {
    owner = "qjfoidnh";
    repo = "BaiduPCS-Go";
    rev = "1b9131817aaf8ca7dee24bc00e33ebc4c7a5cc73";
    hash = "sha256-TRM9bZJDBFFrFSIab4DiZ75JdtvJFvZvji5cJtNDPM8=";
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "BaiduPCS-Go";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Baidu Netdisk commandline client, mimicking Linux shell file handling commands";
    homepage = "https://github.com/qjfoidnh/BaiduPCS-Go";
    license = lib.licenses.asl20;
  };
})
