{ lib
, buildPythonPackage
, fetchPypi
, pkgs
, python
, coqpit
, attrdict
, tqdm
, pyogg_0_6_14a1
, numba
, webdataset
, optuna
}:

buildPythonPackage rec {
  pname = "stt";
  version = "1.3.0";
  disabled = python.pythonVersion != "3.9";
  format = "wheel";
  src = fetchPypi rec {
    inherit pname version format;
    #sha256 = "k+aKo46UcFDxlJ+Wj+XyzHGci2+grWvRTdCP54TOdmY="; # 1.3.0 cp310
    sha256 = "RNC2sp9rui5TLhV5mX5ZOhkvPPX13wcC7ubO2G5yqgA="; # 1.3.0 cp39
    dist = python;
    python = "cp39";
    abi = "cp39";
    platform = "manylinux_2_24_x86_64";
  };
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = with pkgs; [
    # libs for autoPatchelfHook
    xz # liblzma.so.5
    bzip2 # libbz2.so.1.0
    stdenv.cc.cc # libstdc++.so.6
  ];
  # https://github.com/NixOS/nixpkgs/pull/163217
  postInstall = ''
    patchelf --replace-needed libbz2.so.1.0 libbz2.so.1.0.6 $out/lib/python3.9/site-packages/stt/_impl.cpython-39-x86_64-linux-gnu.so
  '';
  propagatedBuildInputs = ([
    coqpit
    pyogg_0_6_14a1
    attrdict
    tqdm
    webdataset
    optuna
    numba
  ]);
  meta = with lib; {
    homepage = "https://github.com/coqui-ai/STT";
    description = "A library for doing speech recognition using a Coqui STT model";
    license = licenses.mpl20;
  };
}
