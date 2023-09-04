{ lib
, buildPythonApplication
, build
, setuptools
, wheel
, fetchFromGitHub
, pdfium
, python3
, pillow
}:

buildPythonApplication rec {

  pname = "pypdfium2";
  #version = "4.18.0";
  version = "4.18.0.2023.08.25";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pypdfium2-team";
    repo = "pypdfium2";
    /*
    rev = version;
    hash = "";
    */
    # fix: the stable release 4.18.0 has no bindings/raw_unsafe.py file
    # the file was renamed from raw.py to _raw_unsafe.py to raw_unsafe.py
    rev = "901ba83993724e4371bdad386918c86c28b782d8";
    hash = "sha256-lDVyoAjcEw5WDOz9B/MB0TBKFwGK4IVtU3zKi3/sqnY=";
  };

  PDFIUM_BINARY = "sourcebuild";

  postUnpack = ''
    mkdir -p $sourceRoot/data/sourcebuild
    pushd $sourceRoot/data/sourcebuild
    echo ${pdfium.version} >.pdfium_version.txt
    ${if pdfium.pname == "pdfium-v8" then "touch .pdfium_is_v8.txt" else ""}
    cp ../../bindings/raw_unsafe.py .
    ln -s ${pdfium}/lib/libpdfium.so pdfium
    popd
  '';

  postInstall = ''
    rm $out/${python3.sitePackages}/pypdfium2/pdfium
    ln -s ${pdfium}/lib/libpdfium.so $out/${python3.sitePackages}/pypdfium2/pdfium
  '';

  nativeBuildInputs = [
    build
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    # optional dependency for bin/pypdfium2
    # https://github.com/pypdfium2-team/pypdfium2/pull/249
    pillow
  ];

  pythonImportsCheck = [ "pypdfium2" ];

  meta = with lib; {
    description = "Python bindings to PDFium";
    homepage = "https://github.com/pypdfium2-team/pypdfium2";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
