{
  sources,
  version,
  srcInfo,
  pubspecLock,
  gitHashes,
  lib,
  callPackage,
}:
callPackage ./build-pili-application.nix { } {
  inherit (sources) pname src;
  inherit
    version
    srcInfo
    pubspecLock
    gitHashes
    ;

  patches = [
    ./disable-auto-update.patch
    ./no-remove-before-patch.patch
  ];

  passthru.updateScript = [ ./update.sh ];

  desktopName = "PiliPlus";
  startupWMClass = "com.example.piliplus";
  commentZhCN = "使用 Flutter 开发的 BiliBili 第三方客户端";
  commentZhTW = "使用 Flutter 開發的 BiliBili 第三方客戶端";

  meta = {
    description = "Third-party Bilibili client developed in Flutter";
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    maintainers = with lib.maintainers; [
      ulysseszhan
      ccicnce113424
    ];
  };
}
