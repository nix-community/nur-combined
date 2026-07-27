{
  lib,
  buildGoModule,
  fetchFromGitHub,
  addDriverRunpath,
  cudaPackages,
}:

buildGoModule rec {
  pname = "amumax";
  version = "2023.12.14";

  src = fetchFromGitHub {
    owner = "MathieuMoalic";
    repo = "amumax";
    rev = version;
    hash = "sha256-U9e8DvgAb5/e2JTDI0yXPF9ollixax3JjeyEFiJbesM=";
  };

  vendorHash = "sha256-YqB7EofpTqDnqOQ+ARDJNvZVFltAy0j210lbSwEvifw=";

  nativeBuildInputs = [
    cudaPackages.cuda_nvcc
    addDriverRunpath
  ];

  buildInputs = [
    cudaPackages.cuda_cudart
    (lib.getDev cudaPackages.cuda_nvcc) # for <crt/host_defines.h>, bug in Nixpkgs
    cudaPackages.libcufft
    cudaPackages.libcurand
  ];

  CGO_CFLAGS = [
    "-lcufft"
    "-lcurand"
  ];

  CGO_LDFLAGS = [ "-L${cudaPackages.cuda_cudart.lib}/lib/stubs/" ];

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false; # Requires a GPU

  postFixup = "
    addDriverRunpath $out/bin/*
  ";

  meta = with lib; {
    description = "Fork of mumax3";
    homepage = "https://github.com/MathieuMoalic/amumax/tree/main";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    mainProgram = "amumax";
  };
}
