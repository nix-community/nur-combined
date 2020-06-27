{ buildPythonApplication
, fetchPypi
, lib
, pytest
, libarchive
, pbzip2
, pigz
, cpio
}:
buildPythonApplication rec {
  pname = "patool";
  version = "1.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "4xgM+L/hO+289vVihFL8oMLISjta6MLT9Vcg6gTLEJc=";
  };

  # pypi is missing test fixtures
  doCheck = false;

  makeWrapperArgs = [
    "--prefix" "PATH" ":" (lib.makeBinPath [
      libarchive pbzip2 pigz cpio
    ])
  ];

  checkInputs = [
    pytest
  ];

  meta = with lib; {
    description = "Portable archive file manager";
    homepage = "https://wummel.github.io/patool";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
