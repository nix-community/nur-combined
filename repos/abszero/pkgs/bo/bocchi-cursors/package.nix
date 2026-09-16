{ stdenvNoCC, lib }:
stdenvNoCC.mkDerivation {
  pname = "bocchi-cursors";
  version = "1.0";

  src = fetchTarball {
    url = "https://github.com/user-attachments/files/31919610/bocchi.tar.gz";
    sha256 = "1zf3sydkmr1cw619g7rrr92dkcj1n6xc50g3f1hy2fcykxmckmkm";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"
    cp -r . "$out/share/icons/bocchi-cursors"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bocchi Cursors";
    homepage = "https://www.bilibili.com/video/BV1Vv4y1o796";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
