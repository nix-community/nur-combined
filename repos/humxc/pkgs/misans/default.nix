{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation {
  pname = "misans";
  version = "1.0";

  src = fetchzip {
    url = "https://cdn.cnbj1.fds.api.mi-img.com/vipmlmodel/font/MiSans/MiSans.zip";
    stripRoot = false;
    hash = "sha256-sDVOF7wZ22qsPkoQjFYNjaB4TrDbbNk+a2oHr8KbA+o=";
  };

  # only extract the variable font because everything else is a duplicate
  installPhase = ''
    runHook preInstall

    install -Dm644 MiSans\ 开发下载字重/*.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://web.vip.miui.com/page/info/mio/mio/detail?postId=33935854";
    description = "Free fonts developed by XiaoMi Corporation.";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
