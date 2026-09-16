{ stdenvNoCC, lib }:
stdenvNoCC.mkDerivation {
  pname = "aris-cursors";
  version = "1.0";

  src = fetchTarball {
    url = "https://github.com/user-attachments/files/31937245/aris.tar.gz";
    sha256 = "1wf7dzyp42rqfk62m5znd7y7x4lla0g4x47ch4lwvic0z2y3d8rr";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"
    cp -r . "$out/share/icons/aris-cursors"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Aris Cursors";
    homepage = "https://www.bilibili.com/video/BV1994y1L7YY";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
