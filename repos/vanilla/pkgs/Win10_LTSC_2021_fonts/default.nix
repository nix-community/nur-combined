{ stdenv, requireFile, p7zip, wimlib, lib, ... }:
stdenv.mkDerivation rec {
  pname = "Win10_LTSC_2019_fonts";
  version = "LTSC_2019";

  src = requireFile {
    name = "SW_DVD9_WIN_ENT_LTSC_2021_64BIT_ChnSimp_MLF_X22-84402.ISO";
    sha256 = "c117c5ddbc51f315c739f9321d4907fa50090ba7b48e7e9a2d173d49ef2f73a3";

    # LTSC - Windows 10 Enterprise LTSC 2021 (x64) - DVD (Chinese-Simplified)
    url = "https://next.itellyou.cn/Original/#cbp=Product?ID=f905b2d9-11e7-4ee3-8b52-407a8befe8d1";
  };

  nativeBuildInputs = [ p7zip wimlib ];
  unpackPhase = "7z x $src";

  # https://wimlib.net/man1/wimextract.html
  buildPhase = ''
    cd ./sources/ && mkdir install && mv install.wim install
    cd install && wimextract install.wim 1 /Windows/Fonts
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/ && find . -name "*.ttf" -exec cp {} $_ \;
    mkdir -p $out/share/fonts/opentype/ && find . -name "*.ttc" -exec cp {} $_ \;
  '';

  meta = with lib; {
    description = "Windows 10 LTSC 2021 fonts, extract from iso.";
    homepage = "https://next.itellyou.cn/Original/Index";
    maintainers = [ maintainers.vanilla ];
  };
}
