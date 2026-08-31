{
  buildGoModule,
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "baidupcs-go";
  version = "4.0.2-unstable-2026-08-25";

  src = fetchFromGitHub {
    owner = "qjfoidnh";
    repo = "BaiduPCS-Go";
    rev = "ab0e7996f24a25a518a4f227af60052c12fc488c";
    hash = "sha256-2ZhelDuOBl95RoP+lYZGXl4ct0N4ZXpE7lgKqrO4lHU=";
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

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/qjfoidnh/BaiduPCS-Go";
    tagPrefix = "v";
  };

  meta = {
    mainProgram = "BaiduPCS-Go";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Baidu Netdisk commandline client, mimicking Linux shell file handling commands";
    homepage = "https://github.com/qjfoidnh/BaiduPCS-Go";
    license = lib.licenses.asl20;
  };
})
