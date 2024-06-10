{ lib, stdenvNoCC, pkgs, fetchurl, makeWrapper }: 
stdenvNoCC.mkDerivation rec {
  pname = "XperiFirm";
  version = "5.7.0";
  src = fetchurl {
    name = "xperifirm-mono.zip";
    url = "https://web.archive.org/web/20240406123724/https://xdaforums.com/attachments/xperifirm-5-7-0-by-igor-eisberg-zip.6059931/";
    sha256 = "sha256-+r2/27pTlKlgM/s4K6L7fnOuuCBXcpjC86nVan9W+hI=";
  };

  nativeBuildInputs = [ pkgs.unzip ];
  buildInputs = [ makeWrapper pkgs.mono ];


  sourceRoot = ".";


  installPhase = ''
    mkdir -p $out/bin
    cp -r XperiFirm-x64.exe XperiFirm-x86.exe "$out"

    makeWrapper "${pkgs.mono}/bin/mono" "$out/bin/XperiFirm-x64" \
      --add-flags "$out/XperiFirm-x64.exe"

    makeWrapper "${pkgs.mono}/bin/mono" "$out/bin/XperiFirm-x86" \
      --add-flags "$out/XperiFirm-x86.exe"

  '';

  meta = with lib; {
    license = licenses.unfree;
    description = "Xperia Firmware Downloader";
    homepage = "https://xdaforums.com/t/tool-xperifirm-xperia-firmware-downloader-v5-7-0.2834142/";
    platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    #maintainers = [ your_name ];
  };
}