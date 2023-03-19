{ lib
, buildPythonPackage
, python
, fetchPypi
, fetchFromGitHub
, pyaudio
, pkgs
, shiboken6
}:

buildPythonPackage rec {
  pname = "PySide6";
  version = "6.2.3";

  format = "wheel";
  src = fetchPypi {
    # url = "https://files.pythonhosted.org/packages/${dist}/${builtins.substring 0 1 pname}/${pname}/${pname}-${version}-${python}-${abi}-${platform}.whl";
    inherit pname format;
    version = "${version}-${version}";
    sha256 = "825fe460d4f9775b729792bbc826f6b41cc10641d4809875077cc54d63a982ba";
    dist = "cp36.cp37.cp38.cp39.cp310";
    python = "cp36.cp37.cp38.cp39.cp310";
    abi = "abi3";
    platform = "manylinux1_x86_64";
  };

  pythonImportsCheck = [ "PySide6" ];

  propagatedBuildInputs = [
    shiboken6
    #pyaudio # PyAudio
    #pkgs.flac

    #shiboken6
  ];
  #doCheck = false; # error: No Default Input Device Available
  # TODO
  # flac-win32.exe
  # flac-linux-x86
  # flac-mac
  meta = with lib; {
    #homepage = "";
    #description = "";
    #license = licenses.bsdOriginal;
  };
}
