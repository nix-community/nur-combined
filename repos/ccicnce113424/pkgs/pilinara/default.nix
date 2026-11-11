{
  sources,
  version,
  srcInfo,
  pubspecLock,
  gitHashes,
  lib,
  callPackage,
}:
callPackage ../piliplus/build-pili-application.nix { } {
  inherit (sources) pname src;
  inherit
    version
    srcInfo
    pubspecLock
    gitHashes
    ;

  patches = [
    ./disable-auto-update.patch
    ../piliplus/no-remove-before-patch.patch # shared with the PiliPlus fork
  ];

  passthru.updateScript = [ ./update.sh ];

  desktopName = "PiliNara";
  startupWMClass = "com.example.pilinara";
  commentZhCN = "使用 Flutter 开发的 BiliBili 第三方客户端，PiliPlus 分支";
  commentZhTW = "使用 Flutter 開發的 BiliBili 第三方客戶端，PiliPlus 分支";

  meta = {
    description = "Third-party Bilibili client developed in Flutter, PiliPlus fork";
    homepage = "https://github.com/Starfallan/PiliNara";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };
}
