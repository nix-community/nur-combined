{opencv4, jdk, ant, tesseract4, leptonica}:
(opencv4.override {
    # enableTesseract would use tesseract3, instead add it manually later
    enablePython=true; enableTesseract=false; enableContrib=true;
  }).overrideAttrs (old: rec {
    pname=old.pname+"Java";
    buildInputs=old.buildInputs ++ [jdk ant tesseract4 leptonica];
    postInstall=old.postInstall + ''
    ln -s $out/share/java/opencv4/libopencv_java*.so $out/share/java/opencv4/libopencv_java.so
    '';
})