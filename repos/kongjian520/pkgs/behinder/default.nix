# default.nix
{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  unzip,
  openjdk17,
}:

stdenv.mkDerivation rec {
  pname = "Behinder";
  version = "v4.1";
  jarName = "${pname}.jar";

  # 替換為 ZIP 文件中實際的 JAR 文件名
  zipJarName = "Behinder_v4.1.t00ls.jar";

  # 使用 fetchurl 下載預編譯的 ZIP 文件
  src = fetchurl {
    url = "https://github.com/rebeyond/Behinder/releases/download/Behinder_v4.1%E3%80%90t00ls%E4%B8%93%E7%89%88%E3%80%91/Behinder_v4.1.t00ls.zip";
    hash = "sha256-HpYNTBwA+jCP6dpr+yB2SjecuM9Lh08kVtGZgubGiMI=";
  };

  # 構建時依賴：解壓工具
  nativeBuildInputs = [ unzip ];

  # 運行時依賴：Java 環境和包裝腳本工具
  buildInputs = [
    openjdk17
    makeWrapper
  ];

  # 由於是 ZIP 文件，我們需要手動解壓
  unpackPhase = ''
    # 使用 unzip 解壓源文件
    unzip $src
    # 設置 sourceRoot 為當前目錄，假設 zip 內容直接解壓到這裡
    sourceRoot="."
  '';

  installPhase = ''
        # 1. 設置安裝目錄結構
        local installDir="$out/share/${pname}"
        mkdir -p $installDir/bin
        mkdir -p $out/share/applications/${pname}
        cp -r $sourceRoot/* $out/share/applications/${pname}/

    #     # 3. 創建可執行啟動腳本 (Wrapper)
    #     # 腳本路徑：$out/bin/${pname}
    #     makeWrapper ${openjdk17}/bin/java $out/bin/${pname} \
    #       --add-flags "-jar $installDir/$jarName" \
    #       --add-flags "-Xmx512m" \
    #       # 為了避免在當前目錄解壓/寫入文件，強制切換到一個臨時緩存目錄
    #       --run "mkdir -p $HOME/.cache/${pname} && cd $HOME/.cache/${pname}"

    #     # 4. 創建 Desktop 啟動器文件
    #     local desktopFile="$out/share/applications/${pname}.desktop"
    #     cat > "$desktopFile" << EOF
    # [Desktop Entry]
    # Name=${pname}
    # Comment=A Java Webshell Management Tool
    # Exec=${pname}  # 使用我們上面創建的 $out/bin/${pname} 啟動腳本
    # Icon=applications-other # 可以替換為更合適的圖標名稱或路徑
    # Terminal=false
    # Type=Application
    # Categories=Utility;Development;
    # EOF
  '';

  meta = with lib; {
    description = "A Java application (Behinder).";
    homepage = "https://github.com/rebeyond/Behinder";
    license = licenses.mit;
    platforms = platforms.all;
    broken = true;
  };
}
