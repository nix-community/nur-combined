{
  lib,
  sources,
  buildGoModule,
  ...
}:
buildGoModule rec {
  inherit (sources.plasma-desktop-lyrics) pname version src;
  vendorHash = "sha256-ixWSIKTKDRzgSz5auquSB/87lzOMaJL5rsa89fcKyOc=";

  meta = with lib; {
    description = "KDE Plasma 桌面歌词显示挂件（后台服务）";
    homepage = "https://github.com/chiyuki0325/PlasmaDesktopLyrics";
    # Upsteam did not specify license
    license = licenses.unfreeRedistributable;
  };
}
