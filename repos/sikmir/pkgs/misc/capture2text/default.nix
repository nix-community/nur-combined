{ lib, stdenv, fetchurl, qmake, unzip, leptonica, tesseract4, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "capture2text";
  version = "4.6.2";

  src = fetchurl {
    url = "mirror://sourceforge/capture2text/SourceCode/Capture2Text_v${version}/Capture2Text_v${version}_Source_Code.zip";
    hash = "sha256-FeQ5E2lW+QOcg6Qi1I75W4BkQmfDiZtJ7+U2K08Ji2U=";
  };

  postPatch = ''
    substituteInPlace Capture2Text.pro \
      --replace "QMAKE_CXXFLAGS" "#QMAKE_CXXFLAGS" \
      --replace "-lpvt.cppan.demo.danbloomberg.leptonica-1.74.4" "-llept" \
      --replace "-luser32" "-ltesseract"

    # Fix app description
    substituteInPlace CommandLine.cpp \
      --replace "Capture2Text_CLI.exe" "capture2text"

    # Locate dictionaries in $XDG_DATA_DIR/Capture2Text/Capture2Text/tessdata
    # Initialize tesseract without specifying tessdata path
    sed -i '1 i #include <QStandardPaths>' OcrEngine.cpp
    substituteInPlace OcrEngine.cpp \
      --replace "QCoreApplication::applicationDirPath()" \
                "QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)" \
      --replace "exeDirpath.toLocal8Bit().constData()" "NULL"

    # See https://github.com/DanBloomberg/leptonica/commit/990a76de210636dfc4c976c7d3c6d63500e363b9
    substituteInPlace PreProcess.cpp \
      --replace "pixAverageInRect(binarizeForNegPixs, &negRect, &pixelAvg)" \
                "pixAverageInRect(binarizeForNegPixs, NULL, &negRect, 0, 255, 1, &pixelAvg)"
  '';

  buildInputs = [ leptonica tesseract4 ];

  nativeBuildInputs = [ qmake unzip wrapQtAppsHook ];

  qmakeFlags = [
    "CONFIG+=console"
    "INCLUDEPATH+=${leptonica}/include/leptonica"
    "INCLUDEPATH+=${tesseract4}/include/tesseract"
  ];

  installPhase = if stdenv.isDarwin then ''
    mkdir -p $out/Applications $out/bin
    mv Capture2Text_CLI.app $out/Applications
    ln -s $out/Applications/Capture2Text_CLI.app/Contents/MacOS/Capture2Text_CLI $out/bin/capture2text
  '' else ''
    install -Dm755 Capture2Text_CLI -t $out/bin
    ln -s $out/bin/Capture2Text_CLI $out/bin/capture2text
  '';

  meta = with lib; {
    description = "Capture2Text enables users to quickly OCR a portion of the screen using a keyboard shortcut";
    homepage = "http://capture2text.sourceforge.net/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
