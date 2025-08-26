{
  lib,
  stdenv,
  fetchzip,
  python3Packages,
  fetchPypi,
}:

let
  pname = "autotorrent2";
  version = "1.3.0";
  src = fetchzip {
    url = "https://github.com/JohnDoee/autotorrent2/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-TTE/9iqDVuwU68itfXtUb93MguOyIdrJvYAeybjQyTc=";
  };
  chardet = python3Packages.buildPythonPackage {
    pname = "chardet";
    version = "4.0.0";
    src = fetchPypi {
      pname = "chardet";
      version = "4.0.0";
      sha256 = "sha256-DW9ToV20Eg8rCMlPEefZPSyRHuEYtrMKBOw+6DEBefo=";
    };
    buildInputs = [ python3Packages.pytest ];
  };
  libtc = python3Packages.buildPythonPackage {
    pname = "libtc";
    version = "1.3.4";
    src = fetchPypi {
      pname = "libtc";
      version = "1.3.4";
      sha256 = "sha256-llp8QQlqadADEilV4mY+vJ5cyNuQgKSdbx1BsbefmSc=";
    };
    propagatedBuildInputs = [
      python3Packages.pytz
      python3Packages.deluge-client
      python3Packages.publicsuffixlist
      python3Packages.requests
      python3Packages.click
      python3Packages.tabulate
      python3Packages.appdirs
    ];
    doCheck = false; # was failing, just skip
  };
in
python3Packages.buildPythonPackage rec {
  inherit pname version;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-TTE/9iqDVuwU68itfXtUb93MguOyIdrJvYAeybjQyTc=";
  };
  propagatedBuildInputs = [
    python3Packages.setuptools
    python3Packages.toml
    python3Packages.click
    libtc
    chardet
  ];
  meta = with lib; {
    description = "Match torrents and data, remove torrents based on data, cleanup your disk for unseeded files. Autotorrent2 does everything you currently miss in your flow.";
    homepage = "https://github.com/JohnDoee/autotorrent2";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "at2";
  };
}
