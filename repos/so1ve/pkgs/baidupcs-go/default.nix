{
  buildGoModule,
  callPackage,
  lib,
  source ? callPackage ./source.nix { },
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "baidupcs-go";
  inherit (source) version src;

  vendorHash = "sha256-3kvB5QxtWuElhDIFFr3Awf5myf6l2Hx0M2k53ltQYeQ=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  # requester/downloader contains tests which download files from the network.
  doCheck = false;

  postInstall = ''
    rm -f "$out/bin/AndroidNDKBuild"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/BaiduPCS-Go";

  meta = {
    description = "Baidu Netdisk command-line client";
    homepage = "https://github.com/qjfoidnh/BaiduPCS-Go";
    changelog = "https://github.com/qjfoidnh/BaiduPCS-Go/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "BaiduPCS-Go";
    platforms = lib.platforms.unix;
  };
})
