{ lib
, stdenv
, fetchurl
, fetchFromGitHub
# TODO why would i need the V8 javascript engine in PDF documents?
, enableV8 ? false
}:

let
  sources = lib.importJSON ./sources.json;

  # TODO translate from nix names to pdfium names
  /*
    pdfium-android-arm.tgz
    pdfium-android-arm64.tgz
    pdfium-android-x64.tgz
    pdfium-android-x86.tgz
    pdfium-ios-arm64.tgz
    pdfium-ios-x64.tgz
    pdfium-linux-arm.tgz
    pdfium-linux-arm64.tgz
    pdfium-linux-musl-x64.tgz
    pdfium-linux-musl-x86.tgz
    pdfium-linux-x64.tgz
    pdfium-linux-x86.tgz
    pdfium-mac-arm64.tgz
    pdfium-mac-univ.tgz
    pdfium-mac-x64.tgz
    pdfium-v8-android-arm.tgz
    pdfium-v8-android-arm64.tgz
    pdfium-v8-android-x64.tgz
    pdfium-v8-android-x86.tgz
    pdfium-v8-ios-arm64.tgz
    pdfium-v8-ios-x64.tgz
    pdfium-v8-linux-arm.tgz
    pdfium-v8-linux-arm64.tgz
    pdfium-v8-linux-musl-x64.tgz
    pdfium-v8-linux-musl-x86.tgz
    pdfium-v8-linux-x64.tgz
    pdfium-v8-linux-x86.tgz
    pdfium-v8-mac-arm64.tgz
    pdfium-v8-mac-univ.tgz
    pdfium-v8-mac-x64.tgz
    pdfium-v8-win-arm64.tgz
  */
  src-name =
    let
      pname = if enableV8 then "pdfium-v8" else "pdfium";
      cpu =
        if stdenv.buildPlatform.parsed.cpu.name == "x86_64" then "x64" else
        stdenv.buildPlatform.parsed.cpu.name;
      kernel = stdenv.buildPlatform.parsed.kernel.name;
    in
    "${pname}-${kernel}-${cpu}.tgz"
  ;
in

stdenv.mkDerivation rec {
  pname = "pdfium${if enableV8 then "-v8" else ""}-bin";
  version = sources.version;

  src = fetchurl sources.sources.${src-name};

  buildCommand = ''
    mkdir $out
    tar xf $src -C $out
    cd $out

    chmod +x lib/libpdfium.so

    mkdir -p lib/cmake/PDFium
    mv PDFiumConfig.cmake lib/cmake/PDFium

    mkdir -p opt/PDFium
    mv LICENSE VERSION args.gn opt/PDFium
  '';

  meta = with lib; {
    description = "library for PDF manipulation and rendering (binary release)";
    homepage = "https://github.com/bblanchon/pdfium-binaries";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
