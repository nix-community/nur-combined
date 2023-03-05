{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, torch
, tensorflow
, imageio
, ninja
, cudatoolkit
}:

let
  pname = "nvdiffrast";
  version = "0.3.0";
in
buildPythonPackage {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "NVLabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-erMac+xt5f3dMWu8c3rlpUV/uixUYOimHexwaNq0Uu0=";
  };
  postPatch = ''
  '';
  buildInputs = [
  ];
  propagatedBuildInputs = [
    numpy
  ];
  checkInputs = [
    torch
    tensorflow
  ];
  passthru.extras-require.all = [
    torch
    imageio
    ninja
    cudatoolkit
  ];
  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = {
      fullName = "Nvidia Source Code License (1-Way Commercial)";
      free = true;
    };
    description = "Modular Primitives for High-Performance Differentiable Rendering";
    homepage = "https://nvlabs.github.io/nvdiffrast/";
    platforms = lib.platforms.unix;
  };
}
