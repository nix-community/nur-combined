{ lib
, buildPythonPackage
, python
, fetchPypi
, fetchFromGitHub
, pyaudio
, pkgs
, autoPatchelfHook
}:

# WONTFIX? shiboken6 throws "Segmentation fault"

# based on
# https://github.com/on-nix/python/commit/4d9a976ab5648a75db3a10a91619e9e1796abaa3

buildPythonPackage rec {
  pname = "shiboken6";
  version = "6.2.3";

  format = "wheel";
  src = fetchPypi {
    # url = "https://files.pythonhosted.org/packages/${dist}/${builtins.substring 0 1 pname}/${pname}/${pname}-${version}-${python}-${abi}-${platform}.whl";
    inherit pname format;
    version = "${version}-${version}";
    sha256 = "daf0dbe18a6272d9fa38e1143a98d6828e4c7428a423afacba0779476a3ed027";
    dist = "cp36.cp37.cp38.cp39.cp310";
    python = "cp36.cp37.cp38.cp39.cp310";
    abi = "abi3";
    platform = "manylinux1_x86_64";
  };

  #pythonImportsCheck = [ "shiboken6" ]; # Segmentation fault -> trying to load AVX2 instructions?

  propagatedBuildInputs = [
    #pyaudio # PyAudio
    #pkgs.flac

    #shiboken6
  ];
  buildInputs = [
    pkgs.stdenv.cc.cc # libstdc++.so.6: cannot open shared object file: No such file or directory
  ];

  nativeBuildInputs = [ autoPatchelfHook ];

  /*
  postFixup = let
    rpath = lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];
  in ''
    patchelf --set-rpath "${rpath}:${pytorch-bin}/${python.sitePackages}/torch/lib:" \
      "$out/${python.sitePackages}/torchvision/_C.so"
  '';
  */

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
